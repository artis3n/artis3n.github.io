---
layout: post
title: "Writeup: HackTheBox Sense - with Metasploit"
description: "Rooting Sense using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][].
All published writeups are for retired HTB machines.
Whether or not I use Metasploit to pwn the server will be indicated in the title.
 
# Sense

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.60</small>_

I kick things off with a port scan.

```bash
sudo nmap -sS -T4 -p- 10.10.10.60

Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-07 16:34 EDT
Nmap scan report for 10.10.10.60
Host is up (0.015s latency).
Not shown: 65533 filtered ports
PORT    STATE SERVICE
80/tcp  open  http
443/tcp open  https
```

```bash
sudo nmap -sT -T4 -A -sC -sV -p 80,443 10.10.10.60

Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-07 16:36 EDT
Nmap scan report for 10.10.10.60
Host is up (0.014s latency).

PORT    STATE SERVICE    VERSION
80/tcp  open  http       lighttpd 1.4.35
|_http-server-header: lighttpd/1.4.35
|_http-title: Did not follow redirect to https://10.10.10.60/
|_https-redirect: ERROR: Script execution failed (use -d to debug)
443/tcp open  ssl/https?
|_ssl-date: TLS randomness does not represent time
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: specialized|general purpose
Running (JUST GUESSING): Comau embedded (92%), FreeBSD 8.X (85%), OpenBSD 4.X (85%)
OS CPE: cpe:/o:freebsd:freebsd:8.1 cpe:/o:openbsd:openbsd:4.0
Aggressive OS guesses: Comau C4G robot control unit (92%), FreeBSD 8.1 (85%), OpenBSD 4.0 (85%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops

TRACEROUTE (using proto 1/icmp)
HOP RTT      ADDRESS
1   13.80 ms 10.10.14.1
2   13.93 ms 10.10.10.60
```

It looks like 80/443 are the only ports open, and I'm looking at a `lighttpd` server version 1.4.35.

Browsing to `https://10.10.10.60/index.php` brings up a login page for [pfSense][].
A [gobuster][] scan finds a `/system-users.txt` file.

```bash
gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 30 -u https://10.10.10.60/ -k -x txt
```

From <https://docs.netgate.com/pfsense/en/latest/usermanager/pfsense-default-username-and-password.html>, I see that the default credentials for pfSense are `admin / pfsense`.
These do not work on the `index.php` page, however.

![pfsense default creds][]

The `https://10.10.10.60/system-users.txt` page reveals the existence of a `Rohit` user with a default password.

![rohit ticket][]

That would be `Rohit / pfsense`, then.
These credentials allow me to login to the pfSense portal.

In Metasploit, I see there is a `exploit/unix/http/pfsense_graph_injection_exec` module, which is a remote code execution exploit requiring an authenticated session.
Well, now that I have pfSense credentials, this should do the trick.
Sure enough, this exploit gives me a root shell.

![root shell][]

I can now collect the user and root flags.

[gobuster]: https://github.com/OJ/gobuster
[hackthebox]: https://www.hackthebox.eu
[pfsense]: https://www.pfsense.org/

[pfsense default creds]: /assets/img/htb/sense/pfsense-default-creds.png
[rohit ticket]: /assets/img/htb/sense/rohit-ticket-found.png
[root shell]: /assets/img/htb/sense/meterpreter-root.png
