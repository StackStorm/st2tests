# Requirements:
# See ../requirements.txt
# import datetime

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

    def setup(self):
        pass

    def poll(self):
        # Stopped
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
