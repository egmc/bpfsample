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



