
load 'test_helpers/bats-support/load'
load 'test_helpers/bats-assert/load'

ST2_HOST=${ST2_HOST:-localhost}
ST2_USERNAME=${ST2_USERNAME:-st2admin}
ST2_PASSWORD=${ST2_PASSWORD:-Ch@ngeMe}

setup() {
	export TOKEN=$(st2 auth $ST2_USERNAME -p $ST2_PASSWORD -t)
	[[ "$?" -eq 0 ]]
	[[ -n "$TOKEN" ]]
}

@test "rule creation works and is idempotent (with an error message)" {
	run st2 rule create /usr/share/doc/st2/examples/rules/sample_rule_with_webhook.yaml -j
	assert_success

	assert_output --partial '"uid": "rule:examples:sample_rule_with_webhook"'
	assert_output --partial '"enabled": true'

	run st2 rule create /usr/share/doc/st2/examples/rules/sample_rule_with_webhook.yaml -j
	assert_failure 2

	assert_output --partial "ERROR: 409 Client Error: Conflict"
	assert_output --partial "MESSAGE: Tried to save duplicate unique keys"
	assert_output --partial "duplicate key error"
	assert_output --partial "sample_rule_with_webhook"
}

@test "rule get works" {
	run st2 rule get examples.sample_rule_with_webhook -j
	assert_success

	assert_output --partial '"uid": "rule:examples:sample_rule_with_webhook"'
	assert_output --partial '"enabled": true'
}

@test "rule list works" {
	run st2 rule list --pack examples -j
	assert_success

	assert_output --partial '"ref": "examples.sample_rule_with_webhook"'
	assert_output --partial '"pack": "examples"'
	assert_output --partial '"enabled": true'
}

@test "rule disable/enable works" {
	run st2 rule disable examples.sample_rule_with_webhook -j
	assert_success

	assert_output --partial '"uid": "rule:examples:sample_rule_with_webhook"'
	assert_output --partial '"enabled": false'

	run st2 rule enable examples.sample_rule_with_webhook -j
	assert_success

	assert_output --partial '"uid": "rule:examples:sample_rule_with_webhook"'
	assert_output --partial '"enabled": true'
}

@test "rule status works" {
	run eval "curl --silent -k https://localhost/api/v1/webhooks/sample -d '{\"foo\": \"bar\", \"name\": \"st2\"}' -H 'Content-Type: application/json' -H \"X-Auth-Token: ${TOKEN}\""
	assert_success

	assert_output --partial '"foo": "bar"'
	assert_output --partial '"name": "st2"'
}

@test "rule deletion works and is idempotent (with an error message)" {
	run st2 rule delete examples.sample_rule_with_webhook -j
	assert_success

	assert_output --partial 'Resource with id "examples.sample_rule_with_webhook" has been successfully deleted'

	run st2 rule list --pack examples -j
	assert_success

	assert_output --partial "No matching items found"

	run st2 rule delete examples.sample_rule_with_webhook -j
	assert_failure 2

	assert_output --partial 'Rule "examples.sample_rule_with_webhook" is not found.'
}

@test "examples pack installation and setup works" {
	run sudo cp -r /usr/share/doc/st2/examples/ /opt/stackstorm/packs/
	assert_success

	[[ -d /opt/stackstorm/packs/examples ]]

	run st2 run packs.setup_virtualenv packs=examples -j

	assert_output --partial 'Successfully set up virtualenv for the following packs: examples'
	assert_output --partial '"status": "succeeded"'

	run st2 action list -p examples
	assert_success

	assert_output --partial 'No matching items found'

	run st2ctl reload --register-all
	assert_success
	run st2 action list -p examples -j
	assert_success

	assert_output --partial '"pack": "examples"'
}

@test "examples pack successfully uninstalls" {
	run st2 run packs.uninstall packs=examples -j
	assert_success

	[[ $(echo "$output" | grep -c '"status": "succeeded') -eq 3 ]]
	assert_output --partial '"action": "packs.unload"'
	assert_output --partial '"action": "packs.delete"'

	run st2 action list -p examples
	assert_success

	assert_output --partial "No matching items found"
}
