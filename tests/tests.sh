#!/bin/bash

root_path="$(realpath "$(dirname "$(realpath "$0")")/..")"
xdebug_path="${root_path}/xdebug"
tests_path="${root_path}/tests"
php_file_path="${tests_path}/cli.php"

run_test() {
    echo -ne "Running test \\e[33m\"${1}\"\\e[0m... "

    expected_result="${2}"
    result=$("${@:3}")

    if [ "${result}" != "${expected_result}" ]
    then
        echo -e "\\e[31mFail:\\e[0m"
        diff -u <(echo "${expected_result}" ) <(echo "${result}")
        echo

        return 3
    fi

    echo -e "\\e[32mOK\\e[0m"

    return 0
}


failures=0

if ! run_test \
    "No Xdebug" \
    "$(cat <<STR
Xdebug extension loaded: no
INI setting "xdebug.remote_enable": ""
CLI arguments: array (
  0 => '${php_file_path}',
)
STR
    )" \
    "${php_file_path}"
then
    ((++failures))
fi


if ! run_test \
    "No Xdebug, with arguments" \
    "$(cat <<STR
Xdebug extension loaded: no
INI setting "xdebug.remote_enable": ""
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
    "${php_file_path}" -a -b="b" --foo --bar="bar" baz "argument with spaces"
then
    ((++failures))
fi


expected_result_xdebug="$(cat <<STR
Xdebug extension loaded: yes
INI setting "xdebug.remote_enable": "1"
CLI arguments: array (
  0 => '${php_file_path}',
)
STR
)"
if ! run_test \
    "Xdebug, with PHP command" \
    "${expected_result_xdebug}" \
    "${xdebug_path}" php "${php_file_path}"
then
    ((++failures))
fi


expected_result_xdebug_with_arguments="$(cat <<STR
Xdebug extension loaded: yes
INI setting "xdebug.remote_enable": "1"
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
    "Xdebug, with PHP command, with arguments" \
    "${expected_result_xdebug_with_arguments}" \
    "${xdebug_path}" php "${php_file_path}" -a -b="b" --foo --bar="bar" baz "argument with spaces"
then
    ((++failures))
fi


if ! run_test \
    "Xdebug, with PHP script" \
    "${expected_result_xdebug}" \
    "${xdebug_path}" "${php_file_path}"
then
    ((++failures))
fi


if ! run_test \
    "Xdebug, with PHP script, with arguments" \
    "${expected_result_xdebug_with_arguments}" \
    "${xdebug_path}" "${php_file_path}" -a -b="b" --foo --bar="bar" baz "argument with spaces"
then
    ((++failures))
fi


if ! PATH="$PATH:${tests_path}" run_test \
    "Xdebug, with PHP script" \
    "${expected_result_xdebug}" \
    "${xdebug_path}" cli.php
then
    ((++failures))
fi


if ! PATH="$PATH:${tests_path}" run_test \
    "Xdebug, with PHP script, with arguments" \
    "${expected_result_xdebug_with_arguments}" \
    "${xdebug_path}" cli.php -a -b="b" --foo --bar="bar" baz "argument with spaces"
then
    ((++failures))
fi

if [ ${failures} -gt 0 ]
then
    exit 3
fi

exit 0
