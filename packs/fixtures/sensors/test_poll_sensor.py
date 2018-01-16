# Requirements:
# See ../requirements.txt
# import datetime

# This is to test imports from pack's lib folder to check
# if we messed up PYTHONPATH for sensors.
from common_lib import get_environ  # pylint: disable=import-error

# This is to test imports from action's lib folder to check
# if we messed up PYTHONPATH for actions.
from lib.base import get_uuid_4  # NOQA

from st2reactor.sensor.base import PollingSensor

SAMPLE_PAYLOAD = {
    'str': 'String',
    'int': 1,
    'boo': True,
    'obj': {
        'foo': 'bar',
        'baz': 1
    },
    'lst': [1, 5, 7]
}


class TestPollingSensor(PollingSensor):
    def __init__(self, sensor_service, config=None, poll_interval=5):
        super(TestPollingSensor, self).__init__(sensor_service=sensor_service,
                                                config=config,
                                                poll_interval=poll_interval)
        self._trigger_pack = 'fixtures'
        self._trigger_ref = '.'.join([self._trigger_pack, 'test_trigger.dummy'])
        self.logger = self.sensor_service.get_logger(name=self.__class__.__name__)

    def setup(self):
        pass

    def poll(self):
        self.logger.info('PYTHONPATH: %s', get_environ('PYTHONPATH'))
        self._dispatch_trigger(self._trigger_ref, data=SAMPLE_PAYLOAD)

    def cleanup(self):
        pass

    def add_trigger(self, trigger):
        pass

    def update_trigger(self, trigger):
        pass

    def remove_trigger(self, trigger):
        pass

    def _dispatch_trigger(self, trigger, data):
        # data['timestamp'] = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S.%fZ')
        self._sensor_service.dispatch(trigger, data)
