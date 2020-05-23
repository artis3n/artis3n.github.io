---
layout: post
title: "Writeup: HackTheBox Lame - with Metasploit"
description: "Rooting Lame using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][]. All published writeups are for retired HTB machines. It is
 against their rules to publish a writeup for an active machine. Whether or not I use Metasploit to pwn the server
  will be indicated in the title.

# Lame

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.3</small>_

I always start enumeration with [AutoRecon][].
It's an incredibly useful tool to automate a series of enumeration tasks you would normally perform manually.
With the tool installed - `sudo python3 autorecon.py 10.10.10.3`.
Note that some of the commands `autorecon` will run - such as nmap's UDP scan - require `sudo` privileges.

![autorecon-start][]

I see that nmap's initial scans have discoverd NetBIOS running on `TCP/139` and `TCP/445`, FTP on `TCP/21`, and SSH on `TCP/22`.
For each discovered service, autorecon runs additional scans to pull a good amount of information.
While autorecon continues its scans, I can look at what it has found so far.

![autorecon-scans][]

In `results/10.10.10.3/scans` I have a `_quick_tcp_nmap.txt` file displaying the full stdout of the quick full-connect nmap scan that autorecon ran.
I see that FTP allows anonymous login - let's see if there are any goodies.

![quick-tcp][]

![ftp][]

Hm, doesn't appear that anything exists.
Although, I may be able to use it to push files onto the server if I need to execute a payload.
Let's see if autorecon has completed.

![autorecon-end][]

It has, and I've discovered another open service - distccd on `TCP/3632`.
Let's see what additional discovery autorecon has launched against this open port.
I can see that it ran an nmap scan with the following NSE scripts: `--script=banner,distcc-cve2004-2687 --script-args=distcc-cve2004-2687.cmd=id`.
And the target is vulnerable!

![distccd-vuln][]

"Daemon command execution" sounds very promising.
Let's see what I have to work with.
Let's open Metasploit.
Starting with Kali 2020.1, remember that you should run `sudo msfconsole` to give Metasploit sudo privileges, which are required for some exploits.
I'll also create a workspace for the target.

![msf-workspace][]

Now let's see whether there is anything related to distccd in Metasploit already.

![msf-search-distccd][]

Great! There's a ready-to-go exploit for command execution against the distccd daemon for the vulnerability I discovered from nmap.
Let's use the exploit and configure it against the target, `10.10.10.3`.

![msf-distccd-exploit-options][]

Exploit!

![msf-target-dead]

What?
I spent several minutes here trying to understand what part of my Kali instance was borked before checking the HTB panel and realizing the server had gone down.
After restarting the server and navigating back to our exploit...

![msf-user-shell][]

Now that's what I'm talking about.
I can see I have a user shell and am the `daemon` user.
I still need to escalate my privileges to root.
But I can get my flag for the user shell.

![user-shell][]

Now to see how to escalate my privileges...
Running `ps aux`, I look for interesting services.
`udev` catches my eye.

![udev-services][]

I see several known local privilege escalation exploits against `udev`.
Searchsploit is a convenient CLI tool to query a local cache of <https://www.exploit-db.com/>'s database.

![searchsploit-udev][]

I choose the `exploits/linux/local/8572.c` exploit arbitrarily.
Looking at the details of the exploit with `vim /usr/share/exploitdb/exploits/linux/local/8572.c`:

![udev-exploit-code][]

I need to pass the PID of the udev netlink socket.
The exploit will then run the arbitrary code located at `/tmp/run`.
A quick [Google search][netlink google] tells me that I can find the Netlink process IDs via:

![netlink-pids][]

I'll save `2687` for later.
Now I need to get the exploit onto my target and compile it.
Let's host the uncompiled exploit on a local web server.
I can verify it is available with a curl command.

![host-exploit][]

I retrieve the exploit code on my user shell on the target machine with wget.

![wget-exploit][]

And now I can compile it on the target, which ensures it is compiled for the right architecture.

![compiled-exploit][]

Now I need to add a payload to `/tmp/run`.
I'd like for the target to create a reverse listener and have it connect to my machine.
Let's add the payload.

![escalation payload][]

Now let's set up a listener on our machine.

![nc local][]

This tells netcat to listen on local port 5555 without performing DNS resolution.
I also use `-v` for verbose output.
Now I can run our exploit with my retrieved PID of `2687`.

Target:

![escalation run][]

Local:

![nc shell][]

And there it is.
I can now retrieve the root flag.

![root-shell][]

## Notes

In the official writeup, there is a much easier exploit to take advantage of.
`TCP/139` and `TCP/445` reveal the presence of a Samba share on the target.
We can use Metasploit's `exploit/multi/samba/usermap_script` exploit.

![samba exploit][]

And just like that, I have a root shell on the machine.
From here I can read the user flag and root flag with no additional work.

I will say I do like my method for this initial box, as I had to do much more 'work' myself and understand what was happening.
That being said, it took me about 30 minutes to complete this box when it could have taken about 1 minute!
I imagine my technique to root this box without Metasploit will closely resemble my method above.

[autorecon]: https://github.com/Tib3rius/AutoRecon
[hackthebox]: https://www.hackthebox.eu
[netlink google]: https://unix.stackexchange.com/a/48269

[autorecon-start]: /assets/img/htb/lame/autorecon-start.png
[autorecon-end]: /assets/img/htb/lame/autorecon-end.png
[autorecon-scans]: /assets/img/htb/lame/autorecon-results-scan.png
[compiled-exploit]: /assets/img/htb/lame/exploit-compiled.png
[escalation payload]: /assets/img/htb/lame/escalation-payload.png
[escalation run]: /assets/img/htb/lame/target-escalation-run.png
[distccd-vuln]: /assets/img/htb/lame/nmap-distccd-vuln.png
[ftp]: /assets/img/htb/lame/ftp.png
[host-exploit]: /assets/img/htb/lame/host-exploit-uncompiled.png
[msf-distccd-exploit-options]: /assets/img/htb/lame/msf-distccd-exploit-options.png
[msf-user-shell]: /assets/img/htb/lame/msf-exploit-success-user.png
[msf-search-distccd]: /assets/img/htb/lame/msf-search-distccd.png
[msf-target-dead]: /assets/img/htb/lame/msf-run-deadserver.png
[msf-workspace]: /assets/img/htb/lame/msf-workspace.png
[nc local]: /assets/img/htb/lame/nc-local.png
[nc shell]: /assets/img/htb/lame/nc-local-root-shell.png
[netlink-pids]: /assets/img/htb/lame/netlink-pids.png
[quick-tcp]: /assets/img/htb/lame/autorecon-nmap-quick-results.png
[root-shell]: /assets/img/htb/lame/root-flag.png
[samba exploit]: /assets/img/htb/lame/samba-msf.png
[searchsploit-udev]: /assets/img/htb/lame/searchsploit-udev.png
[udev-exploit-code]: /assets/img/htb/lame/udev-exploit-code.png
[udev-services]: /assets/img/htb/lame/ps-aux-udev.png
[user-shell]: /assets/img/htb/lame/user-flag.png
[wget-exploit]: /assets/img/htb/lame/wget-lame.png
