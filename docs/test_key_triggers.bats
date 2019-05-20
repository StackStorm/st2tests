
load '../test_helpers/bats-support/load'
load '../test_helpers/bats-assert/load'



ROBOT_KEY="robot_key"
ROBOT_VALUE="robot_value"
ROBOT_NEW_VALUE="robot_new_value"

TRIGGER_KEY_CREATE="core.st2.key_value_pair.create"
TRIGGER_KEY_UPDATE="core.st2.key_value_pair.update"
TRIGGER_KEY_CHANGE="core.st2.key_value_pair.value_change"
TRIGGER_KEY_DELETE="core.st2.key_value_pair.delete"

KEY_JSON_FILE="docs/test_key_triggers.json"



@test "key-value triggers exist" {
	run eval "st2 trigger list -p core -a ref -j | jq -r '.[].ref'"
	assert_success

	assert_output --partial "$TRIGGER_KEY_CREATE"
	assert_output --partial "$TRIGGER_KEY_UPDATE"
	assert_output --partial "$TRIGGER_KEY_CHANGE"
	assert_output --partial "$TRIGGER_KEY_DELETE"
}

@test "create key-value works" {
	KEY_SET_RESULTS=$(st2 key set "$ROBOT_KEY" "$ROBOT_VALUE" -j)
	run eval "echo '$KEY_SET_RESULTS' | jq -r '.name'"
	assert_success

	assert_output "$ROBOT_KEY"

	run eval "echo '$KEY_SET_RESULTS' | jq -r '.value'"
	assert_success

	assert_output "$ROBOT_VALUE"

	KEY_CREATE_RESULTS=$(st2 trigger-instance list --trigger=$TRIGGER_KEY_CREATE -n 1 -j)

	run eval "echo '$KEY_CREATE_RESULTS' | jq -r '.[].trigger'"
	assert_success

	assert_output "$TRIGGER_KEY_CREATE"

	TRIGGER_ID=$(echo "$KEY_CREATE_RESULTS" | jq -r '.[].id')

	TRIGGER_GET_RESULTS=$(st2 trigger-instance get $TRIGGER_ID -j)
	run eval "echo '$TRIGGER_GET_RESULTS' | jq -r '.payload.object.name'"
	assert_success

	assert_output "$ROBOT_KEY"

	run eval "echo '$TRIGGER_GET_RESULTS' | jq -r '.payload.object.value'"
	assert_success

	assert_output "$ROBOT_VALUE"
}

@test "update key-value works" {
	KEY_SET_RESULTS=$(st2 key set "$ROBOT_KEY" "$ROBOT_VALUE" -j)
	run eval "echo '$KEY_SET_RESULTS' | jq -r '.name'"
	assert_success

	assert_output "$ROBOT_KEY"

	run eval "echo '$KEY_SET_RESULTS' | jq -r '.value'"
	assert_success

	assert_output "$ROBOT_VALUE"

	KEY_UPDATE_RESULTS=$(st2 trigger-instance list --trigger=$TRIGGER_KEY_UPDATE -n 1 -j)
	run eval "echo '$KEY_UPDATE_RESULTS' | jq -r '.[].trigger'"
	assert_success

	assert_output "$TRIGGER_KEY_UPDATE"

	TRIGGER_ID=$(echo "$KEY_UPDATE_RESULTS" | jq -r '.[].id')

	TRIGGER_GET_RESULTS=$(st2 trigger-instance get $TRIGGER_ID -j)
	run eval "echo '$TRIGGER_GET_RESULTS' | jq -r '.payload.object.name'"
	assert_success

	assert_output "$ROBOT_KEY"

	run eval "echo '$TRIGGER_GET_RESULTS' | jq -r '.payload.object.value'"
	assert_success

	assert_output "$ROBOT_VALUE"
}

@test "key-value value change works" {
	KEY_SET_RESULTS=$(st2 key set "$ROBOT_KEY" "$ROBOT_NEW_VALUE" -j)
	run eval "echo '$KEY_SET_RESULTS' | jq -r '.name'"
	assert_success

	assert_output "$ROBOT_KEY"

	run eval "echo '$KEY_SET_RESULTS' | jq -r '.value'"
	assert_success

	assert_output "$ROBOT_NEW_VALUE"

	KEY_CHANGE_RESULTS=$(st2 trigger-instance list --trigger=$TRIGGER_KEY_CHANGE -n 1 -j)
	run eval "echo '$KEY_CHANGE_RESULTS' | jq -r '.[].trigger'"
	assert_success

	assert_output "$TRIGGER_KEY_CHANGE"

	TRIGGER_ID=$(echo "$KEY_CHANGE_RESULTS" | jq -r '.[].id')

	TRIGGER_GET_RESULTS=$(st2 trigger-instance get $TRIGGER_ID -j)
	run eval "echo '$TRIGGER_GET_RESULTS' | jq -r '.payload.old_object.name'"
	assert_success

	assert_output "$ROBOT_KEY"

	run eval "echo '$TRIGGER_GET_RESULTS' | jq -r '.payload.new_object.name'"
	assert_success

	assert_output "$ROBOT_KEY"

	run eval "echo '$TRIGGER_GET_RESULTS' | jq -r '.payload.old_object.value'"
	assert_success

	assert_output "$ROBOT_VALUE"

	run eval "echo '$TRIGGER_GET_RESULTS' | jq -r '.payload.new_object.value'"
	assert_success

	assert_output "$ROBOT_NEW_VALUE"
}

