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
