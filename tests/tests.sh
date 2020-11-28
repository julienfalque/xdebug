#!/bin/bash

root_path="$(realpath "$(dirname "$(realpath "$0")")/..")"
xdebug_path="${root_path}/xdebug"
tests_path="${root_path}/tests"
php_file_path="${tests_path}/cli.php"

run_test() {
    echo -ne "Running test \\e[33m\"${2}\"\\e[0m... "

    if [[ $1 -eq 1 ]] && ! command -v php > /dev/null
    then
        echo -e "\\e[34mSkipped (PHP not available)\\e[0m"
        return 0
    elif [[ $1 -eq 0 ]] && command -v php > /dev/null
    then
        echo -e "\\e[34mSkipped (PHP available)\\e[0m"
        return 0
    fi

    expected_result="${3}"
    expected_exit_code="${4}"

    local result
    result=$("${@:5}")
    exit_code=$?

    if [ "${result}" != "${expected_result}" ]
    then
        echo -e "\\e[31mFail:\\e[0m"
        diff -u <(echo "${expected_result}" ) <(echo "${result}")
        echo

        return 3
    fi

    if [[ $exit_code -ne $expected_exit_code ]]
    then
        echo -e "\\e[31mFail: expected exit code $expected_exit_code, got $exit_code\\e[0m"

        return 3
    fi

    echo -e "\\e[32mOK\\e[0m"

    return 0
}


failures=0

if ! run_test \
    1 \
    "No Xdebug" \
    "$(cat <<STR
Xdebug extension loaded: no
CLI arguments: array (
  0 => '${php_file_path}',
)
STR
    )" \
    0 \
    "${php_file_path}"
then
    ((++failures))
fi


if ! run_test \
    1 \
    "No Xdebug, with arguments" \
    "$(cat <<STR
Xdebug extension loaded: no
CLI arguments: array (
  0 => '${php_file_path}',
  1 => '-a',
  2 => '-b=b',
  3 => '--foo',
  4 => '--bar=bar',
  5 => 'baz',
  6 => 'argument with spaces',
)
STR
    )" \
    0 \
    "${php_file_path}" -a -b="b" --foo --bar="bar" baz "argument with spaces"
then
    ((++failures))
fi


expected_result_xdebug="$(cat <<STR
Xdebug extension loaded: yes
CLI arguments: array (
  0 => '${php_file_path}',
)
STR
)"
if ! run_test \
    1 \
    "Xdebug, with PHP command" \
    "${expected_result_xdebug}" \
    0 \
    "${xdebug_path}" php "${php_file_path}"
then
    ((++failures))
fi


expected_result_xdebug_with_arguments="$(cat <<STR
Xdebug extension loaded: yes
CLI arguments: array (
  0 => '${php_file_path}',
  1 => '-a',
  2 => '-b=b',
  3 => '--foo',
  4 => '--bar=bar',
  5 => 'baz',
  6 => 'argument with spaces',
)
STR
)"
if ! run_test \
    1 \
    "Xdebug, with PHP command, with arguments" \
    "${expected_result_xdebug_with_arguments}" \
    0 \
    "${xdebug_path}" php "${php_file_path}" -a -b="b" --foo --bar="bar" baz "argument with spaces"
then
    ((++failures))
fi


if ! run_test \
    1 \
    "Xdebug, with PHP script" \
    "${expected_result_xdebug}" \
    0 \
    "${xdebug_path}" "${php_file_path}"
then
    ((++failures))
fi


if ! run_test \
    1 \
    "Xdebug, with PHP script, with arguments" \
    "${expected_result_xdebug_with_arguments}" \
    0 \
    "${xdebug_path}" "${php_file_path}" -a -b="b" --foo --bar="bar" baz "argument with spaces"
then
    ((++failures))
fi


if ! PATH="$PATH:${tests_path}" run_test \
    1 \
    "Xdebug, with global PHP executable" \
    "${expected_result_xdebug}" \
    0 \
    "${xdebug_path}" cli.php
then
    ((++failures))
fi


if ! PATH="$PATH:${tests_path}" run_test \
    1 \
    "Xdebug, with global PHP executable, with arguments" \
    "${expected_result_xdebug_with_arguments}" \
    0 \
    "${xdebug_path}" cli.php -a -b="b" --foo --bar="bar" baz "argument with spaces"
then
    ((++failures))
fi


if ! run_test \
    1 \
    "Xdebug, with PHP script that does not exist" \
    'Not a PHP file or a command: not-a-script.php' \
    4 \
    "${xdebug_path}" not-a-script.php
then
    ((++failures))
fi


if ! run_test \
    0 \
    "Xdebug, missing PHP, with PHP command" \
    'Command php not found' \
    4 \
    "${xdebug_path}" php "${php_file_path}"
then
    ((++failures))
fi


if ! PATH="$PATH:${tests_path}" run_test \
    0 \
    "Xdebug, missing PHP, with global PHP executable" \
    'Command php not found' \
    4 \
    "${xdebug_path}" cli.php
then
    ((++failures))
fi


if ! run_test \
    0 \
    "Xdebug, missing PHP, with PHP script" \
    'Command php not found' \
    4 \
    "${xdebug_path}" "${php_file_path}"
then
    ((++failures))
fi


if [[ ${failures} -gt 0 ]]
then
    exit 3
fi

exit 0
