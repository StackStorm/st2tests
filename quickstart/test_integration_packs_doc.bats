
load 'test_helpers/bats-support/load'
load 'test_helpers/bats-assert/load'



@test "packs are not present before a clean install" {
	run st2 action list --pack libcloud --pack consul -j
	assert_success
	refute_output --partial "libcloud"
	refute_output --partial "consul"
}

@test "multiple packs can be installed from repo" {
	run st2 pack install libcloud consul
	assert_success
	refute_output --partial '"status": "failed"'
	refute_output --partial '"status": "timeout"'
	assert_output --partial "For the \"libcloud, consul\" packs, the following content will be registered:"
	assert_output --partial "Installation may take a while for packs with many items."
	assert_output --regexp "rules     \| [[:digit:]]*"
	assert_output --regexp "sensors   \| [[:digit:]]*"
	assert_output --regexp "aliases   \| [[:digit:]]*"
	assert_output --regexp "actions   \| [[:digit:]]*"
	assert_output --regexp "triggers  \| [[:digit:]]*"
}

@test "list actions in libcloud pack" {
	run st2 action list --pack libcloud -j
	assert_success
	assert_output --partial libcloud
}

@test "list actions in consul pack" {
	run st2 action list --pack consul -j
	assert_success
	assert_output --partial consul
}

@test "multiple packs can be removed" {
	run st2 pack remove libcloud consul -j
	assert_success

}

@test "no actions in libcloud pack" {
	run st2 action list --pack libcloud -j
	assert_success
	refute_output --partial '"pack": "libcloud"'
}

@test "no actions in consul pack" {
	run st2 action list --pack consul -j
	assert_success
	refute_output --partial '"pack": "consul"'
}

@test "packs can be downloaded using packs.download" {
	run st2 run packs.download packs=libcloud -j
	assert_success
	assert_output --partial '"status": "succeeded"'
	assert_output --partial '"libcloud": "Success."'
}

@test "can run packs.setup_virtualenv for a pack downloaded in previous step" {
	run st2 run packs.setup_virtualenv packs=libcloud -j
	assert_success
	assert_output --partial "\"result\": \"Successfully set up virtualenv for the following packs: libcloud"
	assert_output --partial '"status": "succeeded"'
}

@test "packs register registers all packs" {
	run st2 pack register -j
	assert_success
	assert_output --partial '"actions":'
	assert_output --partial '"aliases":'
	assert_output --partial '"configs":'
	assert_output --partial '"policies":'
	assert_output --partial '"policy_types":'
	assert_output --partial '"rule_types":'
	assert_output --partial '"rules":'
	assert_output --partial '"runners":'
	assert_output --partial '"sensors":'
	assert_output --partial '"triggers":'
}

@test "pack install with no config" {
	run st2 run packs.download packs=bitcoin -j
	assert_success
	assert_output --partial "\"bitcoin\": \"Success.\""
}

@test "pack reinstall with no config" {
	run st2 run packs.download packs=bitcoin -j
	assert_success
	assert_output --partial "\"bitcoin\": \"Success.\""
}
