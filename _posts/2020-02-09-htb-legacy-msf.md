---
layout: post
title: "Writeup: HackTheBox Legacy - with Metasploit"
description: "Rooting Legacy using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][].
All published writeups are for retired HTB machines.
Whether or not I use Metasploit to pwn the server will be indicated in the title.

# Legacy

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.4</small>_

As always, I start enumeration with [AutoRecon][].
I see that the server is running SMB and the OS is likely Windows XP.

![autorecon results][]

![nmap results][]

![nmap script results][]

Let's see what options I have in Metasploit.
I'll use the [MS08_67][] exploit.

![msf search][]

I configure the exploit options to target `10.10.10.4`.

![msf exploit][]

And there I have it.
A root shell.

![root shell][]

From here I can read the user and root's flags with ease (ignoring some Windows directory traversal mistakes).

![user flag][]

![root flag][]

[autorecon]: https://github.com/Tib3rius/AutoRecon
[hackthebox]: https://www.hackthebox.eu
[ms08_67]: https://docs.microsoft.com/en-us/security-updates/securitybulletins/2008/ms08-067

[autorecon results]: /img/htb/legacy/autorecon.png
[msf exploit]: /img/htb/legacy/msf-exploit-options.png
[msf search]: /img/htb/legacy/msf-search-smb.png
[nmap results]: /img/htb/legacy/full-nmap-results.png
[nmap script results]: /img/htb/legacy/full-nmap-script-results.png
[user flag]: /img/htb/legacy/user-flag.png
[root flag]: /img/htb/legacy/root-flag.png
[root shell]: /img/htb/legacy/root-shell.png