@test "delete key-value key" {
	run eval "st2 key delete \"$ROBOT_KEY\""
	assert_success

	assert_output "Resource with id \"$ROBOT_KEY\" has been successfully deleted."

	KEY_DELETE_RESULTS=$(st2 trigger-instance list --trigger=$TRIGGER_KEY_DELETE -n 1 -j)
	run eval "echo '$KEY_DELETE_RESULTS' | jq -r '.[].trigger'"
	assert_success

	assert_output "$TRIGGER_KEY_DELETE"

	TRIGGER_ID=$(echo "$KEY_DELETE_RESULTS" | jq -r '.[].id')

	TRIGGER_DELETE_RESULTS=$(st2 trigger-instance get $TRIGGER_ID -j)
	run eval "echo '$TRIGGER_DELETE_RESULTS' | jq -r '.payload.object.name'"
	assert_success

	assert_output "$ROBOT_KEY"

	run eval "echo '$TRIGGER_DELETE_RESULTS' | jq -r '.payload.object.value'"
	assert_success

	assert_output "$ROBOT_NEW_VALUE"
}

@test "load key values from JSON file" {
	KEY_LOAD_RESULTS=$(st2 key load $KEY_JSON_FILE -j)
	run eval "echo '$KEY_LOAD_RESULTS' | jq -r '.[] | select(.name == \"robot1\") | .value'"
	assert_success

	assert_output --partial "key1"
	assert_output --partial "key4"

	run eval "echo '$KEY_LOAD_RESULTS' | jq -r '.[] | select(.name == \"robot2\") | .value'"
	assert_success

	assert_output --partial "key2"
	assert_output --partial "key5"

	run eval "echo '$KEY_LOAD_RESULTS' | jq -r '.[] | select(.name == \"1\") | .value'"
	assert_success

	assert_output "2"
}

# Depends on previous test
@test "list key values in JSON" {
	KEY_LIST_RESULTS=$(st2 key list -j)
	run eval "echo '$KEY_LIST_RESULTS' | jq -r '.[] | select(.name == \"robot1\") | .value'"
	assert_success

	assert_output "key4"
	refute_output "key1"

	run eval "echo '$KEY_LIST_RESULTS' | jq -r '.[] | select(.name == \"robot2\") | .value'"
	assert_success

	assert_output "key5"
	refute_output "key2"

	run eval "echo '$KEY_LIST_RESULTS' | jq -r '.[] | select(.name == \"1\") | .value'"
	assert_success

	assert_output "2"
}

# Depends on previous test
@test "delete keys by prefix" {
	run eval "st2 key delete_by_prefix -p ro"
	assert_success

	assert_output --partial "Deleted 2 keys"
	assert_output --partial "Deleted key ids: robot1, robot2"
}

# Depends on previous test
@test "delete key-value with numeric key" {
	run eval "st2 key delete 1 -j"
	assert_success

	assert_output "Resource with id \"1\" has been successfully deleted."
}

@test "key-value operations with expiries" {
	KEY_EXPIRY_SET_RESULTS=$(st2 key set "$ROBOT_KEY" "$ROBOT_VALUE" -l 1 -j)
	run eval "echo '$KEY_EXPIRY_SET_RESULTS' | jq -r '.expire_timestamp'"
	assert_success

	run eval "echo '$KEY_EXPIRY_SET_RESULTS' | jq -r '.name'"
	assert_success

	assert_output "$ROBOT_KEY"

	run eval "echo '$KEY_EXPIRY_SET_RESULTS' | jq -r '.value'"
	assert_success

	assert_output "$ROBOT_VALUE"

	KEY_GET_RESULTS=$(st2 key get "$ROBOT_KEY" -j)
	run eval "echo '$KEY_GET_RESULTS' | jq -r '.name'"
	assert_success

	assert_output "$ROBOT_KEY"

	run eval "echo '$KEY_GET_RESULTS' | jq -r '.value'"
	assert_success

	assert_output "$ROBOT_VALUE"

	# Let the key expire
	# NOTE: We set expire to 1 second, but the way MongoDB garbage collection of expired documents
	# work, item could still be visible for a while after expire has already passed
	# "TTL Monitor is a separate thread that runs periodically (usually every
	# minute) and scans a collection"
	sleep 65

	# Get a list of all keys
	KEY_LIST_RESULTS=$(st2 key list -j)
	run eval "echo '$KEY_LIST_RESULTS' jq -r '.name'"
	assert_success

	refute_output "$ROBOT_KEY"

	run eval "echo '$KEY_LIST_RESULTS' jq -r '.value'"
	assert_success

	refute_output "$ROBOT_VALUE"
}
