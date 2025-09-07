#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 -p python3Packages.curl-cffi
import json
import logging
import sys
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from typing import Any, Dict, List, Optional
from urllib.parse import urljoin

import curl_cffi


class LogLevel(Enum):
    """日志级别枚举"""

    DEBUG = "DEBUG"
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"


class CheckinStatus(Enum):
    """签到状态枚举"""

    SUCCESS = "success"
    FAILED = "failed"
    ALREADY_CHECKED = "already_checked"
    UNAUTHORIZED = "unauthorized"
    NETWORK_ERROR = "network_error"


@dataclass
class CheckinResult:
    """签到结果数据类"""

    status: CheckinStatus
    message: str
    data: Optional[Dict[str, Any]] = None
    error_code: Optional[str] = None
    timestamp: datetime = field(default_factory=datetime.now)


@dataclass
class VeloeraConfig:
    """Veloera 配置数据类"""

    base_url: str
    user_id: str
    access_token: str
    checkin_endpoint: str = "/api/user/check_in"
    timeout: int = 30
    retry_count: int = 3
    retry_delay: float = 1.0

    @property
    def checkin_url(self) -> str:
        """获取完整的签到URL"""
        return urljoin(self.base_url, self.checkin_endpoint)


class Logger:
    """企业级日志管理器"""

    def __init__(self, name: str = "VeloeraCheckin", level: LogLevel = LogLevel.INFO):
        self.logger = logging.getLogger(name)
        self.logger.setLevel(getattr(logging, level.value))

        if not self.logger.handlers:
            # 控制台处理器
            console_handler = logging.StreamHandler()
            formatter = logging.Formatter(
                "[%(asctime)s] %(levelname)s - %(message)s", datefmt="%Y-%m-%d %H:%M:%S"
            )
            console_handler.setFormatter(formatter)
            self.logger.addHandler(console_handler)

    def debug(self, message: str) -> None:
        self.logger.debug(message)

    def info(self, message: str) -> None:
        self.logger.info(message)

    def warning(self, message: str) -> None:
        self.logger.warning(message)

    def error(self, message: str) -> None:
        self.logger.error(message)

    def critical(self, message: str) -> None:
        self.logger.critical(message)


class BaseCheckinService(ABC):
    """签到服务抽象基类"""

    def __init__(self, config: VeloeraConfig, logger: Logger):
        self.config = config
        self.logger = logger
        self.default_headers = self._get_default_headers()

    @abstractmethod
    def _get_default_headers(self) -> Dict[str, str]:
        """获取默认请求头"""
        pass

    @abstractmethod
    def _parse_response(self, response: curl_cffi.Response) -> CheckinResult:
        """解析响应数据"""
        pass

    def checkin(self) -> CheckinResult:
        """执行签到操作"""
        self.logger.info("🚀 开始执行签到操作...")

        for attempt in range(1, self.config.retry_count + 1):
            try:
                self.logger.debug(f"第 {attempt} 次尝试签到")

                response = curl_cffi.post(
                    self.config.checkin_url,
                    timeout=self.config.timeout,
                    headers=self.default_headers,
                    impersonate="firefox",
                )

                result = self._parse_response(response)

                if result.status == CheckinStatus.SUCCESS:
                    self.logger.info(f"✅ {result.message}")
                    return result
                elif result.status == CheckinStatus.ALREADY_CHECKED:
                    self.logger.info(f"ℹ️ {result.message}")
                    return result
                elif result.status == CheckinStatus.UNAUTHORIZED:
                    self.logger.error(f"🔒 认证失败: {result.message}")
                    return result  # 认证失败不需要重试
                else:
                    self.logger.warning(f"⚠️ 第 {attempt} 次尝试失败: {result.message}")

                    if attempt < self.config.retry_count:
                        import time

                        time.sleep(self.config.retry_delay)

            except curl_cffi.RequestsError as e:  # curl_cffi 的所有异常都在这里
                self.logger.error(f"❌ 第 {attempt} 次尝试网络异常: {e}")
            except Exception as e:
                self.logger.error(f"❌ 第 {attempt} 次尝试未知错误: {e}")

        return CheckinResult(
            status=CheckinStatus.FAILED,
            message="所有重试尝试均失败",
            error_code="MAX_RETRY_EXCEEDED",
        )


