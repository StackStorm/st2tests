# `st2.ask` UX Overview

From a user perspective, the new `st2.ask` feature will show itself in three ways, which we'll cover below:

- Invoking an `st2.ask` task in a workflow
- Creating rules to detect when an `st2.ask` is waiting for approval (or additional data) and provide notifications to relevant parties
- Providing approval (or additional data) to satisfy an `ask` action

## Invoking `st2.ask` in a Workflow

A workflow is certainly the most likely place to find a reference to `st2.ask`. Within this context, the `st2.ask` action will provide two things:

- A blocking task that will effectively pause the workflow, waiting for approval, or other appropriate data, to proceed (i.e. pause based on available info, not just time).
- Allow users to inject data into the workflow at runtime. One strong use case for this is two-factor authentication. Usernames and passwords can be stored within `st2kv` and referenced within action parameters in a workflow, but it's impossible to do this with something like a 2FA token that must be provided in realtime.

An example workflow can be found at `st2-ask/example_workflow.md`. This shows `st2.ask` in action, both with a simple, binary approve/reject response, as well as a more complicated response that requires some customization, as well as the ability to publish results from this action as a variable to be used by the final task. Please see the comments inline for further explanation.

> Please read `st2-ask/example_workflow.md` for an example of this

## Notifying Approvers with Rules

Of course, when `st2.ask` is invoked, it's important to quickly notify those that can provide approval. Using Rules for this is not only a very idiomatic way to do this in StackStorm, it also allows for a lot of different notification options by simply leveraging existing packs like `slack` or `email` either in the Rule itself, or in a more elaborate workflow that uses a combination of these.

StackStorm has a built-in trigger called `core.st2.generic.actiontrigger` which can be watched by Rules to know when an execution has changed status. Using two simple string matches within the criteria, we can narrow this down to only execution changes to the `awaits` status from the `st2.ask` action. In response to such an event, we can send a simple message via slack containing the execution ID, as an example, so the user knows which execution has paused.

> Please read `st2-ask/example_rule.md` for an example of this

## Satisfying an `st2.ask` Execution

Finally, once we've invoked `st2.ask` in a workflow, and notified the approvers, they need a way to approve, or otherwise allow the workflow to continue. They can do this via the Web UI, or via the command-line using the `st2` command. For either of these options, the idea is to provide a JSON or YAML data structure that will satisfy the schema (and any additional checks) implemented in the `st2.ask` action.

> Note that both options are API-driven, which means the approve functionality can (and should) be protected by the RBAC functionality available in Brocade Workflow Composer. It also means that providing an approval response to an `st2.ask` action can be done programmatically, if you would like to build your own tooling to do this.

Let's explore approving via the CLI first. A new resource, known as as `approval` can be created in the same way that a rule or action is created. Let's say we've received a notification that execution `59023cfc02ebd51154291652` is waiting for approval, and in this case, the default schema is being used, which means we need only create a simple approval response. The following YAML file (also shown at `st2-ask/simple_approval.yaml`) will suffice for this:

```yaml
---
id: 59023cfc02ebd51154291652
data:
  approve: yes
```

Note that the execution ID in question is provided via the `id` field, and everything provided underneath the `data` field is passed directly to the execution context. Finally, we upload this approval to StackStorm using `st2 approval create`:

```
vagrant@st2vagrant:~$ st2 approval create simple_approval.yaml
+-------------+--------------------------------------------------------------+
| Property    | Value                                                        |
+-------------+--------------------------------------------------------------+
| id          | 59023cfc02ebd51154291652                                     |
| data        | {                                                            |
|             |     "approve": "yes"                                         |
|             | }                                                            |
+-------------+--------------------------------------------------------------+
```

In the workflow example we discussed in the first section, we have another instance of `st2.ask` that requires some additional data, not just a simple approval. In this case, we would just modify our approval to - in addition to containing the new execution ID - provide the data required by that instance's JSON schema in use:

```
vagrant@st2vagrant:~$ cat 2FA_approval.yaml
---
id: 59023cfc02ebd51154291653
data:
  second_factor: 012345


vagrant@st2vagrant:~$ st2 approval create 2FA_approval.yaml
+-------------+--------------------------------------------------------------+
| Property    | Value                                                        |
+-------------+--------------------------------------------------------------+
| id          | 59023cfc02ebd51154291653                                     |
| data        | {                                                            |
|             |     "second_factor": "012345"                                |
|             | }                                                            |
+-------------+--------------------------------------------------------------+
```

Finally, the same data could also be provided via the Web UI (I'm not a web designer, but this would be functionally similar to creating a rule or action via the UI):

> See st2-ask/st2web-approve.png 
