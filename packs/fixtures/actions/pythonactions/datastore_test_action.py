import os
import json

# This is to test imports within actions folder to check
# if we messed up sys.path for actions.
from base import DummyClass  # pylint: disable=no-name-in-module

from st2actions.runners.pythonrunner import Action
from st2client.client import Client
from st2client.models import KeyValuePair


__all__ = [
    'DatastoreTestAction'
]


class DatastoreTestAction(Action):

    def run(self):
        t_cls = DummyClass()
        print('Tests begin: %s' % t_cls.now())
        self._test_datastore_actions_via_client()
        self._test_datastore_actions_via_action_service()
        print('Tests end: %s' % t_cls.now())

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

        # Note: "decrypt" option requires admin access and when we generate service token that
        # token isn't granted admin access so it won't work.
        # To make the tests also pass on st2enteprise with RBAC we use explicit admin token
        admin_token = os.environ.get('ST2_AUTH_TOKEN')

        try:
            # Method was made public in v2.9dev
            self.action_service.datastore_service.get_api_client()
        except AttributeError:
            self.action_service.datastore_service._get_api_client()

        os.environ['ST2_AUTH_TOKEN'] = admin_token

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
        if not value or value != 'foo':
            raise Exception('Retrieved incorrect value from datastore: %s. Expected: %s' %
                            (value, 'foo'))

        # non-decrypted value should not match
        value = self.action_service.get_value('cache')
        if not value or value == 'foo':
            raise Exception('Retrieved incorrect value from datastore: %s. Did not expect: %s' %
                            (value, 'foo'))

        # Delete a value
        self.action_service.delete_value('cache')
