
load 'test_helpers/bats-support/load'
load 'test_helpers/bats-assert/load'

setup() {
	if [[ -e /tmp/apikeys.json ]]; then
		rm /tmp/apikeys.json
	fi
}

teardown() {
	if [[ -e /tmp/apikeys.json ]]; then
		rm /tmp/apikeys.json
	fi
}

@test "load command works and is idempotent" {
	run st2 apikey create
	assert_success
	assert_output --partial "key"
	assert_output --partial "created_at"

	run st2 apikey create
	assert_success
	assert_output --partial "key"
	assert_output --partial "created_at"

	# Dump the keys and load them twice - operation should be idempotent and
	# existing keys should be updated
	st2 apikey list -d --show-secrets -j >/tmp/apikeys.json
	assert_success
	[[ -e /tmp/apikeys.json ]]

	run st2 apikey list
	assert_success
	NUM_LINES="${#lines[@]}"

	run st2 apikey load /tmp/apikeys.json
	assert_success

	# Verify count is correct/same after load
	run st2 apikey list
	assert_success
	[[ "${#lines[@]}" -eq "$NUM_LINES" ]]

	run st2 apikey load /tmp/apikeys.json
	assert_success
	[[ "${#lines[@]}" -eq "$NUM_LINES" ]]

	# Verify count is correct/same after load
	run st2 apikey list
	assert_success
	[[ "${#lines[@]}" -eq "$NUM_LINES" ]]
}
