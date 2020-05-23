---
layout: post
title: "Writeup: HackTheBox Optimum - with Metasploit"
description: "Rooting Optimum using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][]. All published writeups are for retired HTB machines. Whether
 or not I use Metasploit to pwn the server will be indicated in the title.

# Optimum

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.8</small>_

As always, I start enumeration with [AutoRecon][].

![autorecon-results][]

I see a web server is up at TCP/80. By looking at WhatWeb's results, I see that it is an HFS server running version 2.3.

![whatweb-results][]

I run HFS through searchsploit and come back with several exploits.

![searchsploit-hfs][]

I decide to look at `exploits/windows/remote/39161.py` - remote code execution would be nice.

![hfs-rce-code][]

I need to set up netcat to listen on a local port, edit the exploit to update my local host and port, and set up an
 `nc.exe` executable on a local web server for the exploit to run on the target machine. I grab an `.exe` version of
  netcat and start my local Apache server.
  
![apache-local][]

I start netcat:

![netcat-listening][]

I modify a copy of the exploit script to set it to my IP and my netcat listener's port:

![rce-modified][]

And I execute the exploit.

![rce-run][]

Success! I have a user shell.

![user-shell][]

Let's grab the user flag and move to escalate our privileges.

![user-flag][]

Now I enumerated a number of services and network and system settings, but I wasn't sure what to do. I'm new to this
. I opted to get a user shell through Metasploit so I could take advantage of it's `local_exploit_suggestor` module
 to figure out how to escalate my privilege.
 
 I search Metasploit for "HFS" modules and do not find anything. Maybe it was because I mis-typed 'HFS' as 'HSF
 .' However, I remember that the `searchsploit` title of my RCE exploit was "Rejetto HTTP File Server..." I look for
  "rejetto" modules. Success.
  
![rejetto-msf][]

I run the module and get a user shell.

![msf-user-shell][]

Now I background the meterpreter session, as I already have the user flag, and run the `local_exploit_suggestor
` module for privilege escalation options.

![local-privesc-suggestor][]

There are 2 results. I know from my previous enumeration that the `kostas` user is not in the Administrators group
, so the first module will not work. I try the second:

![local-privesc-options][]

And get a root shell.

![root-shell][]

Now I can grab my root flag:

![root-flag][]

[autorecon]: https://github.com/Tib3rius/AutoRecon
[hackthebox]: https://www.hackthebox.eu

[apache-local]: /assets/img/htb/optimum/apache-local.png
[autorecon-results]: /assets/img/htb/optimum/autorecon.png
[hfs-rce-code]: /assets/img/htb/optimum/hfs-rce-code.png
[local-privesc-options]: /assets/img/htb/optimum/local-privesc-module-options.png
[local-privesc-suggestor]: /assets/img/htb/optimum/local-privesc-suggestor.png
[msf-user-shell]: /assets/img/htb/optimum/msf-user-shell.png
[netcat-listening]: /assets/img/htb/optimum/nc-listening.png
[rejetto-msf]: /assets/img/htb/optimum/rejetto-msf-module.png
[rce-modified]: /assets/img/htb/optimum/rce-code-modified.png
[root-flag]: /assets/img/htb/optimum/root-flag.png
[rce-run]: /assets/img/htb/optimum/rce-run.png
[root-shell]: /assets/img/htb/optimum/root-shell.png
[searchsploit-hfs]: /assets/img/htb/optimum/searchsploit-hfs.png
[user-flag]: /assets/img/htb/optimum/user-flag.png
[user-shell]: /assets/img/htb/optimum/nc-user-shell.png
[whatweb-results]: /assets/img/htb/optimum/whatweb.png
