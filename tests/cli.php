#!/usr/bin/env php
<?php

echo 'Xdebug extension loaded: '.(extension_loaded('xdebug') ? 'yes' : 'no')."\n";
echo 'CLI arguments: '.var_export($argv, true)."\n";
