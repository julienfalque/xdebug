#!/usr/bin/env php
<?php

echo 'Xdebug extension loaded: '.(extension_loaded('xdebug') ? 'yes' : 'no')."\n";
echo 'INI setting "xdebug.remote_enable": "'.ini_get('xdebug.remote_enable')."\"\n";
echo 'CLI arguments: '.var_export($argv, true)."\n";
