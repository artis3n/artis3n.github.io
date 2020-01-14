---
layout: post
title: "Writeup: SANS Holiday Hack Challenge 2019"
description: "A writeup of some of the challenges in this 2D CTF game."
tags: pentest ctf
image: /img/kringlecon_2019/kringlecon_logo.png
---

Lights flashing. The whistle of the wind. It's cold - even inside. You can't avoid that, not up here.

It's been several years since I've been up in these parts. Up to this frigid, bountiful land. Something was wrong back then. It drew me. Something's not right again, now. Someone's up to no good.

I hear the students of Elf University wait all year for Kringlecon. They used to call it something different. That's ok. Things change. I heard the talks this year are exceptional. Other things don't change. Someone's not content with the way things are. 

The train slows, shifting on the tracks. The lights outside the window stabilize, soft and inviting. The wind batters the outside of my carriage. Still cold, then. Well, that's to be expected. I'm here. The North Pole. I exit the train and look around the crowded station at Elf University. It looks like a lot of folks are here for Kringlecon. It's a shame they had to call me. It's only in the darkest times that folk call on the Hacker. Two trees dot the edges of the station. I know my contact is outside, waiting to fill me in. I stay inside the station for a few more minutes. There's music playing. It's a banger.

<small>"Ninjula - Here Comes Santa"</small>
<audio controls="controls" aria-label="Here Comes Santa">
  <source type="audio/mp3" src="https://www.holidayhackchallenge.com/2019/album/Ninjula%20-%20Here%20Comes%20Santa.mp3"></source>
  <p>Your browser does not support the audio element. Here is a <a href="https://www.holidayhackchallenge.com/2019/album/Ninjula%20-%20Here%20Comes%20Santa.mp3">link to the audio</a> instead.</p>
</audio>

![My avatar at Kringlecon][me]

I step outside and see my contact near the station's exit. Santa waves me over.

"This is a little embarrassing, but I could really use your help," Santa says. "Our turtle dove mascots are _missing_. They probably just wandered off."

