# Adjusting child processes for PHP-FPM (Nginx)

When setting these options consider the following:

- How long is your average request?
- What is the maximum number of simultaneous visitors the site(s) get?
- How much memory on average does each child process consume?

## Determine if the max_children limit has been reached.
- `sudo grep max_children /var/log/php?.?-fpm.log.1 /var/log/php?.?-fpm.log`

## Determine system RAM and average pool size memory.
- `free -h`
- All fpm processes: `ps -ylC php-fpm7.0 --sort:rss`
- Average memory: `ps --no-headers -o "rss,cmd" -C php-fpm7.0 | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"M") }'`
- All fpm processes memory: `ps -eo size,pid,user,command --sort -size | awk '{ hr=$1/1024 ; printf("%13.2f Mb ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }' | grep php-fpm`

## Calculate max_children
### Based on RAM
- `pm.max_children = Total RAM dedicated to the web server / Max child process size`

- System RAM: 2GB
- Average Pool size: 85Mb
- `pm.max_children = 1500MB / 85MB = 17`

#### Based on average script execution time
- `max_children = (average PHP script execution time) * (PHP requests per second)`
- `visitors = max_children * (seconds between page views) / (avg. execution time)`

## Configure
`sudo vim /etc/php/7.0/fpm/pool.d/www.conf`

```
pm.max_children = 17
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
pm.max_request = 1000
```

```
; Choose how the process manager will control the number of child processes.
; Possible Values:
;   static  - a fixed number (pm.max_children) of child processes;
;   dynamic - the number of child processes are set dynamically based on the
;             following directives:
;             pm.max_children      - the maximum number of children that can
;                                    be alive at the same time.
;             pm.start_servers     - the number of children created on startup.
;             pm.min_spare_servers - the minimum number of children in 'idle'
;                                    state (waiting to process). If the number
;                                    of 'idle' processes is less than this
;                                    number then some children will be created.
;             pm.max_spare_servers - the maximum number of children in 'idle'
;                                    state (waiting to process). If the number
;                                    of 'idle' processes is greater than this
;                                    number then some children will be killed.
; Note: This value is mandatory.
```

