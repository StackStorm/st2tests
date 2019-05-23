---
name: remote_custom_result_format
description: Execute a command on a remote host via SSH - custom result format.
pack: chatops_tests
action_ref: core.remote
formats:
  - "custom-format run {{cmd}} on {{hosts}}"
result:
  format: |
    Ran command \`{{ execution.parameters.cmd }}\` on \`{{ execution.parameters.hosts|length }}\` host{% if execution.parameters.hosts|length > 1 %}s{% endif %}.

    Details are as follows:
    {% for host in execution.result -%}
        Host: \`{{ host }}\`
        ---> stdout: {{ execution.result[host].stdout }}
        ---> stderr: {{ execution.result[host].stderr }}
    {%+ endfor %}
