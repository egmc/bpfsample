# bpf sample's samples


## memcached sample

libmemcachedのsetパラメータを覗く


ruby

```
sudo BPFTRACE_STRLEN=200 bpftrace -e 'uprobe:/var/lib/gems/2.7.0/gems/memcached-1.8.0/lib/rlibmemcached.so:memcached_set { printf("----");time(); printf("key_length: %d\nkey: %s\n", arg2, str(arg1));  printf("val_lenght: %d\nval: %s\n", arg4, str(arg3) );}'
```

php

```
sudo BPFTRACE_STRLEN=200 bpftrace -e 'uprobe:/usr/lib/x86_64-linux-gnu/libmemcached.so.11:memcached_set { printf("----");time(); printf("key_length: %d\nkey: %s\n", arg2, str(arg1));  printf("val_lenght: %d\nval: %s\n", arg4, str(arg3) );   }'
```

## MySQL sample

あまり振るわず

サンプルのmysqld_qslowerはUSDTが使える前提なのでtraceオプションつきでmysqlをビルドする必要あり

```
$ sudo tplist-bpfcc /usr/sbin/mysqld
#nothing
```

uprobeを使用するサンプルは動いた本番でオプションを変更せずに動かせるという意味ではいいかもしれない
sysbenchで出力を眺めてみようとしたがBEGINしか出力されず微妙


```
$ sudo ./mysqld_qslower-uprobes.bt 0
./mysqld_qslower-uprobes.bt:14:18-20: WARNING: comparison of integers of different signs: 'unsigned int64' and 'int64' can lead to undefined behavior
        if (arg2 == $COM_QUERY) {
                 ~~
./mysqld_qslower-uprobes.bt:24:18-19: WARNING: comparison of integers of different signs: 'unsigned int64' and 'int64' can lead to undefined behavior
        if ($dur > $1) {
                 ~
Attaching 3 probes...
Tracing mysqld queries slower than 0 ms. Ctrl-C to end.
TIME(ms)   PID        MS QUERY
1408       25379      25 select * from sbtest1 where c like '%11%'
79991      25379       1 SELECT * FROM INFORMATION_SCHEMA.CHARACTER_SETS`
```


## PHP sample

```
$ tplist-bpfcc -l /usr/bin/php
b'/usr/bin/php' b'php':b'request__startup'
b'/usr/bin/php' b'php':b'request__shutdown'
b'/usr/bin/php' b'php':b'compile__file__entry'
b'/usr/bin/php' b'php':b'compile__file__return'
b'/usr/bin/php' b'php':b'function__return'
b'/usr/bin/php' b'php':b'function__entry'
b'/usr/bin/php' b'php':b'execute__entry'
b'/usr/bin/php' b'php':b'execute__return'
b'/usr/bin/php' b'php':b'error'
b'/usr/bin/php' b'php':b'exception__thrown'
b'/usr/bin/php' b'php':b'exception__caught'
```

## opensnoop

opensnoopでopenに失敗したファイルを出力する

これはrubyスクリプトでも適当にfileコマンドを叩くでもかんたんにサンプルが得られる

negative dentryの調査などによさそう、こういうのとか

https://qiita.com/digitalpeak/items/4b39fdcb8fae7d09f406


