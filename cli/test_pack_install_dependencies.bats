load '../test_helpers/bats-support/load'
load '../test_helpers/bats-assert/load'

@test "Fail to install ms pack due to outdated excel pack" {
	run st2 pack remove excel powerpoint microsoft_test mssql microsoft_parent_test microsoft_broken_test

	run eval "st2 pack list | grep -q microsoft"
	assert_failure

	run eval "st2 pack list | grep -q mssql"
	assert_failure

	run eval "st2 pack list | grep -q excel"
	assert_failure

	run eval "st2 pack list | grep -q powerpoint"
	assert_failure

	run st2 pack install excel=0.2.0
	[[ "$?" -eq 0 ]]

	run eval "st2 pack get excel --json | jq -r .version"
	assert_success

	assert_output "0.2.0"

	run st2 pack install https://github.com/StackStorm/stackstorm-ms.git
	assert_failure

	run eval "st2 pack get excel --json | jq -r .version"
	assert_success

	assert_output "0.2.0"
}

@test "Fail to install ms pack due to more recent powerpoint pack" {
	run st2 pack remove microsoft_test mssql microsoft_parent_test microsoft_broken_test
	assert_success

	run st2 pack install excel
	[[ "$?" -eq 0 ]]

	run eval "st2 pack get excel --json | jq -r .version"
	assert_success

	refute_output "0.2.0"

	run st2 pack install powerpoint=0.2.2
	assert_success

	run eval "st2 pack get powerpoint --json | jq -r .version"
	assert_success

	assert_output "0.2.2"

	run st2 pack install https://github.com/StackStorm/stackstorm-ms.git
	assert_failure

	run eval "st2 pack get excel --json | jq -r .version"
	assert_success

	refute_output "0.2.0"

	run eval "st2 pack get powerpoint --json | jq -r .version"
	assert_success

	assert_output "0.2.2"
}

@test "Successfully install the ms pack by skipping dependencies" {
	run st2 pack install excel=0.2.4
	assert_success

	run eval "st2 pack get excel --json | jq -r .version"
	assert_success

	assert_output "0.2.4"

	run st2 pack install powerpoint=0.2.2
	assert_success

	run eval "st2 pack get powerpoint --json | jq -r .version"
	assert_success

	assert_output "0.2.2"

	run st2 pack install --skip-dependencies https://github.com/StackStorm/stackstorm-ms.git
	assert_success

	run eval "st2 pack get excel --json | jq -r .version"
	assert_success

	assert_output "0.2.4"

	run eval "st2 pack get powerpoint --json | jq -r .version"
	assert_success

	assert_output "0.2.2"
}

@test "Successfully install the ms pack (excel and powerpoint packs)" {
	run st2 pack remove excel powerpoint microsoft_test mssql microsoft_parent_test microsoft_broken_test
	assert_success

	run eval "st2 pack list | grep -q microsoft"
	assert_failure

	run eval "st2 pack list | grep -q mssql"
	assert_failure

	run eval "st2 pack list | grep -q excel"
	assert_failure

	run eval "st2 pack list | grep -q powerpoint"
	assert_failure

	run st2 pack install https://github.com/StackStorm/stackstorm-ms.git
	assert_success

	run eval "st2 pack get excel --json | jq -r .version"
	assert_success

	assert_output "0.2.4"

	run eval "st2 pack get powerpoint --json | jq -r .version"
	assert_success

	assert_output "0.2.0"
}

@test "Successfully install the ms pack a second time" {
	run st2 pack install https://github.com/StackStorm/stackstorm-ms.git
	assert_success

	run eval "st2 pack get excel --json | jq -r .version"
	assert_success

	assert_output "0.2.4"

	run eval "st2 pack get powerpoint --json | jq -r .version"
	assert_success

	assert_output "0.2.0"
}

@test "Successfully install the parent ms pack" {
	run st2 pack remove excel powerpoint microsoft_test mssql microsoft_parent_test microsoft_broken_test
	assert_success

	run st2 pack install https://github.com/StackStorm/stackstorm-ms-parent.git
	assert_success

	run eval "st2 pack get excel --json | jq -r .version"
	assert_success

	assert_output "0.2.4"

	run eval "st2 pack get powerpoint --json | jq -r .version"
	assert_success

	assert_output "0.2.0"

	run eval "st2 pack get mssql --json | jq -r .version"
	assert_success

	assert_output "0.2.2"
}

@test "Fail to install the broken ms pack" {
	run st2 pack remove excel powerpoint microsoft_test mssql microsoft_parent_test microsoft_broken_test
	assert_success

	run eval "st2 pack list | grep -q microsoft"
	assert_failure

	run eval "st2 pack list | grep -q mssql"
	assert_failure

	run eval "st2 pack list | grep -q excel"
	assert_failure

	run eval "st2 pack list | grep -q powerpoint"
	assert_failure

	run st2 pack install https://github.com/StackStorm/stackstorm-ms-broken.git
	assert_failure

	run eval "st2 pack list | grep -q microsoft"
	assert_failure

	run eval "st2 pack list | grep -q mssql"
	assert_failure

	run eval "st2 pack list | grep -q excel"
	assert_failure

	run eval "st2 pack list | grep -q powerpoint"
	assert_failure
}
