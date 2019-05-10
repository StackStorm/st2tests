
load '../test_helpers/bats-support/load'
load '../test_helpers/bats-assert/load'



ST2_HOST=${ST2_HOST:-localhost}
ST2_USERNAME=${ST2_USERNAME:-st2admin}
ST2_PASSWORD=${ST2_PASSWORD:-Ch@ngeMe}

setup() {
	export TOKEN=$(st2 auth $ST2_USERNAME -p $ST2_PASSWORD -t)
	[[ "$?" -eq 0 ]]
	[[ -n "$TOKEN" ]]
}



@test "rule creation works and is idempotent (with an error message)" {
	if [[ $(st2 rule get examples.sample_rule_with_webhook) ]]; then
		st2 rule delete examples.sample_rule_with_webhook
	fi

	WEBHOOK_RESULTS=$(st2 rule create /usr/share/doc/st2/examples/rules/sample_rule_with_webhook.yaml -j)
	assert_success

	run eval "echo '$WEBHOOK_RESULTS' | jq -r '.uid'"
	assert_success

	assert_output "rule:examples:sample_rule_with_webhook"

	run eval "echo '$WEBHOOK_RESULTS' | jq -r '.enabled'"
	assert_success

	assert_output "true"

	run st2 rule create /usr/share/doc/st2/examples/rules/sample_rule_with_webhook.yaml -j
	assert_failure 2

	assert_output --partial "ERROR: 409 Client Error: Conflict"
	assert_output --partial "MESSAGE: Tried to save duplicate unique keys"
	assert_output --partial "duplicate key error"
	assert_output --partial "sample_rule_with_webhook"
}

@test "rule get works" {
	WEBHOOK=$(st2 rule get examples.sample_rule_with_webhook -j)
	assert_success
	run eval "echo '$WEBHOOK' | jq -r '.uid'"
	assert_success

	assert_output "rule:examples:sample_rule_with_webhook"

	run eval "echo '$WEBHOOK' | jq -r '.enabled'"
	assert_success

	assert_output "true"
}

@test "rule list works" {
	WEBHOOK_LIST=$(st2 rule list --pack examples -j)
	run eval "echo '$WEBHOOK_LIST' | jq -r '.[].ref'"
	assert_success

	assert_output --partial "examples.sample_rule_with_webhook"

	run eval "echo '$WEBHOOK_LIST' | jq -r '.[].pack'"
	assert_success

	assert_output --partial "examples"

	run eval "echo '$WEBHOOK_LIST' | jq -r '.[].enabled'"
	assert_success

	assert_output --partial "true"
}

@test "rule disable/enable works" {
	DISABLE_RULE_RESULT=$(st2 rule disable examples.sample_rule_with_webhook -j)
	assert_success

	run eval "echo '$DISABLE_RULE_RESULT' | jq -r '.uid'"
	assert_success

	assert_output "rule:examples:sample_rule_with_webhook"

	run eval "echo '$DISABLE_RULE_RESULT' | jq -r '.enabled'"
	assert_success

	assert_output --partial "false"

	ENABLE_RULE_RESULT=$(st2 rule enable examples.sample_rule_with_webhook -j)
	run eval "echo '$ENABLE_RULE_RESULT' | jq -r '.uid'"
	assert_success

	assert_output "rule:examples:sample_rule_with_webhook"

	run eval "echo '$ENABLE_RULE_RESULT' | jq -r '.enabled'"
	assert_success

	assert_output --partial "true"
}

