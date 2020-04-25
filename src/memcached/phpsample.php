<?php
$m = new Memcached();
$m->addServers([['localhost', 11211]]);
//$m->setByKey('s1', 'key1', $val, 100)
//
//
$key_prefix = 'phpsample_';

for($i = 1; $i <= 100; $i++ ) {
    $key = $key_prefix . $i;
    $m->set($key, $i, 100);
    $m->get($key);
    sleep(1);
};