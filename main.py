# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "requests==2.32.5",
# ]
# ///

#!/usr/bin/env python3

import os
import requests
import unittest
from unittest.mock import patch


def itsfriday():
    api_url = "https://slack.com/api/chat.postMessage"
    api_token = os.environ.get("SLACK_BOT_TOKEN")
    channelid = os.environ.get("SLACK_CHANNEL_ID")
    auth_header = {"Authorization": "Bearer " + str(api_token)}
    content = {
        "channel": channelid,
        "text": "Happy Friday cunts! https://www.youtube.com/watch?v=1TewCPi92ro",
        "icon_emoji": ":pepe:",
        "username": "Good Vibes Bot",
    }
    requests.post(api_url, headers=auth_header, json=content)


class TestFridayBot(unittest.TestCase):
    @patch("requests.post")
    def test_itsfriday(self, mock_post):
        itsfriday()

        mock_post.assert_called_once()
        args, kwargs = mock_post.call_args

        self.assertEqual(args[0], "https://slack.com/api/chat.postMessage")
        self.assertIn("Bearer", kwargs["headers"]["Authorization"])
        self.assertIn("channel", kwargs["json"])
        self.assertIn("text", kwargs["json"])
        self.assertIn("icon_emoji", kwargs["json"])
        self.assertIn("username", kwargs["json"])


# Start your app
if __name__ == "__main__":
    if os.environ.get("RUN_TESTS") == "true":
        unittest.main()
    else:
        itsfriday()
