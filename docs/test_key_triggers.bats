
load 'test_helpers/bats-support/load'
load 'test_helpers/bats-assert/load'

ROBOT_KEY="robot_key"
ROBOT_VALUE="robot_value"
ROBOT_NEW_VALUE="robot_new_value"

TRIGGER_KEY_CREATE="core.st2.key_value_pair.create"
TRIGGER_KEY_UPDATE="core.st2.key_value_pair.update"
TRIGGER_KEY_CHANGE="core.st2.key_value_pair.value_change"
TRIGGER_KEY_DELETE="core.st2.key_value_pair.delete"

KEY_JSON_FILE="docs/variables/test_key_triggers.json"

@test "key-value triggers exist" {
	run st2 trigger list -p core -a ref -j
	assert_success

	assert_output --partial "core.st2.key_value_pair.create"
	assert_output --partial "core.st2.key_value_pair.update"
	assert_output --partial "core.st2.key_value_pair.value_change"
	assert_output --partial "core.st2.key_value_pair.delete"
}

@test "create key-value works" {
	run eval "st2 key set \"$ROBOT_KEY\" \"$ROBOT_VALUE\" -j"
	assert_success

	assert_output --partial "\"name\": \"$ROBOT_KEY\""
	assert_output --partial "\"value\": \"$ROBOT_VALUE\""

	run eval "st2 trigger-instance list --trigger=$TRIGGER_KEY_CREATE -n 1 -j"
	assert_success

	assert_output --partial "\"trigger\": \"$TRIGGER_KEY_CREATE\""

	run eval "st2 trigger-instance list --trigger=$TRIGGER_KEY_CREATE -n 1 -a id -j"
	assert_success
	TRIGGER_ID=$(echo "$output" | head -n 3 | tail -n 1 | awk '{ print $2 }' | tr -d ' "')

	run eval "st2 trigger-instance get $TRIGGER_ID -j"
	assert_success

	assert_output --partial "\"name\": \"$ROBOT_KEY\""
	assert_output --partial "\"value\": \"$ROBOT_VALUE\""
}

@test "update key-value works" {
	run eval "st2 key set \"$ROBOT_KEY\" \"$ROBOT_VALUE\" -j"
	assert_success

	assert_output --partial "\"name\": \"$ROBOT_KEY\""
	assert_output --partial "\"value\": \"$ROBOT_VALUE\""

	run eval "st2 trigger-instance list --trigger=$TRIGGER_KEY_UPDATE -n 1 -j"
	assert_success

	assert_output --partial "\"trigger\": \"$TRIGGER_KEY_UPDATE\""

	run eval "st2 trigger-instance list --trigger=$TRIGGER_KEY_UPDATE -n 1 -a id -j"
	assert_success
	TRIGGER_ID=$(echo "$output" | head -n 3 | tail -n 1 | awk '{ print $2 }' | tr -d ' "')

	run eval "st2 trigger-instance get $TRIGGER_ID -j"
	assert_success

	assert_output --partial "\"name\": \"$ROBOT_KEY\""
	assert_output --partial "\"value\": \"$ROBOT_VALUE\""
}

@test "key-value value change works" {
	run eval "st2 key set \"$ROBOT_KEY\" \"$ROBOT_NEW_VALUE\" -j"
	assert_success

	assert_output --partial "\"name\": \"$ROBOT_KEY\""
	assert_output --partial "\"value\": \"$ROBOT_NEW_VALUE\""

	run eval "st2 trigger-instance list --trigger=$TRIGGER_KEY_CHANGE -n 1 -j"
	assert_success

	assert_output --partial "\"trigger\": \"$TRIGGER_KEY_CHANGE\""

	run eval "st2 trigger-instance list --trigger=$TRIGGER_KEY_CHANGE -n 1 -a id -j"
	assert_success
	TRIGGER_ID=$(echo "$output" | head -n 3 | tail -n 1 | awk '{ print $2 }' | tr -d ' "')

	run eval "st2 trigger-instance get $TRIGGER_ID -j"
	assert_success

	assert_output --partial "\"name\": \"$ROBOT_KEY\""
	assert_output --partial "\"value\": \"$ROBOT_NEW_VALUE\""
}

@test "delete key-value key" {
	run eval "st2 key delete \"$ROBOT_KEY\""
	assert_success

	assert_output --partial "Resource with id \"$ROBOT_KEY\" has been successfully deleted."

	run eval "st2 trigger-instance list --trigger=$TRIGGER_KEY_DELETE -n 1 -j"
	assert_success

	assert_output --partial "\"trigger\": \"$TRIGGER_KEY_DELETE\""

	run eval "st2 trigger-instance list --trigger=$TRIGGER_KEY_DELETE -n 1 -a id -j"
	assert_success
	TRIGGER_ID=$(echo "$output" | head -n 3 | tail -n 1 | awk '{ print $2 }' | tr -d ' "')

	run eval "st2 trigger-instance get $TRIGGER_ID -j"
	assert_success

	assert_output --partial "\"name\": \"$ROBOT_KEY\""
	assert_output --partial "\"value\": \"$ROBOT_NEW_VALUE\""
}

@test "load key values from JSON file" {
	run eval "st2 key load $KEY_JSON_FILE -j"
	assert_success

	assert_output --partial "key5"
	assert_output --partial "key4"
	assert_output --partial "2"
}

# Depends on previous test
@test "list key values in JSON" {
	run eval "st2 key list -j"
	assert_success

	assert_equal $(echo $output | jq -r '.[] | select(.value == "key5") | .name') "robot2"
	assert_equal $(echo $output | jq -r '.[] | select(.value == "key4") | .name') "robot1"
	assert_equal $(echo $output | jq -r '.[] | select(.value == "2") | .name') "1"
	refute_output --partial "key1"
	refute_output --partial "key2"
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

	assert_output --partial "Resource with id \"1\" has been successfully deleted."
}

@test "key-value operations with expiries" {
	run eval st2 key set "$ROBOT_KEY" "$ROBO_VALUE"
}
