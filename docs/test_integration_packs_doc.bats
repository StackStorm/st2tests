
load '../test_helpers/bats-support/load'
load '../test_helpers/bats-assert/load'



@test "packs are not present before a clean install" {
	run st2 action list --pack libcloud --pack consul
	assert_success
	refute_output --partial "libcloud"
	refute_output --partial "consul"
	refute_output --partial "bitcoin"
}

@test "multiple packs can be installed from repo" {
	run eval "st2 pack install libcloud consul -j | jq -r '.[].name'"
	assert_success

	assert_output --partial "consul"
	assert_output --partial "libcloud"
}

@test "list actions in libcloud pack" {
	run eval "st2 action list --pack libcloud -j | jq '. | length'"
	assert_success

	assert_line --regexp '^[[:digit:]]{1,}$'
	refute_output '0'
}

@test "list actions in consul pack" {
	run eval "st2 action list --pack consul -j | jq '. | length'"
	assert_success

	assert_line --regexp '^[[:digit:]]{1,}$'
	refute_output '0'
}

@test "multiple packs can be removed" {
	run eval "st2 pack remove libcloud consul -j | jq '.[].name'"
	assert_success

	assert_output --partial "consul"
	assert_output --partial "libcloud"
}

@test "no actions in libcloud pack" {
	run st2 action list --pack libcloud -j
	assert_success

	assert_line "No matching items found"
}

@test "no actions in consul pack" {
	run st2 action list --pack consul -j
	assert_success

	assert_line "No matching items found"
}

@test "packs can be downloaded using packs.download" {
	DOWNLOAD_RESULTS=$(st2 run packs.download packs=libcloud -j)
	run eval "echo '$DOWNLOAD_RESULTS' | jq -r '.status'"
	assert_success

	assert_line "succeeded"

	run eval "echo '$DOWNLOAD_RESULTS' | jq -r '.result.result.libcloud'"
	assert_success

	assert_line "Success."
}

@test "can run packs.setup_virtualenv for a pack downloaded in previous step" {
	run eval "st2 run packs.setup_virtualenv packs=libcloud -j | jq -r '.status'"
	assert_success

	assert_line "succeeded"

	run eval "st2 run packs.setup_virtualenv packs=libcloud -j | jq -r '.result.result'"
	assert_success

	assert_line "Successfully set up virtualenv for the following packs: libcloud"
}

@test "packs register registers all packs" {
	REGISTER_RESULTS=$(st2 pack register -j)
	run eval "echo '$REGISTER_RESULTS' | jq -r '.actions'"
	assert_success

	assert_output --regexp '^[[:digit:]]{1,}$'

	run eval "echo '$REGISTER_RESULTS' | jq -r '.aliases'"
	assert_success

	assert_output --regexp '^[[:digit:]]{1,}$'

	run eval "echo '$REGISTER_RESULTS' | jq -r '.configs'"
	assert_success

	assert_output --regexp '^[[:digit:]]{1,}$'

	run eval "echo '$REGISTER_RESULTS' | jq -r '.policies'"
	assert_success

	assert_output --regexp '^[[:digit:]]{1,}$'

	run eval "echo '$REGISTER_RESULTS' | jq -r '.policy_types'"
	assert_success

	assert_output --regexp '^[[:digit:]]{1,}$'

	run eval "echo '$REGISTER_RESULTS' | jq -r '.rule_types'"
	assert_success

	assert_output --regexp '^[[:digit:]]{1,}$'

	run eval "echo '$REGISTER_RESULTS' | jq -r '.rules'"
	assert_success

	assert_output --regexp '^[[:digit:]]{1,}$'

	run eval "echo '$REGISTER_RESULTS' | jq -r '.runners'"
	assert_success

	assert_output --regexp '^[[:digit:]]{1,}$'

	run eval "echo '$REGISTER_RESULTS' | jq -r '.sensors'"
	assert_success

	assert_output --regexp '^[[:digit:]]{1,}$'

	run eval "echo '$REGISTER_RESULTS' | jq -r '.triggers'"
	assert_success

	assert_output --regexp '^[[:digit:]]{1,}$'
}

@test "pack install with no config" {
	run eval "st2 run packs.download packs=bitcoin -j | jq -r '.result.result.bitcoin'"
	assert_success

	assert_line "Success."
}

@test "pack reinstall with no config" {
	run eval "st2 run packs.download packs=bitcoin -j | jq -r '.result.result.bitcoin'"
	assert_success

	assert_line "Success."
}
