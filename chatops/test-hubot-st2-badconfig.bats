
load '../test_helpers/bats-support/load'
load '../test_helpers/bats-assert/load'


ST2_CHATOPS_ENV_FILE='/opt/stackstorm/chatops/st2chatops.env'
cd /opt/stackstorm/chatops

@test "SETUP: setup environment variables for authentication related variables." {
	`sed -e '/ ST2_API_KEY=/s/^/#/g' -i $ST2_CHATOPS_ENV_FILE`
	`sed -e '/ ST2_AUTH_TOKEN= /s/^/#/g' -i $ST2_CHATOPS_ENV_FILE`
	`sed -e '/ ST2_AUTH_USERNAME= /s/^/#/g' -i $ST2_CHATOPS_ENV_FILE`
	`sed -e '/ ST2_AUTH_PASSWORD= /s/^/#/g' -i $ST2_CHATOPS_ENV_FILE`
	`sed -e '/ ST2_AUTH_URL= /s/^/#/g' -i $ST2_CHATOPS_ENV_FILE`
}

@test "exit with error status from unresolved ST2_API_URL." {
	run eval "(ST2_API_URL=http://non-existent:9101/ bin/hubot --test)"

	assert_failure
	assert_equal $status 1
	assert_output --partial "Failed to retrieve commands from "$ST2_API_URL""
}

@test "exit with error status from only providing user name for authentication." {
	run eval "(ST2_AUTH_USERNAME="st2admin" bin/hubot --test)"

	assert_failure
	assert_equal $status 1
	assert_output --partial "Error: Env variables ST2_AUTH_USERNAME, ST2_AUTH_PASSWORD " \
	                        "and ST2_AUTH_URL should only be used together"
}

@test "exit with error status from only providing user password for authentication." {
	run eval "(ST2_AUTH_PASSWORD="testp" bin/hubot --test)"

	assert_failure
	assert_equal $status 1
	assert_output --partial "Error: Env variables ST2_AUTH_USERNAME, ST2_AUTH_PASSWORD " \
	                        "and ST2_AUTH_URL should only be used together"
}

@test "exit with error status from only providing user name and password for authentication." {
	run eval "(ST2_AUTH_USERNAME="st2admin" ST2_AUTH_PASSWORD="testp" bin/hubot --test)"

	assert_failure
	assert_equal $status 1
	assert_output --partial "Error: Env variables ST2_AUTH_USERNAME, ST2_AUTH_PASSWORD " \
	                        "and ST2_AUTH_URL should only be used together"
}

@test "exit with error status from unresolved ST2_AUTH_URL." {
	run eval "(ST2_AUTH_USERNAME="st2admin" ST2_AUTH_PASSWORD="testp" "\
	          "ST2_AUTH_URL=http://non-existent:9100/ bin/hubot --test)"

	assert_failure
	assert_equal $status 1
	assert_output --partial "Failed to authenticate: getaddrinfo EAI_AGAIN non-existent"
}

@test "exit with error status from invalid ST2_AUTH_TOKEN." {
	run eval "(ST2_AUTH_TOKEN=invalidst2authtoken bin/hubot --test)"

	assert_failure
	assert_equal $status 1
	assert_output --partial "Failed to retrieve commands from"
	assert_output --partial "Unauthorized"
}

@test "exit with error status from invalid ST2_API_KEY." {
	run eval "(ST2_API_KEY=invalidst2apikey bin/hubot --test)"

	assert_failure
	assert_equal $status 1
	assert_output --partial "ERROR Failed to retrieve commands from"
	assert_output --partial "Unauthorized - ApiKey"
}

@test "TEARDOWN: remove environment variables changes for authentication related variables." {
	`sed -i '/^#.* ST2_API_KEY=/s/^#//' $ST2_CHATOPS_ENV_FILE`
	`sed -i '/^#.* ST2_AUTH_TOKEN= /s/^#//' $ST2_CHATOPS_ENV_FILE`
	`sed -i '/^#.* ST2_AUTH_USERNAME= /s/^#//' $ST2_CHATOPS_ENV_FILE`
	`sed -i '/^#.* ST2_AUTH_PASSWORD= /s/^#//' $ST2_CHATOPS_ENV_FILE`
	`sed -i '/^#.* ST2_AUTH_URL= /s/^#//' $ST2_CHATOPS_ENV_FILE`
}
