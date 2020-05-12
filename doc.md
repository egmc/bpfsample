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

~~usdt試したかったがdtraceオプションつきでビルドしてみてもあからんので諦め~~

できた https://dasalog.hatenablog.jp/entry/2020/04/30/094503

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

trace有効にしたもののこちらもうまくいってないのでスルー

## funccount

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

## tcptop

```
sudo tcptop-bpfcc -C 2

```

## tcpconnect / accept

## tcpretrans

再送の発生状況をプロセス / 宛先ベースで確認できる

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

AWS上でよくある名前解決問題の観測とか
https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html#vpc-dns-limits

```
$ sudo gethostlatency-bpfcc
TIME      PID    COMM                  LATms HOST
17:49:49  8149   sshd                   0.04 217.61.7.239
17:50:35  1086   mackerel-agent         2.21 api.mackerelio.com


```


# CPU

## exitsnoop

processes exitを監視、生存期間、exit codeがとれる。

short-livedなプロセスの調査など。

下記はユーザーログイン時の様子の観測

```
ubuntu@ip-172-31-2-220:~$ sudo exitsnoop-bpfcc
PCOMM            PID    PPID   TID    AGE(s)  EXIT_CODE
sshd             8818   8817   8818   0.11    0
uname            8833   8832   8833   0.00    0
uname            8836   8832   8836   0.00    0
uname            8838   8832   8838   0.00    0
00-header        8832   8831   8832   0.01    0
10-help-text     8839   8831   8839   0.00    0
grep             8841   8840   8841   0.00    0
cut              8845   8843   8845   0.00    0
50-landscape-sy  8843   8842   8843   0.00    0
bc               8844   8842   8844   0.00    0
50-landscape-sy  8842   8840   8842   0.00    0
date             8846   8840   8846   0.00    0
uname            8849   8847   8849   0.00    0
landscape-sysin  8850   8847   8850   0.00    0
who              8851   8847   8851   0.01    0
landscape-sysin  8847   8840   8847   0.30    0
50-landscape-sy  8840   8831   8840   0.31    0
cat              8853   8852   8853   0.00    0
head             8854   8852   8854   0.00    0
```

## runqslower-bpfcc

run queue latencyが一定値以上のプロセス、latencyの出力を行う


```
$ sudo runqslower-bpfcc 100
Tracing run queue latency higher than 100 us
TIME     COMM             PID           LAT(us)
19:38:41 b'mysqld'        1132              321
19:38:41 b'mysqld'        1132              783
19:38:47 b'snapd'         598              2201
19:38:47 b'snapd'         598               236
19:39:01 b'in:imuxsock'   744               149
19:39:01 b'gmain'         492               141
19:39:01 b'runqslower-bpfc' 8942              114
19:39:01 b'cron'          8943              980
19:39:01 b'cron'          8943              257
19:39:01 b'cron'          8944              361
19:39:01 b'rcu_sched'     11                362
19:39:01 b'cron'          8943              142
19:39:01 b'mysqld'        1132             2050
19:39:01 b'cron'          8943              306
19:39:05 b'dbus-daemon'   499               812
```

# Disk I/O

プロセスごとのdisk io 、latency

```
$ sudo biosnoop-bpfcc |grep -v kworker
TIME(s)        COMM           PID    DISK    T  SECTOR    BYTES   LAT(ms)
0.000000000    mysqld         28818  xvda    W  39956472  4096       0.58
0.000840000    jbd2/xvda1-8   343    xvda    W  4798352   4096       0.48
0.001036000    jbd2/xvda1-8   343    xvda    W  2215488   28672      0.64
0.001517000    jbd2/xvda1-8   343    xvda    W  2215544   4096       0.44
0.206898000    mysqld         28530  xvda    W  39956472  4096       0.56
0.207693000    jbd2/xvda1-8   343    xvda    W  2215552   12288      0.58
0.208179000    jbd2/xvda1-8   343    xvda    W  2215576   4096       0.45
0.216680000    apache2        5205   xvda    R  13506488  4096       0.41
1.818017000    mysqld         28030  xvda    W  39882752  81920      1.09
1.818908000    jbd2/xvda1-8   343    xvda    W  2215584   20480      0.63
1.819481000    jbd2/xvda1-8   343    xvda    W  2215624   4096       0.53
1.828273000    mysqld         28026  xvda    W  11831584  16384      0.67
1.828910000    jbd2/xvda1-8   343    xvda    W  2215632   8192       0.53
1
```
