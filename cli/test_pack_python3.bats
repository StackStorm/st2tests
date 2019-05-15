load '../test_helpers/bats-support/load'
load '../test_helpers/bats-assert/load'

setup() {
	if [[ ! -d /opt/stackstorm/packs/examples ]]; then
		sudo cp -r /usr/share/doc/st2/examples/ /opt/stackstorm/packs/
		[[ "$?" -eq 0 ]]
		[[ -d /opt/stackstorm/packs/examples ]]
	fi

	st2 run packs.setup_virtualenv packs=examples -j
	[[ "$?" -eq 0 ]]

	st2-register-content --register-pack /opt/stackstorm/packs/examples/ --register-actions
	[[ "$?" -eq 0 ]]
}

teardown() {
	if [[ -d /opt/stackstorm/packs/examples ]]; then
		st2 run packs.uninstall packs=examples
	fi

	if [[ -d /opt/stackstorm/packs/python3_test ]]; then
		st2 run packs.uninstall packs=python3_test
	fi
}

skip_tests_if_python3_is_not_available_or_if_already_running_under_python3() {
    # Utility function which skips tests if python3 binary is not available on the system or if
    # StackStorm components are already running under Python 3 (e.g. Ubuntu Xenial)
	run python3 --version
	if [[ "$status" -ne 0 ]]; then
		skip "Python 3 binary not found, skipping tests"
	fi

	run /opt/stackstorm/st2/bin/python3 --version
	if [[ "$status" -eq 0 ]]; then
		skip "StackStorm components are already running under Python 3, skipping tests"
	fi
}

@test "packs.setup_virtualenv without python3 flags works and defaults to Python 2" {
	skip_tests_if_python3_is_not_available_or_if_already_running_under_python3

	SETUP_VENV_RESULTS=$(st2 run packs.setup_virtualenv packs=examples -j)
	run eval "echo '$SETUP_VENV_RESULTS' | jq -r '.result.result'"
	assert_success

	assert_output "Successfully set up virtualenv for the following packs: examples"

	run eval "echo '$SETUP_VENV_RESULTS' | jq -r '.status'"
	assert_success

	assert_output "succeeded"

	run st2-register-content --register-pack /opt/stackstorm/packs/examples/ --register-all
	assert_success

	run /opt/stackstorm/virtualenvs/examples/bin/python --version
	assert_output --partial "Python 2.7"

	run st2 run packs.uninstall packs=examples
	assert_success
}

@test "packs.setup_virtualenv with python3 flag works" {
	skip_tests_if_python3_is_not_available_or_if_already_running_under_python3

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
	assert_output --regexp ".*PYTHONPATH: /usr/(local/)?lib/python3.*"
}

@test "python3 imports work correctly" {
    skip_tests_if_python3_is_not_available_or_if_already_running_under_python3

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

	run st2 run packs.uninstall packs=python3_test
	assert_success
}
