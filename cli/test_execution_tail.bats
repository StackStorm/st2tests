load '../test_helpers/bats-support/load'
load '../test_helpers/bats-assert/load'

# Hack: BATS executes tests sequentially in the order they are defined in the
#       .bats file. We really only need to do this once (before the first
#       actual test), so instead of doing all of this in the setup() function,
#       we just throw it into a SETUP test.
@test "SETUP: reinstall the examples pack" {
	sudo cp -r /usr/share/doc/st2/examples/ /opt/stackstorm/packs/
	[[ "$?" -eq 0 ]]
	[[ -d /opt/stackstorm/packs/examples ]]

	st2 run packs.setup_virtualenv packs=examples -j | grep -q "$STATUS_SUCCESS"
	[[ "$?" -eq 0 ]]

	st2-register-content --register-pack /opt/stackstorm/packs/examples/ --register-all
	[[ "$?" -eq 0 ]]
}

@test "st2 execution tail works correctly for simple actions" {
	# Run the run + execution tail command - this may take awhile
	run eval "st2 run examples.python_runner_print_to_stdout_and_stderr count=5 sleep_delay=1 --tail"

	assert_success
	assert_output --partial "stderr -> Line: 3"
	assert_output --partial "stdout -> Line: 4"
	assert_output --partial "stderr -> Line: 5"
}

@test "st2 execution tail works correctly for action chain workflows" {
	# Run the run + execution tail command - this may take awhile
	run eval "st2 run examples.action_chain_streaming_demo count=2 sleep_delay=0.2 --tail"

	assert_success
	assert_output --regexp "Child execution \\(task=task3\\) [0-9a-f]{24} has started\..*"
	assert_output --regexp "Child execution \\(task=task3\\) [0-9a-f]{24} has finished \\(status=succeeded\\)\."
	assert_output --regexp "Child execution \\(task=task10\\) [0-9a-f]{24} has started\..*"
	assert_output --regexp "Child execution \\(task=task10\\) [0-9a-f]{24} has finished \\(status=succeeded\\)\."
	assert_output --regexp "Execution [0-9a-f]{24} has completed \\(status=succeeded\\)."
}

@test "st2 execution tail command works correctly for Mistral workflows" {
	run st2 runner get mistral-v2 > /dev/null
	if [[ "$status" -ne 0 ]]; then
		skip "Mistral not available, skipping tests"
	fi

	# Run the run + execution tail command - this may take awhile
	run eval "st2 run examples.mistral-streaming-demo count=2 sleep_delay=0.2 --tail"

	assert_success
	assert_output --regexp "Child execution \\(task=task3\\) [0-9a-f]{24} has started\..*"
	assert_output --regexp "Child execution \\(task=task3\\) [0-9a-f]{24} has finished \\(status=succeeded\\)\."
	assert_output --regexp "Child execution \\(task=task10\\) [0-9a-f]{24} has started\..*"
	assert_output --regexp "Child execution \\(task=task10\\) [0-9a-f]{24} has finished \\(status=succeeded\\)\."
	assert_output --regexp "Execution [0-9a-f]{24} has completed \\(status=succeeded\\)."
}

@test "st2 execution tail command works correctly for Orquesta workflows" {
	run st2 runner get orquesta > /dev/null
	if [[ "$status" -ne 0 ]]; then
		skip "Orquesta not available, skipping tests"
	fi

	# Run the run + execution tail command - this may take awhile
	run eval "st2 run examples.orquesta-streaming-demo count=2 sleep_delay=0.2 --tail"

	assert_success
	assert_output --regexp "Child execution \\(task=task3\\) [0-9a-f]{24} has started\..*"
	assert_output --regexp "Child execution \\(task=task3\\) [0-9a-f]{24} has finished \\(status=succeeded\\)\."
	assert_output --regexp "Child execution \\(task=task10\\) [0-9a-f]{24} has started\..*"
	assert_output --regexp "Child execution \\(task=task10\\) [0-9a-f]{24} has finished \\(status=succeeded\\)\."
	assert_output --regexp "Execution [0-9a-f]{24} has completed \\(status=succeeded\\)."
}
