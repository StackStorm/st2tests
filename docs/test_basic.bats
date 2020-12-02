
load '../test_helpers/bats-support/load'
load '../test_helpers/bats-assert/load'



@test "st2 version works" {
	run st2 --version
	assert_success

	assert_line --regexp "^st2 "
	assert_line --partial "on Python"
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

	assert_line --regexp "^usage:"
	assert_output --partial "CLI for StackStorm event-driven automation platform."
	assert_output --partial "Enable debug mode"
}

@test "action list for core.local and core.remote action" {
	run eval "st2 action list -j --pack=core | jq -r '.[].ref'"
	assert_success

	assert_output --partial "core.announcement"
	assert_output --partial "core.ask"
	assert_output --partial "core.echo"
	assert_output --partial "core.http"
	assert_output --partial "core.inject_trigger"
	assert_output --partial "core.local"
	assert_output --partial "core.local_sudo"
	assert_output --partial "core.noop"
	assert_output --partial "core.pause"
	assert_output --partial "core.remote"
	assert_output --partial "core.remote_sudo"
	assert_output --partial "core.sendmail"
	assert_output --partial "core.uuid"
	assert_output --partial "core.winrm_cmd"
	assert_output --partial "core.winrm_ps_cmd"
}

@test "action get core.http works" {
	run eval "st2 action get -j core.http | jq -r '.ref'"
	assert_success

	assert_line "core.http"

	run eval "st2 action get -j core.http | jq -r '.parameters.method.enum | .[]'"
	assert_success

	assert_output --partial "HEAD"
	assert_output --partial "GET"
	assert_output --partial "POST"
	assert_output --partial "PUT"
	assert_output --partial "DELETE"
	assert_output --partial "OPTIONS"
	assert_output --partial "TRACE"
	assert_output --partial "PATCH"
	assert_output --partial "PURGE"
}

@test "execution list includes the core.local 'date' that was just run" {
	run eval "st2 run -j core.local -- date -R | jq -r '.status'"
	assert_success

	assert_line "succeeded"

	run eval "st2 run -j core.local -- date -R | jq -r '.parameters.cmd'"
	assert_success
	assert_line "date -R"

	run eval "st2 execution list -n 1 -j | jq -r '.[].action.ref'"
	assert_success
	assert_line "core.local"

	run eval "st2 execution list -n 1 -j | jq -r '.[].status'"
	assert_success
	assert_line "succeeded"
}

@test "sensor list works" {
	run eval "st2 sensor list -j | jq -r '.[].pack'"
	assert_success

	assert_output --partial "linux"
}

@test "trigger list works" {
	run eval "st2 trigger list -j -a=all | jq -r '.[].pack = \"core\" | length'"
	assert_success

	assert_line --regexp "[[:digit:]]{1,}"
}

@test "trigger get works" {
	TRIGGER_ID=$(st2 trigger list -j -a=all | jq -r '.[4].id')
	run eval "st2 trigger get -j $TRIGGER_ID | jq -r '.id'"
	assert_success

	assert_line "$TRIGGER_ID"
}

@test "core.remote action works" {
	run eval "st2 run -j core.remote hosts=\"localhost\" -- uname -a | jq -r '.parameters.cmd'"
	assert_success

	assert_line "uname -a"

	run eval "st2 run -j core.remote hosts=\"localhost\" -- uname -a | jq -r '.parameters.hosts'"
	assert_success

	assert_line "localhost"
}
