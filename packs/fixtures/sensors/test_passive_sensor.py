# Requirements:
# See ../requirements.txt
# import datetime

import json

from flask import Flask

from st2reactor.sensor.base import Sensor

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


class TestPassiveSensor(Sensor):
    def __init__(self, sensor_service, config=None):
        super(TestPassiveSensor, self).__init__(sensor_service=sensor_service,
                                                config=config)
        self._trigger_pack = 'fixtures'
        self._trigger_ref = '.'.join([self._trigger_pack, 'test_passive_trigger.dummy'])
        self.host = self._config['host']
        self.port = self._config['port']
        self.app = Flask(__name__)

    def setup(self):
        @self.app.route('/webhooks/<path:endpoint>', methods=['POST', 'GET'])
        def handle_ep(endpoint):
            if endpoint == 'passivesensor/test':
                return self._handle_webhook(endpoint)
            else:
                raise Exception('Unhandled endpoint: %s', endpoint)

    def run(self):
        # Stopped
        self.app.run(host=self.host, port=self.port, threaded=False)

    def cleanup(self):
        pass

    def add_trigger(self, trigger):
        pass

    def update_trigger(self, trigger):
        pass

    def remove_trigger(self, trigger):
        pass

    def _handle_webhook(self, endpoint):
        self._dispatch_trigger(self._trigger_ref, SAMPLE_PAYLOAD)
        return json.dumps(SAMPLE_PAYLOAD)

    def _dispatch_trigger(self, trigger, data):
        # data['timestamp'] = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S.%fZ')
        self._sensor_service.dispatch(trigger, data)