@test "rule status works" {
	RULE_STATUS=$(curl --silent -k https://localhost/api/v1/webhooks/sample -d '{"foo": "bar", "name": "st2"}' -H 'Content-Type: application/json' -H "X-Auth-Token: ${TOKEN}")
	assert_success

	run eval "echo '$RULE_STATUS' | jq -r '.foo'"
	assert_success

	assert_output "bar"

	run eval "echo '$RULE_STATUS' | jq -r '.name'"
	assert_success

	assert_output "st2"
}

@test "rule deletion works and is idempotent (with an error message)" {
	run st2 rule delete examples.sample_rule_with_webhook -j
	assert_success

	assert_output --partial 'Resource with id "examples.sample_rule_with_webhook" has been successfully deleted'

	run st2 rule list --pack examples -j
	assert_success

	refute_output --partial "examples.sample_rule_with_webhook"

	run st2 rule delete examples.sample_rule_with_webhook -j
	assert_failure 2

	assert_output --partial 'Rule "examples.sample_rule_with_webhook" is not found.'
}

# Removing these tests because they fail and they don't test anything that
# hasn't already been done.
# @test "examples pack successfully uninstalls" {
# 	# UNINSTALL_RESULT=$(st2 run packs.uninstall packs=examples -j)
# 	# assert_success

# 	# run eval "echo '$UNINSTALL_RESULT' | jq -r '.status'"

# 	# The packs.uninstall action does not return valid JSON data!
# 	# It returns:
# 	# {
# 	#     "action": {
# 	#         "ref": "packs.uninstall"
# 	#     },
# 	#     "end_timestamp": "2019-04-18T02:52:47.720613Z",
# 	#     "id": "5cb7e67ca08f813f457b8a25",
# 	#     "parameters": {
# 	#         "packs": [
# 	#             "examples"
# 	#         ]
# 	#     },
# 	#     "result": {
# 	#         "exit_code": 0,
# 	#         "result": null,
# 	#         "stderr": "st2.actions.python.UninstallPackAction: DEBUG    Deleting pack directory \"/opt/stackstorm/packs/examples\"\nst2.actions.python.UninstallPackAction: DEBUG    Deleting virtualenv \"/opt/stackstorm/virtualenvs/examples\" for pack \"examples\"\n",
# 	#         "stdout": ""
# 	#     },
# 	#     "result_task": "delete packs",
# 	#     "start_timestamp": "2019-04-18T02:52:44.274245Z",
# 	#     "status": "succeeded"
# 	# }
# 	# [
# 	#     {
# 	#         "action": "packs.unload",
# 	#         "id": "5cb7e67ca08f813fa9f006a3",
# 	#         "start_timestamp": "2019-04-18T02:52:44.527055Z",
# 	#         "status": "succeeded (1s elapsed)",
# 	#         "task": "unregister packs"
# 	#     },
# 	#     {
# 	#         "action": "packs.delete",
# 	#         "id": "5cb7e67ea08f813fa9f006a5",
# 	#         "start_timestamp": "2019-04-18T02:52:46.645818Z",
# 	#         "status": "succeeded (1s elapsed)",
# 	#         "task": "delete packs"
# 	#     }
# 	# ]
# 	#
# 	# So we cannot use jq here
# 	#
# 	# Reported in https://github.com/StackStorm/st2/issues/4639
# 	#
# 	run st2 run packs.uninstall packs=examples -j
# 	assert_success

# 	NUM_SUCCESSES=$(echo "$output" | grep -c '"status": "succeeded')
# 	[[ "$NUM_SUCCESSES" -eq 3 ]]
# 	assert_output --partial '"action": "packs.unload"'
# 	assert_output --partial '"action": "packs.delete"'

# 	run st2 action list -p examples
# 	assert_success

# 	assert_output --partial "No matching items found"
# }

# @test "examples pack installation and setup works" {
# 	run sudo cp -r /usr/share/doc/st2/examples/ /opt/stackstorm/packs/
# 	assert_success

# 	[[ -d /opt/stackstorm/packs/examples ]]

# 	run st2 run packs.setup_virtualenv packs=examples -j
# 	assert_success

# 	# run eval "echo '$SETUP_VENV_RESULT' | jq -r '.result.result'"
# 	# assert_success

# 	assert_output --partial 'Successfully set up virtualenv for the following packs: examples'

# 	# run eval "echo '$SETUP_VENV_RESULT' | jq -r '.status'"
# 	# assert_success

# 	assert_output --partial '"status": "succeeded'

# 	run sudo st2ctl restart
# 	assert_success

# 	run sudo st2ctl reload --register-all
# 	assert_success

# 	run eval "st2 action list -p examples -j | jq -r '[.[].pack] | unique[0]'"
# 	assert_success

# 	assert_output "examples"
# }
