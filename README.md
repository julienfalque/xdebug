Xdebug
======

This little shell script allows you to enable Xdebug on demand when running a PHP script.

Xdebug is a powerful tool to debug PHP scripts, but is also known to be a performance killer: enabling it by default for CLI scripts will slow down all PHP commands such as Composer or PHPUnit. It is then recommended to not load the Xdebug extension at all for CLI. If you need to debug a script, enable the extension just for this script.

_Note: the script was tested with PhpStorm only._

Compatibility
------------

The script currently supports PHP 7.2+ and Xdebug 2+.

Installation
------------

Copy the [xdebug file](./xdebug) in a directory that is part of your `PATH` so it can be executed globally.

Usage
-----

When you need to debug a PHP script, just prefix your command with `xdebug`:

`$ xdebug phpunit`

`$ xdebug php script.php`

