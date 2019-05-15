# Copyright 2019 Extreme Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Common bash utility functions used by test code

run_command_and_log_output() {
    # Utility function which runs a bash command and logs the command output (stdout) and exit
    # code.
    #
    # This comes in handy in scenarios where you want to save command stdout in a variable, but you
    # also want to output the command stdout to make troubleshooting / debugging in test failures
    # easier.
    #
    # Example usage:
    #
    # RESULT=$(run_command_and_log_output st2 run pack install packs=examples)
    #
    # 1. Run the command and capture the outputs
    eval "$({ stderr=$({ stdout=$($@); exit_code=$?; } 2>&1; declare -p stdout exit_code >&2); declare -p stderr ; } 2>&1)"

    # 2. Log the output to stderr
    >&2 echo "=========="
    >&2 echo "Ran command: ${@}"
    >&2 echo "stdout: ${stdout}"
    >&2 echo "stderr: ${stderr}"
    >&2 echo "exit code: ${exit_code}"
    >&2 echo "=========="

    # 3. Return original command value
    echo "${stdout}"
}

run_command_and_log_output_get_stderr() {
    # Utility function which runs a bash command and logs the command output (stdout) and exit
    # code.
    #
    # This comes in handy in scenarios where you want to save command stdout in a variable, but you
    # also want to output the command stdout to make troubleshooting / debugging in test failures
    # easier.
    #
    # Example usage:
    #
    # RESULT=$(run_command_and_log_output_get_stderr st2 run pack install packs=examples)
    #
    # 1. Run the command and capture the outputs
    eval "$({ stderr=$({ stdout=$($@); exit_code=$?; } 2>&1; declare -p stdout exit_code >&2); declare -p stderr ; } 2>&1)"

    # 2. Log the output to stderr
    >&2 echo "=========="
    >&2 echo "Ran command: ${@}"
    >&2 echo "stdout: ${stdout}"
    >&2 echo "stderr: ${stderr}"
    >&2 echo "exit code: ${exit_code}"
    >&2 echo "=========="

    # 3. Return original command error
    echo "${stderr}"
}
