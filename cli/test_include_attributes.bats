
load '../test_helpers/bats-support/load'
load '../test_helpers/bats-assert/load'



@test "st2 execution list include attributes works" {
	run st2 execution list --attr id
	assert_success
	assert_output --partial "id"
	refute_output --partial "status"
	refute_output --partial "context"
	refute_output --partial "start_timestamp"
	refute_output --partial "end_timestamp"
	refute_output --partial "action.ref"
}

@test "st2 execution list include nonexistent attribute errors" {
	run st2 execution list --attr doesntexist
	assert_failure
	assert_output --partial "Invalid or unsupported include attribute specified"
}

@test "st2 action list include attributes works" {
	run st2 action list --attr name
	assert_success
	assert_output --partial "| name"
	assert_output --partial "name"
	refute_output --partial "| pack"
	refute_output --partial "| description"
	refute_output --partial "description"
}

@test "st2 action list include nonexistent attribute errors" {
	run st2 action list --attr doesntexist
	assert_failure
	assert_output --partial "Invalid or unsupported include attribute specified"
}
