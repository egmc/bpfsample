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
http://www.brendangregg.com/blog/2016-10-04/linux-bcc-mysqld-qslower.html

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

```
$ sudo bpftrace -e 'usdt:/usr/bin/php:* { printf("func: %s", probe) }'
Attaching 11 probes...
Error finding or enabling probe: usdt:/usr/bin/php:php:request__startup
```

usdt試したかったがdtraceオプションつきでビルドしてみてもあからんので諦め

## Ruby Sample

```
buntu@ip-172-31-2-220:~/work/src/ruby$ sudo tplist-bpfcc -l /home/ubuntu/.rbenv/versions/2.4.1/bin/ruby
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'raise'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'gc__sweep__begin'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'gc__sweep__end'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'gc__mark__end'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'gc__mark__begin'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'hash__create'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'load__entry'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'load__return'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'find__require__return'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'require__entry'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'find__require__entry'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'require__return'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'object__create'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'parse__begin'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'parse__end'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'string__create'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'symbol__create'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'method__cache__clear'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'cmethod__entry'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'cmethod__return'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'method__return'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'method__entry'
b'/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby' b'ruby':b'array__create'

```

##

```
sudo funccount-bpfcc '/usr/lib/x86_64-linux-gnu/libmemcached.so.11:*'
Tracing 138 functions for "b'/usr/lib/x86_64-linux-gnu/libmemcached.so.11:*'"... Hit Ctrl-C to end.
^C
FUNC                                    COUNT
b'memcached_set_user_data'                  1
b'memcached_server_list_append_with_weight'        1
b'memcached_server_list_free'               1
b'memcached_create'                         1
b'memcached_server_push'                    1
b'memcached'                                1
b'memcached_server_list_count'              3
b'memcached_mget'                           7
b'memcached_result_cas'                     7
b'memcached_result_key_length'              7
b'memcached_set'                            7
b'memcached_result_value'                   7
b'memcached_result_length'                  7
b'memcached_mget_by_key'                    7
b'memcached_result_free'                    7
b'memcached_result_key_value'               7
b'memcached_result_create'                  8
b'memcached_behavior_get'                  14
b'memcached_result_flags'                  14
b'memcached_fetch_result'                  14
b'memcached_result_reset'                  21
b'memcached_get_user_data'                 29
b'memcached_server_response_count'         35
b'memcached_server_count'                 148
Detaching...

```

## opensnoop

opensnoopでopenに失敗したファイルを出力する

これはrubyスクリプトでも適当にfileコマンドを叩くでもかんたんにサンプルが得られる

negative dentryの調査などによさそう、こういうのとか

https://qiita.com/digitalpeak/items/4b39fdcb8fae7d09f406

# networking 

```
$ sudo bpftrace -e 'kprobe:sock_sendmsg { @[comm] = count(); }'
Attaching 1 probe...
^C

@[postfix_exporte]: 1
@[dbus-daemon]: 2
@[systemd]: 2
@[process-exporte]: 2
@[systemd-journal]: 3
@[showq]: 3
@[php-fpm_exporte]: 5
@[apache2]: 15
@[mysqld_exporter]: 20
@[sshd]: 30
@[php-fpm7.2]: 73
@[mysqld]: 91
```

##tcptop

```
sudo tcptop-bpfcc -C 2

```

##tcpconnect / accept

##tcpretrans

```
$ sudo tcpretrans-bpfcc
TIME     PID    IP LADDR:LPORT          T> RADDR:RPORT          STATE
17:39:02 0      6  ::ffff:172.26.6.79:443 R> ::ffff:39.101.128.217:55414 ESTABLISHED
17:39:02 7      6  ::ffff:172.26.6.79:443 R> ::ffff:39.101.128.217:55414 ESTABLISHED
17:39:02 7      6  ::ffff:172.26.6.79:443 R> ::ffff:39.101.128.217:55414 ESTABLISHED
17:39:58 0      6  ::ffff:172.26.6.79:443 R> ::ffff:39.101.128.217:53935 ESTABLISHED
17:39:59 0      6  ::ffff:172.26.6.79:443 R> ::ffff:39.101.128.217:53935 ESTABLISHED
17:39:59 0      6  ::ffff:172.26.6.79:443 R> ::ffff:39.101.128.217:53935 ESTABLISHED
17:39:59 0      6  ::ffff:172.26.6.79:443 R> ::ffff:39.101.128.217:53935 ESTABLISHED
17:41:01 0      4  172.26.6.79:22       R> 222.186.15.62:41242  ESTABLISHED
17:46:32 0      4  172.26.6.79:22       R> 222.186.30.112:27714 ESTABLISHED

```

ローカルテスト

```
$ sudo tcpretrans-bpfcc
Tracing retransmits ... Hit Ctrl-C to end
TIME     PID    IP LADDR:LPORT          T> RADDR:RPORT          STATE
17:44:44 0      4  127.0.0.1:47232      R> 127.0.0.1:11211      SYN_SENT

```

## gethostlatency

`getaddrinfo(3), gethostbyname(3), etc.`

あたりのライブラリコールをみている

```
$ sudo gethostlatency-bpfcc
TIME      PID    COMM                  LATms HOST
17:49:49  8149   sshd                   0.04 217.61.7.239
17:50:35  1086   mackerel-agent         2.21 api.mackerelio.com


```

## その他諸々

https://speakerdeck.com/takumakume/ebpf-getting-started
