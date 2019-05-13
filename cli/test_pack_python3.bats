load '../test_helpers/bats-support/load'
load '../test_helpers/bats-assert/load'

STATUS_SUCCESS='"status": "succeeded'

setup() {
	# TODO: Not sure if we can call skip from within a setup function...
	#       If this doesn't work, copy the two skips to the top of each test
	#       case and call it good.
	run python3 --version
	if [[ "$status" -ne 0 ]]; then
		skip "Python 3 binary not found, skipping tests"
	fi

	run /opt/stackstorm/st2/bin/python3 --version
	if [[ "$status" -eq 0 ]]; then
		skip "StackStorm components are already running under Python 3, skipping tests"
	fi

	sudo cp -r /usr/share/doc/st2/examples/ /opt/stackstorm/packs/
	[[ "$?" -eq 0 ]]
	[[ -d /opt/stackstorm/packs/examples ]]

	st2 run packs.setup_virtualenv packs=examples -j | grep -q "$STATUS_SUCCESS"
	[[ "$?" -eq 0 ]]

	st2-register-content --register-pack /opt/stackstorm/packs/examples/ --register-all
	[[ "$?" -eq 0 ]]
}

teardown() {
	if [[ -d /opt/stackstorm/packs/examples ]]; then
		st2 run packs.uninstall packs=examples
	fi
	[[ ! -d /opt/stackstorm/packs/examples ]]

	if [[ -d /opt/stackstorm/packs/python3_test ]]; then
		st2 run packs.uninstall packs=python3_test
	fi
	[[ ! -d /opt/stackstorm/packs/python3_test ]]
}

@test "packs.setup_virtualenv without python3 flags works and defaults to Python 2" {
	SETUP_VENV_RESULTS=$(st2 run packs.setup_virtualenv packs=examples -j)
	run eval "echo '$SETUP_VENV_RESULTS' | jq -r '.result.result'"
	assert_success

	assert_output "Successfully set up virtualenv for the following packs: examples"

	run eval "echo '$SETUP_VENV_RESULTS' | jq -r '.status'"
	assert_success

	assert_output "succeeded"

	run /opt/stackstorm/virtualenvs/examples/bin/python --version
	assert_output --partial "Python 2.7"
}

@test "packs.setup_virtualenv with python3 flag works" {
	SETUP_VENV_RESULTS=$(st2 run packs.setup_virtualenv packs=examples python3=true -j)
	run eval "echo '$SETUP_VENV_RESULTS' | jq -r '.result.result'"
	assert_success

	assert_output "Successfully set up virtualenv for the following packs: examples"

	run eval "echo '$SETUP_VENV_RESULTS' | jq -r '.status'"
	assert_success
	assert_output "succeeded"

	run /opt/stackstorm/virtualenvs/examples/bin/python --version
	assert_success

	assert_output --partial "Python 3."

	RESULT=$(st2 run examples.python_runner_print_python_version -j)
	assert_success

	run eval "echo '$RESULT' | jq -r '.result.stdout'"
	assert_success

	assert_output --partial "Using Python executable: /opt/stackstorm/virtualenvs/examples/bin/python"
	assert_output --partial "Using Python version: 3."

	run eval "echo '$RESULT' | jq -r '.status'"
	assert_output "succeeded"

    # Verify PYTHONPATH is correct
	RESULT=$(st2 run examples.python_runner_print_python_environment -j)
	assert_success

	run eval "echo '$RESULT' | jq -r '.result.stdout'"
	assert_success
	assert_output --partial "PYTHONPATH: /usr/lib/python3"
}

@test "python3 imports work correctly" {
	run st2 pack install python3_test --python3 -j
	assert_success

	RESULT=$(st2 run python3_test.test_stdlib_import -j)
	assert_success

	run eval "echo '$RESULT' | jq -r '.result.result'"
	assert_success
	assert_output --partial "imports work correctly"

	run eval "echo '$RESULT' | jq -r '.result.stdout'"
	assert_success
	assert_output --partial "Using Python version: 3."
}
