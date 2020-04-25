
<?php
$m = new Memcached();
for($i = 1; $i <= 10000000000; $i++ ) {
    $m->addServers([['localhost', 11211]]);
    $m->getStats();
    $m->quit();
};
