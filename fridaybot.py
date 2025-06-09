# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "requests==2.32.4",
# ]
# ///

#!/usr/bin/env python3

import os
import requests


def itsfriday():
    api_url = "https://slack.com/api/chat.postMessage"
    api_token = os.environ.get("SLACK_BOT_TOKEN")
    channelid = os.environ.get("SLACK_CHANNEL_ID")
    auth_header = {"Authorization": "Bearer " + api_token}
    content = {
        "channel": channelid,
        "text": "Happy Friday cunts! https://www.youtube.com/watch?v=1TewCPi92ro",
        "icon_emoji": ":pepe:",
        "username": "Good Vibes Bot",
    }
    requests.post(api_url, headers=auth_header, json=content)


# Start your app
if __name__ == "__main__":
    itsfriday()