![Santa's avatar][santa]

Santa tells me that elves around the university have discovered some clues. I need to help them out. Once I solve the first five objectives I should re-group with him. He hands me a badge and I see instructions start scrolling across it. Before I meet with the elves I take a stroll around the quad and look at what Santa has brought me here to do. I'm softly vibing to the music. I take a look at the objectives on my badge.

<small>"Ninjula - Let it Snow"</small>
<audio controls="controls" aria-label="Here Comes Santa">
  <source type="audio/mp3" src="https://www.holidayhackchallenge.com/2019/album/Ninjula%20-%20Let%20it%20Snow.mp3"></source>
  <p>Your browser does not support the audio element. Here is a <a href="https://www.holidayhackchallenge.com/2019/album/Ninjula%20-%20Let%20it%20Snow.mp3">link to the audio</a> instead.</p>
</audio>

## List of Objectives <!-- omit in toc -->

- [Objective 0: Talk to Santa in the Quad](#objective-0-talk-to-santa-in-the-quad)
- [Objective 1: Find the Turtle Doves](#objective-1-find-the-turtle-doves)
- [Objective 2: Unredact Threatening Document](#objective-2-unredact-threatening-document)
- [Objective 3: Windows Log Analysis: Evaluate Attack Outcome](#objective-3-windows-log-analysis-evaluate-attack-outcome)
- [Objective 4: Windows Log Analysis: Determine Attacker Technique](#objective-4-windows-log-analysis-determine-attacker-technique)
- [Objective 5: Network Log Analysis: Determine Compromised System](#objective-5-network-log-analysis-determine-compromised-system)
- [Objective 6: Splunk](#objective-6-splunk)
- [Objective 7: Get Access to the Steam Tunnels](#objective-7-get-access-to-the-steam-tunnels)
- [Wrap-up](#wrap-up)

# Objective 0: Talk to Santa in the Quad

_Enter the campus quad and talk to Santa._

Nice. Easy.

# Objective 1: Find the Turtle Doves

_Find the missing turtle doves._

Hm. Better start with a walk around the property. Hackers are known for their exercise, after all. On the west end of the quad, I find Hermey Hall. There are some interesting rooms in here, but I'll come back to it later. To the east, there is a sign called Dormitory, but it's locked. There's a keypad. Under closer inspection, I see smudges on each key, some smudges larger than others. There's an elf by the keypad as well, goes by the name of Tangle Coalbox. Tangle is muttering over the keypad. Trying to get inside? I'll have to return to it later. I don't think doves can operate keypads. To the north is the Student Union.

Let's go inside.

There are vendor booths lined across the room. To the right is a sleigh shop guarded by a mischievous-looking elf named Shinny Upatree. Shinny doesn't look too friendly, as elves go. In the center of the room is a great fireplace. Flames lick the walls and logs crackle merrily beneath. Perched by the flames... I see two doves. Michael and Jane. I approach them. The doves coo at me. My badge buzzes. I open it and see the dove's location has been recorded. The music in this room isn't in the freely distributed album. It's ok, I guess. The music was better outside. Guess my work here is done.

# Objective 2: Unredact Threatening Document

_Difficulty: 1/5_

_Someone sent a threatening letter to Elf University. What is the first word in ALL CAPS in the subject line of the letter? Please find the letter in the Quad._

Guess not. Someone's still being naughty. I exit the Student Union and walk slowly across the quad. Now, where is this letter? I softly vibe to the left.

...And see a letter in the north-west corner of the quad. Interesting. There seems to be a crowd of Kringlecon attendees in this corner. Bit of a giveaway, if you ask me. I take a look at the letter.

![Redacted letter][obj2-redacted]

A confounding cipher, to be sure. But, if you tilt your head to the left and squint...

Nah. I grab my laptop and copy + paste the letter's contents into an empty text file. You can only hide so long, Aggrieved Character.

> Date: February 28, 2019
>
> To the Administration, Faculty, and Staff of Elf University
> 17 Christmas Tree Lane
> North Pole
>
> From: A Concerned and Aggrieved Character
>
> Subject: DEMAND: Spread Holiday Cheer to Other Holidays and Mythical Characters... OR ELSE!
>
> Attention All Elf University Personnel,
>
> It remains a constant source of frustration that Elf University and the entire operation at the North Pole focuses exclusively on Mr. S. Claus and his year-end holiday spree.  We URGE you to consider lending your considerable resources and expertise in providing merriment, cheer, toys, candy, and much more to other holidays year-round, as well as to other mythical characters. For centuries, we have expressed our frustration at your lack of willingness to spread your cheer beyond the inaptly-called “Holiday Season.”  There are many other perfectly fine holidays and mythical characters that need your direct support year-round.
>
> If you do not accede to our demands, we will be forced to take matters into our own hands.  We do not make this threat lightly.  You have less than six months to act demonstrably. 
>
> Sincerely,
>
> --A Concerned and Aggrieved Character

It's a good thing I'm here. The threat is greater than I imagined. The doves were only herrings, and red ones at that. We have a threat. Before I do anything else, I open my badge and enter the requested word: **DEMAND**. A cold shiver rises up my spine.

# Objective 3: Windows Log Analysis: Evaluate Attack Outcome

_Difficulty: 1/5_

_We're seeing attacks against the Elf U domain! Using the event log data, identify the user account that the attacker compromised using a password spray attack. Bushy Evergreen is hanging out in the train station and may be able to help you out._

What would Elf U do without me? There isn't a moment to waste. I download the event log data and move to my Windows environment. It takes several minutes for Event Viewer to process the events and display them. 4,833 events. That's a lot, right? This is a 1/5, an easy challenge. Shouldn't be an issue. But there is one problem. I am an 1337 hacker. I hack on Linux, web, and mobile things; I don't know how Windows works. I phone a friend who tells me to look for 4624 events. I research this event code and sure enough, Windows security logs track successful login attempts under event code 4624. I filter the event log and get back 16 events. Much more manageable. Every event is logon type 3, which is a login from the network. No help there. Most of the events have a Security ID of SYSTEM. Not quite sure what that means, but presumably that's the system launching this event. I need a user. I see 2 events are spawned by users, in that they have an actual SID for a Security ID. The SIDs, or [security identifiers][], are unique and look like `S-1-5-21-3433234885-4193570458-1970602280-1123`. One logon event was from `pminstix` and the other is for user `supatree`. I try `pminstix` in my badge - no luck. I try `supatree` - cha-ching, I've solved the challenge.

![windows security log event][obj3-event]

The above is how I would have solved it if I hadn't clicked on a random security event, seen the user `supatree` on it, and tried it on my badge. Of course it was correct. I am an 1337 hacker, remember? I called up my friend after solving the challenge to ask how I'd actually parse these records.

No matter. On to the next.

# Objective 4: Windows Log Analysis: Determine Attacker Technique

_Difficulty: 2/5_

_Using these normalized Sysmon logs, identify the tool the attacker used to retrieve domain password hashes from the lsass.exe process. For hints on achieving this objective, please visit Hermey Hall and talk with SugarPlum Mary._

Hermey Hall, ey? I won't trouble SugarPlum, but let's see if they-- yes, they do have music. And it's a banger. Let's solve it inside.

<small>"Ninjula - Jinglebell rock"</small>
<audio controls="controls" aria-label="Here Comes Santa">
  <source type="audio/mp3" src="https://www.holidayhackchallenge.com/2019/album/Ninjula%20-%20Jinglebell%20rock.mp3"></source>
  <p>Your browser does not support the audio element. Here is a <a href="https://www.holidayhackchallenge.com/2019/album/Ninjula%20-%20Jinglebell%20rock.mp3">link to the audio</a> instead.</p>
</audio>

Ok, let's open up this Sysmon log file. It's a lot of JSON.

![Sysmon log file][obj4-json]

I `ctlf+f` for "lsass" and come up with 2 entries, both in the same event. That's handy.

![lsass search][obj4-lsass]

I see that this event's process ID (`pid`) is 3440. Searching for `3440` in the file, I come up with 18 entries.

![3440 search][obj4-3440]

Most are other processes with a PID of 3440.

![pid example][obj4-pid-ex]

Only 1 entry has `ppid: 3440`, indicating the parent process ID.

![ppid][obj4-ppid]

I enter **ntdsutil.exe** into my badge. Objective complete.

# Objective 5: Network Log Analysis: Determine Compromised System

_Difficulty: 2/5_

_The attacks don't stop! Can you help identify the IP address of the malware-infected system using these Zeek logs? For hints on achieving this objective, please visit the Laboratory and talk with Sparkle Redberry._

Bro, Zeek, the name makes no difference. I've never used it. Time to figure that out.

I download the Zeek logs attached to the objective and unzip the archive. My files window tells me there are 890 log files. There's also an ELFU directory with an index.html file inside it. I open the HTML file in my browser and am presented with this view.

![RITA web view][obj5-gui]

[RITA][rita-github], huh? I've never used RITA but from its GitHub page, it is a "Real Threat Intelligence Analytics" platform. And it ingests Bro/Zeek logs. I do some cursory research on how Zeek logging works but quickly determine that learning how to use RITA is what I need. Zeek builds the logs. Now that I have them, I need to use RITA to determine the compromised IP.

It takes me a bit of time to work out how to configure RITA appropriately. I followed the [Docker instructions][rita-docker] and kept trying to get it working from the docker image (`docker pull quay.io/activecm/rita`). It was much easier to get it up and running with [Docker Compose][rita-docker-compose]. I set my `CONFIG` environment variable to point to the default config that comes with RITA and pointed the `LOGS` environment variable to my directory of Zeek log files. These needed to be absolute paths. I then instructed RITA to ingest the log files into its database.

```bash
export CONFIG=~/Kringlecon/2019/rita/etc/rita.yaml
export LOGS=~/Kringlecon/2019/zeek/elfu-zeeklogs

docker-compose run --rm rita import /logs kringlecon2019
```

When `docker-compose` runs, it mounts the `CONFIG` and `LOG` paths to internal container paths as appropriate for RITA. I believe they are `/etc/rita/config.yaml` and `/logs`, respectively. This is why we tell RITA to ingest the logs at `/logs` - inside the container, this is where my specified directory will exist.

Once ingested, RITA has several pluggable options to display pieces of data from the logs. You can find them documented [here][rita-commands]. `show-beacons` immediately catches my eye. What does it mean that RITA will show "signs of C2 software?" I look for answers. RITA is [one of the tools available][rita-onion] in [Security Onion][], a Linux distribution for intrusion detection, security monitoring, and log management. That page describes `show-beacons` as:

>  Search for signs of beaconing behavior in and out of your network

Well, not much clearer than the main documentation. But my goal is to identify the IP address of the malware-infected system. Presumably, that system will be communicating with known C2 servers. I run the command.

```bash
docker-compose run rita show-beacons kringlecon2019
```

I get a ton of data back. I need a more manageable way to view this, so I pipe the data to `less` with a human-readable flag.

```bash
docker-compose run rita show-beacons kringlecon2019 -H | less -S
```

This gives me a view that looks like this:

![RITA beacon results][obj5-results]

Presumably, the highest score is a 1.0. So a 0.998 is very high... And 7660 connections?? I enter **192.168.134.130** into my badge. Success.

Five objectives complete. It's time to return to Santa. He's happy with the progress I've made, but he's concerned about who took the doves in the first place. Sends me hunting after an additional seven objectives, bringing the total (that I've encountered) to 12.

# Objective 6: Splunk

_Difficulty: 3/5_

_Access https://splunk.elfu.org/ as elf with password elfsocks. What was the message for Kent that the adversary embedded in this attack? The SOC folks at that link will help you along! For hints on achieving this objective, please visit the Laboratory in Hermey Hall and talk with Prof. Banas._

Kids, don't forget to document everything you do. Because maybe you'll solve an objective and forget how. And then your options are to either re-do the whole series of questions that lead to the answer with limited time left to submit the writeup or throw in the towel.

![Splunk solved][obj6-solved]

![Splunk questions][obj6-questions]

They are:

```
What is the short host name of Professor Banas' computer?
SWEETUMS

What is the name of the sensitive file that was likely accessed and copied by the attacker? Please provide the fully qualified location of the file.
C:\Users\cbanas\Documents\Naught_and_Nice_2019_draft.txt

What is the fully-qualified domain name (FQDN) of the command and control (C2) server?
144.202.46.214.vultr.com

What document is involved with launching the malicious PowerShell code? Please provide just the filename.
19th Century Holiday Cheer Assignment.docm

How many unique email addresses were used to send Holiday Cheer essays to Professor Banas? Please provide the numeric value.
21

What was the password for the zip archive that contained the suspicious file?
123456789

What email address did the suspicious file come from?
bradly.buttercups@eifu.org
```

And finally, the main objective:

```
What was the message for Kent that the adversary embedded in his attack?
Kent you are so unfair. And we were going to make you the king of the Winter Carnival.
```

The point of writing up this objective would be to show how to find the answers through the Splunk queries, but with the deadline for this writeup looming I've afraid all I can do is rattle off the answers. Ah! I know what to do.

_The solution to this objective is left as an exercise to the reader._

Now I am a professional.

# Objective 7: Get Access to the Steam Tunnels

_Difficulty: 3/5_

_Gain access to the steam tunnels. Who took the turtle doves? Please tell us their first and last name. For hints on achieving this objective, please visit Minty's dorm room and talk with Minty Candy Cane._

It's time to return to that keypad.

![keypad][]

Tangle Coalbox, next to the keypad, informs me that only 1 number is repeated. It seems from the keypad smudges that the most commonly touched digits are 1, 3, and 7...

> WAIT

![keypad-1337][]

![keypad-invalid][]

Shoot. Unless...

![notsureif][]

![keypad-7331][]

![keypad-solved][]

Too easy for an 7331 hacker like me.

This gives us access to the Dormitory, but the steam pipes are nowhere in sight. There is some great music, though.

<small>"Dual Core - Tis Not The Season"</small>
<audio controls="controls" aria-label="Here Comes Santa">
  <source type="audio/mp3" src="https://www.holidayhackchallenge.com/2019/album/Dual%20Core%20-%20Tis%20Not%20The%20Season.mp3"></source>
  <p>Your browser does not support the audio element. Here is a <a href="https://www.holidayhackchallenge.com/2019/album/Dual%20Core%20-%20Tis%20Not%20The%20Season.mp3">link to the audio</a> instead.</p>
</audio>

There's nothing to the hallway on the left, but on the right... a door slightly ajar. There's also a helpful message on the wall for any hackers that may forget the keypad code.

![keypad-wall][]

I walk through the ajar dorm room. There's a key-cutting machine on the desk and I get a quick glimpse of an elf who quickly walks into the closet, door slamming shut behind him. I follow. The closet is empty. Where did the elf go? Ah... I notice a small keyhole in the middle of the wall. Now how to get in...

I return to the dorm room and inspect the key-cutting machine.

![key-machine][]

CSS is hard.

It looks like I enter 6 values and a key is cut with ridges accompanying the values I select. I need to get a look at a real key into the closet to know what values to enter. It's time to break out of the Matrix.

I put on my fourth-wall-breaking beanie and inspect the browser console's Network tab for this dorm room. That elf was loaded into this room so there must be something...

![Krampus][]

Gotcha. That gives me a pretty good luck at the key, but let's ENHANCE.

![Krampus key][]

I remove my fourth-wall-breaking beanie. I have an image of the real key, now I need to fashion a key with the same dimensions. I remember a Kringlecon talk covering this... I eyeball the dimensions and on my second attempt, I manage to reveal the hidden passage.

![closet passage][]

By the way, the key-cutting machine's audio is hilarious.

<audio controls="controls" aria-label="Here Comes Santa">
  <source type="audio/wav" src="https://key.elfu.org/bzzz.wav"></source>
  <p>Your browser does not support the audio element.</p>
</audio>
<audio controls="controls" aria-label="Here Comes Santa">
  <source type="audio/wav" src="https://key.elfu.org/ding.wav"></source>
  <p>Your browser does not support the audio element.</p>
</audio>

Now to enter the mysterious passage.

![danger][]

Danger is my middle name. Besides, some of the best music is down here. The music is dark and contemplative. Onward I go.   

<small>"Josh Skoudis - Chim Chimabunga"</small>
<audio controls="controls" aria-label="Here Comes Santa">
  <source type="audio/mp3" src="https://www.holidayhackchallenge.com/2019/album/Josh%20Skoudis%20-%20Chim%20Chimabunga.mp3"></source>
  <p>Your browser does not support the audio element. Here is a <a href="https://www.holidayhackchallenge.com/2019/album/Josh%20Skoudis%20-%20Chim%20Chimabunga.mp3">link to the audio</a> instead.</p>
</audio>

I come face to face with Krampus himself. He admits that he "borrowed" Santa's turtle doves. He reveals that someone had placed paper scraps near the fire and he had sent the doves to fetch them. Unfortunately, the doves didn't return, being doves and all. Scraps of paper... Something tells me they were not ripped up arbitrarily. Krampus refuses to tell me anything more about the scraps until I help him out by solving objective 8. Before I do anything else, I open my badge and report the turtle dove culprit. **Krampus Hollyfeld**. No one escapes the Hacker.

Except for time, apparently. Time got away from me, as it does, and it is time to leave the North Pole. Hopefully, my Hacker associates had better look in the objectives I had yet to tackle.

# Wrap-up

I had a lot of fun at this year's Kringlecon. [The talks][kringlecon talks] were all really entertaining and informative. The hacking challenges were awesome. Besides the objectives listed here, there are many 'challenges' that you can do. These give hints towards some of the objectives but you can do them for fun as well. I completed several but didn't document them, so I decided not to include the challenges in this writeup. Life, unfortunately, pulled me away from the truly epic objectives. 8-12 were the 4- and 5-star challenges. Number 8 was a machine learning bypass of Google CAPTCHA. Number 9 looked like it involved web-based attacks, which is what I do in my day job. Number 10 seemed to involve breaking a weak encryption implementation. Number 11 involved an IP tables challenge that I thought I was entering in the correct syntax for but I kept running out of time so apparently, I was not. Solving that objective would have helped to open the Sleigh Shop door, and I just _know_ the most epic music was waiting behind there. Number 12 had more advanced tasks with Zeek logs.

Speaking of music, Kringlecon publishes [an album][kringlecon music] of most of the music in the game. The tensest track was found in the Laboratory in Hermey Hall, where a PowerShell challenge defeated me at the XML parsing portion. This music will haunt me.

<small>"Ninjula - Holly Jolly Xmas"</small>
<audio controls="controls" aria-label="Here Comes Santa">
  <source type="audio/mp3" src="https://www.holidayhackchallenge.com/2019/album/Ninjula%20-%20Holly%20Jolly%20Xmas.mp3"></source>
  <p>Your browser does not support the audio element. Here is a <a href="https://www.holidayhackchallenge.com/2019/album/Ninjula%20-%20Holly%20Jolly%20Xmas.mp3">link to the audio</a> instead.</p>
</audio>

The hands-down best track was definitely "Everybody wants to look a lot like Christmas," which I did not find in-game. I just know it is behind the Sleigh Shop door.

<small>"Ninjula - Everybody wants to look a lot like christmas"</small>
<audio controls="controls" aria-label="Here Comes Santa">
  <source type="audio/mp3" src="https://www.holidayhackchallenge.com/2019/album/Ninjula%20-%20Everybody%20wants%20to%20look%20a%20lot%20like%20christmas.mp3"></source>
  <p>Your browser does not support the audio element. Here is a <a href="https://www.holidayhackchallenge.com/2019/album/Ninjula%20-%20Everybody%20wants%20to%20look%20a%20lot%20like%20christmas.mp3">link to the audio</a> instead.</p>
</audio>

Thank you to SANS for putting on a great event! See you next year.


[security identifiers]: https://docs.microsoft.com/en-us/windows/win32/secauthz/security-identifiers

[me]: /img/kringlecon_2019/avatar.png
[santa]: /img/kringlecon_2019/santa_quad.png
[obj2-redacted]: /img/kringlecon_2019/obj2_letter_redacted.png
[obj3-event]: /img/kringlecon_2019/obj3_log_event.png
[obj4-json]: /img/kringlecon_2019/obj4_json.png
[obj4-lsass]: /img/kringlecon_2019/obj4_lsass.png
[obj4-3440]: /img/kringlecon_2019/obj4_3440.png
[obj4-pid-ex]: /img/kringlecon_2019/obj4_pid_example.png
[obj4-ppid]: /img/kringlecon_2019/obj4_ppid.png
[obj5-gui]: /img/kringlecon_2019/obj5-rita-gui.png
[obj5-results]: /img/kringlecon_2019/obj5-rita-results.png
[obj6-solved]: /img/kringlecon_2019/obj6_solved.png
[obj6-questions]: /img/kringlecon_2019/obj6-questions-answered.png
[keypad]: /img/kringlecon_2019/keypad.png
[keypad-invalid]: /img/kringlecon_2019/keypad-invalid.png
[keypad-solved]: /img/kringlecon_2019/keypad_solved.png
[keypad-1337]: /img/kringlecon_2019/keypad-1337.png
[keypad-7331]: /img/kringlecon_2019/keypad-7331.png
[notsureif]: /img/kringlecon_2019/notsureif.jpg
[keypad-wall]: /img/kringlecon_2019/keypad-wall-code.png
[key-machine]: /img/kringlecon_2019/key-machine.png
[krampus]: /img/kringlecon_2019/krampus.png
[krampus key]: /img/kringlecon_2019/krampus-key.png
[closet passage]: /img/kringlecon_2019/key-closet-unlocked.png
[danger]: /img/kringlecon_2019/steampipes-danger.png

[rita-github]: https://github.com/activecm/rita
[rita-docker]: https://github.com/activecm/rita/blob/master/docs/Docker%20Usage.md
[rita-docker-compose]: https://github.com/activecm/rita/blob/master/docs/Docker%20Usage.md#running-rita-with-docker-compose
[rita-commands]: https://github.com/activecm/rita/blob/master/Readme.md#examining-data-with-rita
[rita-onion]: https://securityonion.readthedocs.io/en/latest/rita.html
[security onion]: https://securityonion.net/
[kringlecon talks]: https://www.youtube.com/playlist?list=PLjLd1hNA7YVzyhhqBQaW-tF45xnS6oHAP
[kringlecon music]: https://www.holidayhackchallenge.com/2019/music.html
