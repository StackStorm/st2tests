from __future__ import absolute_import

import os
import re
import time
import unittest2
import sys

from slackclient import SlackClient


WAIT_FOR_MESSAGES_TIMEOUT = os.environ.get('SLACK_WAIT_FOR_MESSAGES_TIMEOUT', 120)

DONT_WAIT_FOR_MESSAGES_TIMEOUT = os.environ.get('SLACK_DONT_WAIT_FOR_MESSAGES_TIMEOUT', 10)

ATTACHMENT_REGEX_1 = re.compile(r'.*`[0-9a-f]{24}` for `[^`]+`:.*')
ATTACHMENT_REGEX_2 = re.compile(r'.*(?:running|succeeded|failed),.*')
ATTACHMENT_REGEX_3 = re.compile(r'.*(?:started|finished) at \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.')


def ignore_username(username):
    # Remove 'user_typing' messages, since they are almost certainly
    # caused by a human typing in the channel. Otherwise, the number of
    # messages can be erroneously inflated.
    def filter_messages(message):
        if message['type'] == 'user_typing':
            return False
        elif message['type'] == 'hello':
            return False
        elif message.get('username') == username:
            return False
        else:
            return True
    return filter_messages


class SlackEndToEndTestCase(unittest2.TestCase):
    @classmethod
    def setUpClass(cls):
        # This token is for the bot that impersonates a user
        cls.client = SlackClient(os.environ['SLACK_USER_API_TOKEN'])
        cls.username = os.environ['SLACK_USER_USERNAME']

        cls.filter = staticmethod(ignore_username(cls.username))

        cls.maxDiff = 10000



    def test_non_response(self):
        # Connect as the bot
        self.client.rtm_connect()

        # Drain the event buffer
        self.client.rtm_read()

        post_message_response = self.client.api_call(
            "chat.postMessage",
            channel='local_chatops_ci',
            text="This message should not prompt a response from the bot",
            icon_emoji=':gem:',
            username=self.username)

        messages = []
        for i in range(DONT_WAIT_FOR_MESSAGES_TIMEOUT):
            if len(messages) >= 2:
                break
            time.sleep(1)

            all_messages = self.client.rtm_read()

            filtered_messages = filter(self.filter, all_messages)

            if filtered_messages:
                messages.extend(filtered_messages)

        self.assertListEqual(messages, [])

    def test_chatops_list_executions(self):
        # Connect as the bot
        self.client.rtm_connect()

        # Drain the event buffer
        self.client.rtm_read()

        post_message_response = self.client.api_call(
            "chat.postMessage",
            channel='local_chatops_ci',
            text="!st2 list executions",
            icon_emoji=':gem:',
            username=self.username)

        time.sleep(10)

        messages = []
        for i in range(WAIT_FOR_MESSAGES_TIMEOUT):
            if len(messages) >= 2:
                break
            time.sleep(1)

            all_messages = self.client.rtm_read()

            filtered_messages = filter(self.filter, all_messages)

            if filtered_messages:
                messages.extend(filtered_messages)

        self.assertEqual(2, len(messages))
        self.assertIn("details available at", messages[0]['text'])
        self.assertIsNotNone(messages[1].get('attachments'))
        self.assertGreaterEqual(len(messages[1]['attachments']), 1)
        self.assertIsNotNone(messages[1]['attachments'][0].get('text'))
        self.assertRegex(messages[1]['attachments'][0]['text'], ATTACHMENT_REGEX_1)
        self.assertRegex(messages[1]['attachments'][0]['text'], ATTACHMENT_REGEX_2)
        self.assertRegex(messages[1]['attachments'][0]['text'], ATTACHMENT_REGEX_3)

        time.sleep(10)

        # Drain the event buffer
        self.client.rtm_read()


try:
    from st2common.runners.base_action import Action

    class SlackEndToEndTestCase(Action):
        def run(self):
            return unittest2.main(exit=False)

except ImportError:
    pass


if __name__ == '__main__':
    unittest2.main()
