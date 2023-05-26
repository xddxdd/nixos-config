import os
from request import http
from loghelper import log

# 请自行到人人打码官网注册并充值后获取appkey填写到下面
appkey = ""
if os.getenv("AutoMihoyoBBS_appkey") is not None:
    appkey = os.getenv("AutoMihoyoBBS_appkey")


def game_captcha(gt: str, challenge: str):
    validate = geetest(gt, challenge, 'https://passport-api.mihoyo.com/account/ma-cn-passport/app/loginByPassword')
    return validate  # 失败返回None 成功返回validate


def bbs_captcha(gt: str, challenge: str):
    validate = geetest(gt, challenge,
                       "https://webstatic.mihoyo.com/bbs/event/signin-ys/index.html?bbs_auth_required=true&act_id"
                       "=e202009291139501&utm_source=bbs&utm_medium=mys&utm_campaign=icon")
    return validate  # 失败返回None 成功返回validate


def geetest(gt: str, challenge: str, referer: str):
    if not query_score():
        return None

    response = http.post('http://api.rrocr.com/api/recognize.html', params={
        'appkey': appkey,
        'gt': gt,
        'challenge': challenge,
        'referer': referer,
        'sharecode': '585dee4d4ef94e1cb95d5362a158ea54'
    }, timeout=60)
    data = response.json()
    if data['status'] != 0:
        log.error(data['msg'])  # 打码失败输出错误信息
        return None
    return data['data']['validate']  # 失败返回None 成功返回validate


def query_score():
    response = http.get("http://api.rrocr.com/api/integral.html?appkey=" + appkey)
    data = response.json()
    if data['status'] == -1:
        log.error('查询积分失败')
        return False

    if int(data['integral']) < 10:
        log.warning('积分不足')
        return False
    log.info('积分还剩' + data['integral'])
    return True