class VeloeraCheckinService(BaseCheckinService):
    """Veloera 签到服务实现"""

    def _is_already_checked_message(self, message: str) -> bool:
        """检查消息是否表示已经签到过"""
        already_checked_keywords = [
            "已经签到",
            "已签到",
            "重复签到",
            "今天已经签到过了",
            "already checked",
            "already signed",
        ]
        message_lower = message.lower()
        return any(keyword in message_lower for keyword in already_checked_keywords)

    def _get_default_headers(self) -> Dict[str, str]:
        """获取 Veloera 平台默认请求头"""
        return {
            "Authorization": f"Bearer {self.config.access_token}",
            "Veloera-User": self.config.user_id,
            "Origin": self.config.base_url,
            "Referer": f"{self.config.base_url}/personal",
        }

    def _parse_response(self, response: curl_cffi.Response) -> CheckinResult:
        """解析 Veloera 平台响应"""
        try:
            if response.status_code == 200:
                data = response.json()

                if data.get("success"):
                    quota = data.get("data", {}).get("quota", 0)
                    message = data.get("message", "签到成功")

                    # 格式化配额显示
                    formatted_message = f"{message} - 当前配额: {quota:.2f}"

                    return CheckinResult(
                        status=CheckinStatus.SUCCESS,
                        message=formatted_message,
                        data={"quota": quota},
                    )
                else:
                    error_msg = data.get("message", "签到失败")

                    # 检查是否为已签到的情况
                    if self._is_already_checked_message(error_msg):
                        return CheckinResult(
                            status=CheckinStatus.ALREADY_CHECKED,
                            message=error_msg,
                            error_code="ALREADY_CHECKED",
                        )

                    return CheckinResult(
                        status=CheckinStatus.FAILED,
                        message=error_msg,
                        error_code=data.get("code"),
                    )

            elif response.status_code == 401:
                return CheckinResult(
                    status=CheckinStatus.UNAUTHORIZED,
                    message="认证失败，请检查访问令牌和用户ID",
                    error_code="UNAUTHORIZED",
                )

            else:
                return CheckinResult(
                    status=CheckinStatus.FAILED,
                    message=f"HTTP错误 {response.status_code}: {response.text}",
                    error_code=f"HTTP_{response.status_code}",
                )

        except json.JSONDecodeError as e:
            return CheckinResult(
                status=CheckinStatus.FAILED,
                message=f"响应JSON解析失败: {e}",
                error_code="JSON_DECODE_ERROR",
            )
        except Exception as e:
            return CheckinResult(
                status=CheckinStatus.FAILED,
                message=f"响应解析异常: {e}",
                error_code="PARSE_ERROR",
            )


class ConfigManager:
    """配置管理器"""

    @staticmethod
    def load_from_file(config_path: str) -> List[VeloeraConfig]:
        """从配置文件加载多个配置"""
        with open(config_path, encoding="utf-8") as f:
            data = json.load(f)

        configs = []
        for item in data.get("accounts", []):
            configs.append(VeloeraConfig(**item))

        return configs


class VeloeraCheckinManager:
    """Veloera 签到管理器"""

    def __init__(self, logger: Optional[Logger] = None):
        self.logger = logger or Logger()
        self.configs: List[VeloeraConfig] = []  # 存储配置以便后续使用

    def run_single_checkin(self, config: VeloeraConfig) -> CheckinResult:
        """执行单个账号签到"""
        service = VeloeraCheckinService(config, self.logger)
        return service.checkin()

    def run_batch_checkin(self, configs: List[VeloeraConfig]) -> List[CheckinResult]:
        """执行批量账号签到"""
        self.configs = configs  # 保存配置以便后续使用
        results = []

        self.logger.info(f"开始批量签到，共 {len(configs)} 个账号")

        for i, config in enumerate(configs, 1):
            self.logger.info(f"正在处理第 {i} 个账号 (用户ID: {config.user_id})")
            result = self.run_single_checkin(config)
            results.append(result)

            # 账号间延迟
            if i < len(configs):
                import time

                time.sleep(2)

        return results


def main():
    logger = Logger()
    manager = VeloeraCheckinManager(logger)

    try:
        # 从命令行参数获取配置文件路径
        config_file = sys.argv[1]
        configs = ConfigManager.load_from_file(config_file)
        results = manager.run_batch_checkin(configs)

        # 检查是否有真正失败的签到（排除已签到的情况）
        failed_count = sum(
            1
            for r in results
            if r.status not in [CheckinStatus.SUCCESS, CheckinStatus.ALREADY_CHECKED]
        )

        if failed_count > 0:
            exit(1)

    except Exception as e:
        logger.critical(f"程序执行异常: {e}")
        exit(1)

    logger.info("=" * 60)


if __name__ == "__main__":
    main()
