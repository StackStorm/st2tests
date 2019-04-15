
load 'test_helpers/bats-support/load'
load 'test_helpers/bats-assert/load'

@test "st2 version works" {
	run st2 --version
	assert_success

	assert_output --regexp "^st2 "
	assert_output --partial "on Python"
}

@test "st2 usage works" {
	run st2
	assert_failure 2

	assert_output --partial "CLI for StackStorm event-driven automation platform."
	assert_output --partial "Enable debug mode"
}

@test "st2 help works" {
	run st2 -h
	assert_success

	assert_output --regexp "^usage:"
	assert_output --partial "CLI for StackStorm event-driven automation platform."
	assert_output --partial "Enable debug mode"
}

@test "action list for core.local and core.remote action" {
	run st2 action list -j --pack=core
	assert_success

	assert_output --partial '"ref": "core.local"'
	assert_output --partial '"ref": "core.remote"'
}

@test "action get core.http works" {
	run st2 action get -j core.http
	assert_success

	assert_output --partial '"ref": "core.http"'
	assert_output --partial '"runner_type": "http-request"'
	assert_output --partial '"uid": "action:core:http"'
}

@test "execution list includes the core.local 'date' that was just run" {
	run st2 run -j core.local -- date -R
	assert_success

	assert_output --partial '"status": "succeeded"'
	assert_output --partial '"cmd": "date -R"'

	run st2 execution list -n 1 -j
	assert_success

	sleep 2

	assert_output --partial '"status": "succeeded"'
	assert_output --partial '"ref": "core.local"'
}

@test "sensor list works" {
	run st2 sensor list -j
	assert_success

	assert_output --partial '"pack": "linux"'
}

@test "trigger list works" {
	run st2 trigger list -j -a=all
	assert_success

	assert_output --partial '"pack": "core"'
}

@test "trigger get works" {
	TRIGGER_ID=$(st2 trigger list -j -a=all | grep '"id": ' | head -n 5 | tail -n 1 | awk '{ print $2 }' | tr -d '",')
	run eval "st2 trigger get -j $TRIGGER_ID"
	assert_success

	assert_output --partial "\"id\": \"$TRIGGER_ID\""
}

@test "core.remote action works" {
	run st2 run -j core.remote hosts="localhost" -- uname -a
	assert_success

	assert_output --partial '"cmd": "uname -a"'
	assert_output --partial '"hosts": "localhost"'
}
