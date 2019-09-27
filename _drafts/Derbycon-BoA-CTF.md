---
layout: post
title: "Derbycon 9: Bank of America CTF"
description: "A write up of some of the challenges in this jeopardy-style CTF from Derbycon 9."
tags: pentest ctf
---

<!-- markdownlint-disable MD026 -->

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

I recently attended the final [Derbycon][] conference. I did not participate in the main conference capture-the-flag (CTF) event, but a jeopardy-style CTF provided by Bank of America caught my eye. Get 250 points and win a challenge coin. I couldn't resist. Over the span of two days I wracked up 260 points and won a coin! I wanted to write up my solution to some of the challenges to teach others some things I learned as well as provide notes for myself on future CTF events.

Unfortunately, I waited several weeks after the conference to begin writing this, and I forgot how I solved several of the challenges. This is why you should always take notes during your engagement, whether it's a challenge site or a real target! I may update this article if I take the time to re-solve some of these challenges, but honestly that probably won't happen. So, without further ado let's look at some of the challenges I _did_ remember how to solve.

## Trivia

There were five 2-point challenges related to infosec trivia. I knocked these out of the way to get motivated with some points on the board.

### Who crashed 1507 computers in a single day?

This is an homage to one of the classic hacker films, [Hackers][hackers movie] (1995). The main protagonist, alias of __Zero Cool__ (hint: this is the flag), crashed 1,507 computers at the tender age of 11, causing a 7-point drop in the New York Stock Exchange.

Hackers is a definite must-watch classic, but I think [Sneakers][sneakers movie] (1992) is the better 1990s hacker movie.

### What season/episode of Mr Robot featured the Derbycon founder’s name used as a fake name by the protagonist?

This is a fun fact about Derbycon's founder, Dave Kennedy. [Mr. Robot][mr robot] is an excellent hacker show [dedicated to providing realistic "hacking" behavior][mr robot hacking]. The exploits and commands the show's protagonists run are actual commands, and are usually exactly what a real-life hacker would run in their situation. In season 3 episode 5, the main protagonist, Elliot, pretends to be called "Dave Kennedy" while escaping from law enforcement.

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

Now for some real challenges.

### OSINT: Malware author intel for hire

Points: 20

> We think a malware author has intel and is willing to share. Find his phone number and call or text him.
> Handle: @MalwareTrevor

Trevor is an [infamous cockroach][trevor] who lived and died during Derbycon 7. He first appeared in the milkshake of an attendee at a Shake Shack near to the conference venue, the franchise owners of which no doubt desperately wished for Derbycon's end. Derbycon attendees have since held memorials for Trevor outside the Shake Shack, such as this touching tribute during Derbycon 9:

<blockquote class="twitter-tweet" data-dnt="true"><p lang="und" dir="ltr">.<a href="https://twitter.com/hashtag/TrevorForget?src=hash&amp;ref_src=twsrc%5Etfw">#TrevorForget</a> <a href="https://t.co/cRmeJB5AcT">pic.twitter.com/cRmeJB5AcT</a></p>&mdash; Zlata (@pavlova_zlata) <a href="https://twitter.com/pavlova_zlata/status/1170598427463442434?ref_src=twsrc%5Etfw">September 8, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

Now it appears Trevor has gone from milkshake spelunker to malware author. We'll have to put a stop to that! Let's find some personal information on MalwareTrevor.

First thing to do, a general Google search to see what hits we get:

![Google search for @MalwareTrevor][trevor google]

Ok! They are on Twitter. Let's see what we get from their Twitter account.

![Twitter posts for @MalwareTrevor][trevor twitter]

A link to a Github gist!

![@MalTrevorMan Github gist][trevor gist]

Hmm... There doesn't seem to be anything useful in the gist. But, now we have the author's Github account.

![@MalTrevorMan Github profile][trevor github profile]

They keep their interesting stuff on pastebin, do they? Off we go. Now, I don't really know how to navigate Pastebin, so to find the proper URL for a user profile I made my own account and navigated to my profile. The URL was structured `https://pastebin.com/u/<USER>`. So, let's search both handles we've discovered for our malware author, MalwareTrevor and MalTrevorMan. MalwareTrevor didn't exist, however we get a hit for MalTrevorMan.

![MalTrevorMan Pastebin post][trevor pastebin]

Here we see a contact paste for the malware author's Facebook account. The hunt continues! I had to make a throwaway Facebook account to view the link, but then:

![MalwareTrevor Facebook profile][trevor facebook]

Success! We have a telephone number for the malware author. When I texted the number, I received the flag to submit for this challenge. I no longer remember what it was.

### Do you like nesting dolls?

Points: 25

> Retrieve the flag.

This challenge included a downloadable _nesting_dolls.zip_ file. Inside the zip file was a `VSPWXKGO.tar.gz` file. Inside that was a `FCDLXQSE.7z` file. Inside that was a `XOREPDRA.7z` file. And so on... I actually did about 30 of these manually before looking at my terminal and thinking _wow. I am definitely doing this wrong._

I noticed that the archives were either `.zip`, `.tar.gz`, `.tar.bz2`, `.tar`, or `.7z`. I made the guess that the final item would include `flag` in the title and wrote the following script. We clean up the old archive at each stage of the inception hell hole.

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

The script ran _247_ iterations before stopping at `flag.png`.

![nesting dolls output][nesting output]

But we now have our flag:

![nesting dolls flag][nesting flag]

## Binary

### Crack the Code

Points: 20

> Play the game or don't.

This challenge included a binary `Code_breaker`. Running `file` on this binary, we are told:

```bash
➜ file Code_breaker
Code_breaker: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/l, for GNU/Linux 2.6.32, BuildID[sha1]=43508fb0003043cc72f66ae2c8723ace260bb95c, not stripped
```

Hmm. I don't know anything about reverse engineering. With a little searching I find that [gdb][gdb] is the tool I need. I found [this StackExchange post][binary stackoverflow] that describes how to find the binary's entry point, set a breakpoint, and walk down the execution.

From the following snippet we find __Entry point: 0x1290__. The only problem is that gdb couldn't access this entry point's memory location:

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

Ok, you enter 15 digits and the program tells you how many of those digits are in the correct position, and how many of the other digits are valid but in the wrong column. I can brute force this by modifying one column at a time until I know the correct value. The first column is a 4:

![Code breaker second guess][cracking code 3]

With trial and error, I discover the value:

![Code breaker solution][cracking code 4]

Nice.

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
