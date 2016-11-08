import json

from st2actions.runners.pythonrunner import Action
from st2client.client import Client
from st2client.models import KeyValuePair


__all__ = [
    'DatastoreTestAction'
]


class DatastoreTestAction(Action):

    def run(self):
        self._test_datastore_actions_via_client()
        self._test_datastore_actions_via_action_service()

    def _test_datastore_actions_via_client(self):
        print('Test datastore access via raw client.')
        client = Client(base_url='http://localhost')

        test_name = 'st2tests.putin'
        test_value = 'putout'
        # Put
        kv = KeyValuePair(name=test_name, value=test_value)
        client.keys.update(kv)
        # print('Wrote key: %s value: %s to datastore.' % (test_name, test_value))

        # Get
        val = client.keys.get_by_name(name=test_name)
        if val.value != test_value:
            raise Exception('KeyValue access failed on GET: %s' % test_name)
        # print('Got value: %s from datastore.' % val.value)

        # Delete
        client.keys.delete(val)
        # print('Successfully delete key: %s from datastore.' % test_name)

    def _test_datastore_actions_via_action_service(self):
        print('Test datastore access via action_service')
        data = {'somedata': 'foobar'}
        data_json_str = json.dumps(data)

        # Add a value to the datastore
        self.action_service.set_value(name='cache', value=data_json_str)

        # Retrieve a value
        value = self.action_service.get_value('cache')
        retrieved_data = json.loads(value)
        if 'somedata' not in retrieved_data:
            raise Exception('Retrieved incorrect value from datastore: %s. Expected: %s' %
                            (retrieved_data, data))

        if retrieved_data['somedata'] != 'foobar':
            raise Exception('Datastore value corrupted!!!')

        # Delete a value
        self.action_service.delete_value('cache')

        # Add an encrypted value to the datastore
        self.action_service.set_value(name='cache', value='foo', encrypt=True)

        # decrypted value should match
        value = self.action_service.get_value('cache', decrypt=True)
        if value != 'foo':
            raise Exception('Retrieved incorrect value from datastore: %s. Expected: %s' %
                            (val.value, 'foo'))

        # non-decrypted value should not match
        value = self.action_service.get_value('cache')
        if value == 'foo':
            raise Exception('Retrieved incorrect value from datastore: %s. Did not expect: %s' %
                            (val.value, 'foo'))

        # Delete a value
        self.action_service.delete_value('cache')
