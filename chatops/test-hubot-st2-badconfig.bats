
load '../test_helpers/bats-support/load'
load '../test_helpers/bats-assert/load'


ST2_CHATOPS_ENV_FILE='/opt/stackstorm/chatops/st2chatops.env'
cd /opt/stackstorm/chatops


@test "exit with error status from unresolved ST2_API_URL." {
	export ST2_API_URL=http://non-existent:9101/

	run bin/hubot --test
	assert_failure 1
	assert_output --partial "Failed to retrieve commands from $ST2_API_URL"
}

@test "exit with error status from unresolved ST2_STREAM_URL." {
	export ST2_STREAM_URL=http://non-existent:9101/

	run bin/hubot --test
	assert_failure 1
	assert_output --partial "stream error"
}

@test "SETUP: make sure ENV variables are unset in st2chatops.env to test edge cases" {
	`sed -e '/ ST2_API_KEY=/s/^/#/g' -i $ST2_CHATOPS_ENV_FILE`
	`sed -e '/ ST2_AUTH_TOKEN=/s/^/#/g' -i $ST2_CHATOPS_ENV_FILE`
	`sed -e '/ ST2_AUTH_USERNAME=/s/^/#/g' -i $ST2_CHATOPS_ENV_FILE`
	`sed -e '/ ST2_AUTH_PASSWORD=/s/^/#/g' -i $ST2_CHATOPS_ENV_FILE`
	`sed -e '/ ST2_AUTH_URL=/s/^/#/g' -i $ST2_CHATOPS_ENV_FILE`
}

@test "exit with error status from only providing user name for authentication." {
	export ST2_AUTH_USERNAME=st2admin
	
	run bin/hubot --test
	assert_failure 1
	assert_output --partial "Env variables ST2_AUTH_USERNAME, ST2_AUTH_PASSWORD " \
	                        "and ST2_AUTH_URL should only be used together"
}

@test "exit with error status from only providing user password for authentication." {
	export ST2_AUTH_PASSWORD=testp

	run bin/hubot --test
	assert_failure 1
	assert_output --partial "Env variables ST2_AUTH_USERNAME, ST2_AUTH_PASSWORD " \
	                        "and ST2_AUTH_URL should only be used together"
}

@test "exit with error status from only providing user name and password for authentication." {
	export ST2_AUTH_USERNAME=st2admin
	export ST2_AUTH_PASSWORD=testp

	run bin/hubot --test
	assert_failure 1
	assert_output --partial "Env variables ST2_AUTH_USERNAME, ST2_AUTH_PASSWORD " \
	                        "and ST2_AUTH_URL should only be used together"
}

@test "exit with error status from unresolved ST2_AUTH_URL." {
	export ST2_AUTH_USERNAME=st2admin
	export ST2_AUTH_PASSWORD="testp"
	export ST2_AUTH_URL="http://non-existent:9100/"

	run bin/hubot --test
	assert_failure 1
	assert_output --partial "Failed to authenticate"
}

@test "exit with error status from invalid ST2_AUTH_TOKEN." {
	export ST2_AUTH_TOKEN=invalidst2authtoken

	run bin/hubot --test
	assert_failure 1
	assert_output --partial "Failed to retrieve commands"
	assert_output --partial "Unauthorized"
}

@test "exit with error status from invalid ST2_API_KEY." {
	export ST2_API_KEY=invalidst2apikey

	run bin/hubot --test
	assert_failure 1
	assert_output --partial "Failed to retrieve commands"
	assert_output --partial "Unauthorized - ApiKey"
}

@test "TEARDOWN: revert changes for ENV variables in st2chatops.env for test cases." {
	`sed -i '/^#.* ST2_API_KEY=/s/^#//' $ST2_CHATOPS_ENV_FILE`
	`sed -i '/^#.* ST2_AUTH_TOKEN=/s/^#//' $ST2_CHATOPS_ENV_FILE`
	`sed -i '/^#.* ST2_AUTH_USERNAME=/s/^#//' $ST2_CHATOPS_ENV_FILE`
	`sed -i '/^#.* ST2_AUTH_PASSWORD=/s/^#//' $ST2_CHATOPS_ENV_FILE`
	`sed -i '/^#.* ST2_AUTH_URL=/s/^#//' $ST2_CHATOPS_ENV_FILE`
}