#!/usr/bin/env python3
# https://gist.github.com/techberet/996ef719c92b6d3406e4e03ba94672cc
import hashlib
import os

import requests

MIFI_IP = os.environ["MIFI_IP"]
MIFI_ADMIN_PASSWORD = os.environ["MIFI_ADMIN_PASSWORD"]
TIMEOUT_S = 2


if __name__ == "__main__":
    session = requests.Session()
    response = session.get(f"http://{MIFI_IP}/login", timeout=TIMEOUT_S)
    # grab the gSecureToken from the output
    response_content = response.content.decode("ascii")
    with open("login_page.txt", "w") as ip_out:
        ip_out.write(response_content)

    # get index
    # doing it the quick and dirty way
    # TODO: switch to regex or something
    gSecureTokenStart = 'name="gSecureToken" id="gSecureToken" value="'
    start_of_secure_token = response_content.index(gSecureTokenStart)
    actual_start = start_of_secure_token + len(gSecureTokenStart)
    actual_end = actual_start + 40
    gSecureToken = response_content[actual_start:actual_end]
    print("gSecureToken =", gSecureToken)

    # cool, now we need to generate the SHA1
    shaPassword = hashlib.sha1(
        MIFI_ADMIN_PASSWORD.encode("ascii") + gSecureToken.encode("ascii")
    ).hexdigest()

    # next let's try and login
    login_data = f"shaPassword={shaPassword}&gSecureToken={gSecureToken}"
    print("Submit Login...")
    login_response = session.post(
        f"http://{MIFI_IP}/submitLogin", data=login_data, timeout=TIMEOUT_S
    )

    print("Grabbing first restart page...")
    first_shutdown_response = session.get(
        f"http://{MIFI_IP}/restarting/", timeout=TIMEOUT_S
    )
    # need to update the gSecureToken...
    new_gSecureToken_start = 'gSecureToken : "'
    assert new_gSecureToken_start in first_shutdown_response.text
    start_of_new_secure_token = first_shutdown_response.text.index(
        new_gSecureToken_start
    ) + len(new_gSecureToken_start)
    new_gSecureToken = first_shutdown_response.text[
        start_of_new_secure_token : start_of_new_secure_token + 40
    ]
    print(f"New gsecure token: {new_gSecureToken}")
    print("Do restart...")
    shutdown_response = session.post(
        f"http://{MIFI_IP}/restarting/reboot/",
        data=f"gSecureToken={new_gSecureToken}",
        timeout=TIMEOUT_S,
    )
    print(shutdown_response.content.decode("ascii"))
