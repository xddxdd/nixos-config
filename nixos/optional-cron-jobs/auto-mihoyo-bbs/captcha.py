import os
import time

from loghelper import log
from request import http

appkey = ""
if os.getenv("AutoMihoyoBBS_appkey") is not None:
    appkey = os.getenv("AutoMihoyoBBS_appkey")


def game_captcha(gt: str, challenge: str):
    validate = geetest(
        gt,
        challenge,
        "https://passport-api.mihoyo.com/account/ma-cn-passport/app/loginByPassword",
    )
    return validate  # 失败返回None 成功返回validate


def bbs_captcha(gt: str, challenge: str):
    validate = geetest(
        gt,
        challenge,
        "https://webstatic.mihoyo.com/bbs/event/signin-ys/index.html?bbs_auth_required=true&act_id"
        "=e202009291139501&utm_source=bbs&utm_medium=mys&utm_campaign=icon",
    )
    return validate  # 失败返回None 成功返回validate


def geetest(gt: str, challenge: str, referer: str):
    try:
        log.info("查询打码余额")
        response = http.post(
            "http://2captcha.com/res.php",
            params={
                "key": appkey,
                "action": "getbalance",
                "json": 1,
            },
            timeout=60,
        )
        data = response.json()
        if data.get("status", 0) == 0:
            log.error(f"查询打码余额出错 {response.text}")
            return None
        log.info(f"打码余额 {data['request']}")

        log.info("提交打码任务")
        response = http.post(
            "http://2captcha.com/in.php",
            params={
                "method": "geetest",
                "key": appkey,
                "gt": gt,
                "challenge": challenge,
                "pageurl": referer,
                "json": 1,
                "lang": "zh",
            },
            timeout=60,
        )
        data = response.json()
        if data.get("status", 0) == 0:
            log.error(f"打码出错 {response.text}")
            return None

        req_id = data.get("request")
        log.info(f"打码任务编号 {req_id}，等待")

        time.sleep(10)
        while True:
            time.sleep(5)
            response = http.post(
                "http://2captcha.com/res.php",
                params={
                    "key": appkey,
                    "action": "get",
                    "id": req_id,
                    "json": 1,
                },
                timeout=60,
            )
            data = response.json()

            if data.get("status", 0) == 0:
                if data.get("request") == "CAPCHA_NOT_READY":
                    log.info("打码尚未完成，等待")
                    continue
                log.error(f"打码出错 {response.text}")
                return None

            validate = data["request"]["geetest_validate"]
            log.info("打码成功")
            return validate
    except Exception as e:
        log.error(f"打码出错 {repr(e)}")
        return None
