# `st2.ask` UX Overview

From a user perspective, the new `st2.ask` feature will show itself in three ways, which we'll cover below:

- Invoking an `st2.ask` task in a workflow
- Creating rules to detect when an `st2.ask` is waiting for a response (or additional data) and provide notifications to relevant parties
- Providing a response to satisfy an `st2.ask` action

## Invoking `st2.ask` in a Workflow

A workflow is certainly the most likely place to find a reference to `st2.ask`. Within this context, the `st2.ask` action will provide two things:

- A blocking task that will effectively pause the workflow, waiting for a response in order to proceed (i.e. pause based on available info, not just time).
- Allow users to inject data into the workflow at runtime. One strong use case for this is two-factor authentication. Usernames and passwords can be stored within `st2kv` and referenced within action parameters in a workflow, but it's impossible to do this with something like a 2FA token that must be provided in realtime.

An example workflow can be found at `st2-ask/example_workflow.md`. This shows `st2.ask` in action, both with a simple, binary approve/reject response, as well as a more complicated response that requires some customization, as well as the ability to publish results from this action as a variable to be used by the final task. Please see the comments inline for further explanation.

> Please read `st2-ask/example_workflow.md` for an example of this

## Notifying Approvers using Rules

Of course, when `st2.ask` is invoked, it's important to quickly notify those that can provide a response to an `st2.ask` execution. Using Rules for this is not only a very idiomatic way to do this in StackStorm, it also allows for a lot of different notification options by simply leveraging existing packs like `slack` or `email` either in the Rule itself, or in a more elaborate workflow that uses a combination of these.

StackStorm has a built-in trigger called `core.st2.generic.actiontrigger` which can be watched by Rules to know when an execution has changed status. Using two simple string matches within the criteria, we can narrow this down to only execution changes to the `pending` status from the `st2.ask` action. In response to such an event, we can send a simple message via slack containing the execution ID, as an example, so the user knows which execution has paused.

> Please read `st2-ask/example_rule.md` for an example of this

However, it's not uncommon to have different groups to provide approvals for different `st2.ask` actions. For this reason, `st2.ask` has a `tag` parameter, which is an arbitrary field for attaching a useful label to a specific instance of `st2.ask` in your workflows. In `st2-ask/example_rule.md`, you'll notice that we're explicitly looking for this field in our rule criteria (i.e. only watching for `st2.ask` instances tagged "managers")

It may be more appropriate to put all of the complex logic of who to notify, and using what mechanism (i.e. Slack, email, etc) to a workflow. See `st2-ask/example_rule_workflow.md` for a modified version of this rule that simply passes the original `tag` value for `st2.ask` as a parameter to this workflow. This would allow us to only require one rule for notification purposes.

## Satisfying an `st2.ask` Execution

Finally, once we've invoked `st2.ask` in a workflow, and notified approvers/responders, they need a way to respond and allow the workflow to continue. They can do this via the Web UI, or via the command-line using the `st2` client. For either of these options, the idea is to pass data into the action execution that will satisfy the schema.

> Note that both options are API-driven, which means the approve functionality can (and should) be protected by the RBAC functionality available in Brocade Workflow Composer. A new [`execution`](https://docs.stackstorm.com/rbac.html#execution) permission, `respond` will be available for this. It also means that providing a response to an `st2.ask` action can be done programmatically, if you would like to build your own tooling to do this.

Let's explore responding via the CLI first. The command for responding to the question posed by the `st2.ask` action is aptly named `st2 respond`. Let's say we've received a notification that execution `59023cfc02ebd51154291652` is waiting for a response, and in this case, the default schema is being used, which means we need only create a simple approval response. Only one key is required in this schema, namely `approve`. So, the following command will pass this data to the execution context, and will allow the workflow to continue:

```
vagrant@st2vagrant:~$ st2 respond 59023cfc02ebd51154291652 approve=yes
Data for st2.ask is received and validated. Resuming execution 59023cfc02ebd51154291652...
```

In `st2-ask/example_workflow.md` we have another instance of `st2.ask` that requires a token ID for two-factor authentication, instead of the default, simple approval data, called `ask_for_2fa_token`. In this case, we would provide the key required by that schema, namely `second_factor`.

> Note also that in the first example, we provided this key inline as a parameter to the `st2 respond` command. In this example, we omitted these, which means all required keys will be prompted interactively. This is beneficial when responding with keys that are marked `secret` in the schema, so that we can keep those values hidden from prying eyes.

```
vagrant@st2vagrant:~$ st2 respond 59023cfc02ebd51154291653
Please enter passcode for the second factor authentication: < entered interactively - hidden because secret: true >
Data for st2.ask is received and validated. Resuming execution 59023cfc02ebd51154291653...
```

You may have a workflow that requires multiple responses. Providing multiple st2.ask statements is the best way to do this.

You may want to use a schema that requires multiple fields - for instance, in the event that you want multiple people to provide a response in order to continue. See the `bob_response` and `fred_response` tasks in `st2-ask/example_workflow.md`. The `bob_response` task would fire first, so Bob must first provide a response:

```
vagrant@st2vagrant:~$ st2 respond 59023cfc02ebd51154291654 bob_token=54321
Data for st2.ask is received and validated. Resuming execution 59023cfc02ebd51154291654...
```

Fred would respond similarly to the next `st2.ask` execution.

Everything shown above could also be provided via the Web UI (TBD, I'm not a web designer):

![st2web-approve](https://cloud.githubusercontent.com/assets/4230395/26609100/0f6950e6-4554-11e7-9cc3-e564085c0e8f.png)

# TODOs

- [ ] how to target specific audiences for different st2.ask execution
- [x] how will an approval that requires more than one person looks like
- [x] revisit the CLI UX when responding (i don't like the st2 approval approach)
- [x] what's the story on authenticating the approver? will anyone be able to approve or respond to a st2.ask execution?