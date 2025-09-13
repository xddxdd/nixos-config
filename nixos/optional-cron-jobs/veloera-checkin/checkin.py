#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 -p python3Packages.curl-cffi
import json
import logging
import os
import sys
from dataclasses import dataclass
from typing import Dict, List
from urllib.parse import urljoin

import curl_cffi

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format="[%(asctime)s] %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)


@dataclass
class FlareSolverrResponse:
    """FlareSolverr 响应数据类"""

    cookies: Dict[str, str]
    userAgent: str


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
    ignore_errors: bool = False

    @property
    def checkin_url(self) -> str:
        """获取完整的签到URL"""
        return urljoin(self.base_url, self.checkin_endpoint)


class FlareSolverrClient:
    """FlareSolverr 客户端"""

    def __init__(self, flaresolverr_url: str, timeout: int = 120):
        self.flaresolverr_url = flaresolverr_url.rstrip("/")
        self.timeout = timeout

    def get_cookies(self, url: str) -> FlareSolverrResponse:
        """通过 FlareSolverr 获取网站 cookies"""
        payload = {
            "cmd": "request.get",
            "url": url,
            "maxTimeout": self.timeout * 1000,  # 转换为毫秒
        }

        response = curl_cffi.post(
            f"{self.flaresolverr_url}/v1",
            json=payload,
            timeout=self.timeout + 10,  # 给额外的超时时间
            headers={"Content-Type": "application/json"},
        )

        if response.status_code != 200:
            raise RuntimeError(f"FlareSolverr HTTP 错误: {response.status_code}")

        data = response.json()

        if data.get("status") != "ok":
            error_msg = data.get("message", "未知错误")
            raise RuntimeError(f"FlareSolverr 请求失败: {error_msg}")

        solution = data.get("solution", {})
        cookies_list = solution.get("cookies", [])

        # 将 cookies 列表转换为字典
        cookies_dict = {}
        for cookie in cookies_list:
            cookies_dict[cookie["name"]] = cookie["value"]

        userAgent = solution.get("userAgent", "")

        logging.info(f"成功获取 {len(cookies_dict)} 个 cookies")

        return FlareSolverrResponse(
            cookies=cookies_dict,
            userAgent=userAgent,
        )


class VeloeraCheckinService:
    """Veloera 签到服务"""

    def __init__(
        self, config: VeloeraConfig, flaresolverr_client: "FlareSolverrClient"
    ):
        self.config = config
        self.flaresolverr_client = flaresolverr_client
        self.default_headers = self._get_default_headers()
        self.cookies = {}

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

    def _get_cookies_via_flaresolverr(self):
        """通过 FlareSolverr 获取 cookies"""
        logging.info(f"正在通过 FlareSolverr 获取 {self.config.base_url} 的 cookies...")

        flare_response = self.flaresolverr_client.get_cookies(self.config.base_url)

        self.cookies = flare_response.cookies
        logging.info(f"成功获取 {len(self.cookies)} 个 cookies")

        # 如果获取到了 User-Agent，更新请求头
        if flare_response.userAgent:
            self.default_headers["User-Agent"] = flare_response.userAgent
            logging.debug(f"更新 User-Agent: {flare_response.userAgent}")

    def _parse_response(self, response: curl_cffi.Response):
        """解析 Veloera 平台响应，成功时不返回结果，失败时抛出异常"""
        if response.status_code == 200:
            data = response.json()

            if data.get("success"):
                quota = data.get("data", {}).get("quota", 0)
                message = data.get("message", "签到成功")
                formatted_message = f"{message} - 当前配额: {quota:.2f}"
                logging.info(f"✅ {formatted_message}")
                return  # 成功时直接返回
            else:
                error_msg = data.get("message", "签到失败")

                # 检查是否为已签到的情况
                if self._is_already_checked_message(error_msg):
                    logging.info(f"ℹ️ {error_msg}")
                    return  # 已签到也视为成功

                raise RuntimeError(f"签到失败: {error_msg}")

        elif response.status_code == 401:
            raise RuntimeError("认证失败，请检查访问令牌和用户ID")

        else:
            raise RuntimeError(f"HTTP错误 {response.status_code}: {response.text}")

    def checkin(self):
        """执行签到操作"""
        logging.info("🚀 开始执行签到操作...")

        # 先通过 FlareSolverr 获取 cookies
        self._get_cookies_via_flaresolverr()

        for attempt in range(1, self.config.retry_count + 1):
            try:
                logging.debug(f"第 {attempt} 次尝试签到")

                response = curl_cffi.post(
                    self.config.checkin_url,
                    timeout=self.config.timeout,
                    headers=self.default_headers,
                    cookies=self.cookies,
                    impersonate="firefox",
                )

                self._parse_response(response)
                return  # 成功时直接返回

            except Exception as e:
                if attempt == self.config.retry_count:
                    # 最后一次尝试失败，抛出异常
                    raise RuntimeError(
                        f"签到失败，已重试 {self.config.retry_count} 次: {e}"
                    )
                else:
                    logging.warning(f"⚠️ 第 {attempt} 次尝试失败: {e}")
                    import time

                    time.sleep(self.config.retry_delay)


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

    def __init__(self):
        self.flaresolverr_client = self._init_flaresolverr()

    def _init_flaresolverr(self) -> FlareSolverrClient:
        """初始化 FlareSolverr 客户端"""
        flaresolverr_url = os.getenv("FLARESOLVERR_URL")

        if not flaresolverr_url:
            logging.error("未配置 FLARESOLVERR_URL 环境变量")
            sys.exit(1)

        logging.info(f"检测到 FlareSolverr 配置: {flaresolverr_url}")
        try:
            client = FlareSolverrClient(flaresolverr_url)
            logging.info("FlareSolverr 客户端初始化成功")
            return client
        except Exception as e:
            logging.error(f"FlareSolverr 客户端初始化失败: {e}")
            sys.exit(1)

    def run_single_checkin(self, config: VeloeraConfig):
        """执行单个账号签到"""
        service = VeloeraCheckinService(config, self.flaresolverr_client)
        service.checkin()

    def run_batch_checkin(self, configs: List[VeloeraConfig]):
        """执行批量账号签到"""
        logging.info(f"开始批量签到，共 {len(configs)} 个账号")
        failed_accounts = []
        ignored_failed_accounts = []

        for i, config in enumerate(configs, 1):
            logging.info(f"正在处理第 {i} 个账号 (用户ID: {config.user_id})")
            try:
                self.run_single_checkin(config)
            except Exception as e:
                if config.ignore_errors:
                    logging.warning(f"账号 {config.user_id} 签到失败但已忽略错误: {e}")
                    ignored_failed_accounts.append(config.user_id)
                else:
                    logging.error(f"账号 {config.user_id} 签到失败: {e}")
                    failed_accounts.append(config.user_id)

            # 账号间延迟
            if i < len(configs):
                import time

                time.sleep(2)

        if ignored_failed_accounts:
            logging.info(
                f"以下账号签到失败但已忽略: {', '.join(ignored_failed_accounts)}"
            )

        if failed_accounts:
            raise RuntimeError(f"以下账号签到失败: {', '.join(failed_accounts)}")


def main():
    manager = VeloeraCheckinManager()

    try:
        # 从命令行参数获取配置文件路径
        config_file = sys.argv[1]
        configs = ConfigManager.load_from_file(config_file)
        manager.run_batch_checkin(configs)
        logging.info("=" * 60)

    except Exception as e:
        logging.critical(f"程序执行异常: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
