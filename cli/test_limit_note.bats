
load '../test_helpers/bats-support/load'
load '../test_helpers/bats-assert/load'



ST2_USER=st2admin



@test "default note in execution list" {
	# Use eval so we don't need to export variables to subshells
	# https://github.com/sstephenson/bats/issues/10#issuecomment-447629046
	run eval "st2 execution list 2>/dev/null | grep -c $ST2_USER"

	if [[ "$output" -eq 50 ]]; then
		run st2 execution list
		assert_success
		assert_output --partial "Note: Only first 50 action executions are displayed. Use -n/--last flag for more results."
	fi
}

@test "default note in trace list" {
	run eval "st2 trace list 2>/dev/null | grep -c trace:"

	if [[ "$output" -eq 50 ]]; then
		run st2 trace list
		assert_success
		assert_output --partial "Note: Only first 50 traces are displayed. Use -n/--last flag for more results."
	fi
}

@test "default note in trigger instance list" {
	run eval "st2 trigger-instance list 2>/dev/null | grep -c processed"

	if [[ "$output" -eq 50 ]]; then
		run st2 trigger-instance list
		assert_success
		assert_output --partial "Note: Only first 50 triggerinstances are displayed. Use -n/--last flag for more results."
	fi
}

@test "default note in rule list" {
	run eval "st2 rule list 2>/dev/null | grep -c -e True -e False"

	if [[ "$output" -eq 50 ]]; then
		run st2 rule list
		assert_success
		assert_output --partial "Note: Only first 50 rules are displayed. Use -n/--last flag for more results."
	fi
}

@test "default note in rule enforcement list" {
	run eval "st2 rule-enforcement list 2>/dev/null | grep -c chatops.notify"

	if [[ "$output" -eq 50 ]]; then
		run st2 rule-enforcement list
		assert_success
		assert_output --partial "Note: Only first 50 rule enforcements are displayed. Use -n/--last flag for more results."
	fi
}

@test "default note in key/value list" {
	run eval "st2 key list 2>/dev/null | grep -c st2kv.system"

	if [[ "$output" -eq 50 ]]; then
		run st2 key list
		assert_success
		assert_output --partial "Note: Only first 50 key value pairs are displayed. Use -n/--last flag for more results."
	fi
}



@test "note when action execution limit is 1" {
	run eval "st2 execution list 2>/dev/null | grep -c $ST2_USER"

	if [[ "$output" -gt 1 ]]; then
		run st2 execution list -n 1
		assert_success
		assert_output --partial "Note: Only one action execution is displayed. Use -n/--last flag for more results"
	fi
}

@test "note when trace limit is 1" {
	run eval "st2 trace list 2>/dev/null | grep -c trace:"

	if [[ "$output" -gt 1 ]]; then
		run st2 trace list -n 1
		assert_success
		assert_output --partial "Note: Only one trace is displayed. Use -n/--last flag for more results"
	fi
}

@test "note when trigger instance limit is 1" {
	run eval "st2 trigger-instance list 2>/dev/null | grep -c processed"

	if [[ "$output" -gt 1 ]]; then
		run st2 trigger-instance list -n 1
		assert_success
		assert_output --partial "Note: Only one triggerinstance is displayed. Use -n/--last flag for more results"
	fi
}

@test "note when rule limit is 1" {
	run eval "st2 rule list 2>/dev/null | grep -c -e True -e False"

	if [[ "$output" -gt 1 ]]; then
		run st2 rule list -n 1
		assert_success
		assert_output --partial "Note: Only one rule is displayed. Use -n/--last flag for more results"
	fi
}

@test "note when rule enforcement limit is 1" {
	run eval "st2 rule-enforcement list 2>/dev/null | grep -c chatops.notify"

	if [[ "$output" -gt 1 ]]; then
		run st2 rule-enforcement list -n 1
		assert_success
		assert_output --partial "Note: Only one rule enforcement is displayed. Use -n/--last flag for more results"
	fi
}

@test "note when key/value limit is 1" {
	run eval "st2 key list 2>/dev/null | grep -c st2kv.system"

	if [[ "$output" -gt 1 ]]; then
		run st2 key list -n 1
		assert_success
		assert_output --partial "Note: Only one key value pair is displayed. Use -n/--last flag for more results"
	fi
}



@test "no note on action execution list with JSON/YAML output" {
	run eval "st2 execution list -n 1 -j 1>/dev/null"
	assert_success
	assert_output ""
}

@test "no note on trace list with JSON/YAML output" {
	run eval "st2 trace list -n 1 -j 1>/dev/null"
	assert_success
	assert_output ""
}

@test "no note on trigger instance list with JSON/YAML output" {
	run eval "st2 trigger-instance list -n 1 -j 1>/dev/null"
	assert_success
	assert_output ""
}

@test "no note on rule list with JSON/YAML output" {
	run eval "st2 rule list -n 1 -j 1>/dev/null"
	assert_success
	assert_output ""
}

@test "no note on rule enforcement list with JSON/YAML output" {
	run eval "st2 rule-enforcement list -n 1 -j 1>/dev/null"
	assert_success
	assert_output ""
}

@test "no note on key/value list with JSON/YAML output" {
	run eval "st2 key list -n 1 -j 1>/dev/null"
	assert_success
	assert_output ""
}
