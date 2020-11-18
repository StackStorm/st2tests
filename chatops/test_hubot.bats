
load '../test_helpers/bats-support/load'
load '../test_helpers/bats-assert/load'



@test "StackStorm's client connection" {
	run st2 action execute core.local cmd=echo
	assert_success

	assert_line --index 0          "To get the results, execute:"
	assert_line --index 1 --regexp "^ st2 execution get [0-9a-f]*$"
	assert_line --index 2          "To view output in real-time, execute:"
	assert_line --index 3 --regexp "^ st2 execution tail [0-9a-f]*$"
}

@test "npm directory exists" {
	run eval "(cd /opt/stackstorm/chatops; npm list | grep hubot-stackstorm)"
	assert_success

	assert_output --partial "hubot-stackstorm@"
}

@test "some StackStorm aliases are enabled" {
	run eval "st2 action-alias list -a enabled -j | jq -r '.[].enabled=true | length'"
	assert_success

	assert_output --regexp '^[[:digit:]]{1,}$'
}

@test "chatops.notify rule exists" {
	RESULTS=$(st2 rule list -p chatops -j)
	run eval "echo '$RESULTS' | jq -r '.[].ref'"
	assert_success

	assert_output --partial "chatops.notify"

	run eval "echo '$RESULTS' | jq -r '.[] | select( (.ref == \"chatops.notify\") and .enabled == true) .ref'"
	assert_success
	assert_output --partial "chatops.notify"
}

@test "hubot help command works" {
	run eval "("\
	         " cd /opt/stackstorm/chatops;"\
	         " { "\
	         "   echo -n;"\
	         "   sleep 5;"\
	         "   echo 'hubot help';"\
	         "   echo;"\
	         "   sleep 5;"\
	         "} "\
	         "| bin/hubot --test"\
	         ")"
	assert_success

	assert_output --partial '!help - Displays all of the help commands'
	assert_output --regexp '[[:digit:]]{1,} commands are loaded'
}

@test "chatops.post_message execution and receive status works" {
	RANDOM_CHANNEL_NAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
	run eval "("\
	         " cd /opt/stackstorm/chatops;"\
	         " { "\
	         "   echo -n; "\
	         "   sleep 5; "\
	         "   st2 action execute chatops.post_message channel=$RANDOM_CHANNEL_NAME "\
	         "                   message='Debug. If you see this you are incredibly lucky but please ignore.'"\
	         "       >/dev/null; "\
	         "   echo; "\
	         "   sleep 5; "\
	         " } "\
	         " | bin/hubot --test"\
	         ")"
	assert_success

	assert_output --partial "Chatops message received"
	assert_output --partial "$RANDOM_CHANNEL_NAME"
}

@test "complete request-response flow" {
	run eval "("\
	         " cd /opt/stackstorm/chatops; "\
	         " { "\
	         "   echo -n; "\
	         "   sleep 10; "\
	         "   echo 'hubot st2 list 5 actions pack=st2'; "\
	         "   echo; "\
	         "   sleep 25;"\
	         " } "\
	         " | bin/hubot --test"\
	         ")"
	assert_success

	assert_output --partial "Give me just a moment to find the actions for you"
	assert_output --partial "st2.actions.list - Retrieve a list of available StackStorm actions."
}
