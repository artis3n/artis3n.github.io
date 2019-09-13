---
layout: post
title: "Encrypting Files in a Post-PGP Age"
description: "Have you recently learned that PGP is not as secure as you had hoped? Looking for a simpler cryptographic tool? I don't blame you. Read on for alternatives."
tags: crypto
---

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">I have watched a cryptographer of reasonably widespread renown spitball an attack on the PGP MDC, and then say “fuck it, I’m not going to spend time working on PGP”. <br><br>That’s roughly my take on where PGP is in the modern crypto firmament.</p>&mdash; Thomas H. Ptacek (@tqbf) <a href="https://twitter.com/tqbf/status/997593091094794241?ref_src=twsrc%5Etfw">May 18, 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

Due to the recent [EFail disclosure][efail], a new conversation has arisen over the security (it's lacking) and usability (it's complex) of PGP. This is a good conversation to have and, while I clearly have my own opinion, I welcome everyone's thoughts in the comments below. I know the term "Post-PGP Age" is going to concern some members of the InfoSec community who will argue that strong, secure PGP clients are still the ideal solution for any use case, or at least the majority of them. My intention with this article is not to argue that PGP should die. Instead, I want to outline reasonable alternatives to PGP, of which readers may not be aware, so they can make an informed decision regarding their use case.

<!-- markdownlint-disable MD026 -->
## What is the problem with PGP?
<!-- markdownlint-enable MD026 -->

Cryptography professor Matthew Green has a [great article][matt-green-pgp-die] detailing the technical issues with PGP from 2014 and Keybase lists a series of [cryptographic issues with PGP][saltpack-pgp-issues]. We'll summarize the two most troubling issues but those articles are definitely worth a read.

The biggest concern with PGP is that the cryptography just isn't sufficient by modern standards. Chiefly, PGP has no support for [forward secrecy][]. Forward secrecy is a property of cryptosystems that maintains confidentiality even if secret keys used in the past are compromised in the future. Each session has a different secret key. In some cases, such as with [Signal][], every single message has a new session key so, if a key is compromised, it only affects that particular message. The rest of the conversation remains secret. Without forward secrecy in PGP, if an attacker gains control of either party's private key, the entire history of the conversation is compromised.

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">I helped build PGP support for Facebook, which at this point has probably sent more PGP emails than anyone else in the world.<br><br>If you want authority, Phil Zimmerman has stopped using PGP.<br><br>Dude who wrote it doesn&#39;t use it.</p>&mdash; Steve Weis (@sweis) <a href="https://twitter.com/sweis/status/997231087108550658?ref_src=twsrc%5Etfw">May 17, 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

Additionally, PGP does not employ [authenticated encryption][] by default. Authenticated encryption is a property that combines the confidentiality and integrity properties of ciphertext into one operation. There is a Modification Detection Code (MDC) option [supported in OpenPGP][gpg-mdc] since 2001, but it must be opted-in by client implementations and many have not. A secure cryptosystem should enforce secure defaults. There is, of course, a valid argument about maintaining support for legacy systems but, after 15+ years, it should be acceptable to begin to require the option.

<!-- markdownlint-disable MD026 -->
## What are my alternatives?
<!-- markdownlint-enable MD026 -->

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">This is the problem with PGP: anytime somebody has a use case that remotely touches on encrypting files, some people assume it means we have to drag in all five hundred pages of OpenPGP and the GnuPG mess. No: it doesn’t.</p>&mdash; Matthew Green (@matthew_d_green) <a href="https://twitter.com/matthew_d_green/status/997426990805409793?ref_src=twsrc%5Etfw">May 18, 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

If you need to send encrypted email or secure sensitive files, what do you use if not PGP? Let's look at what else is out there.

### OpenSSL

Let me kick off by saying that, while it is an available alternative, you should not choose OpenSSL. Public key encryption with OpenSSL is a lengthy process and there are simpler options with stronger security available. But, let's look at how it would work. Replace any `%wrapped%` text with an appropriate value.

1) Get the recipient's public key in `pem` format and go to step 2. If the key is in `rsa` format, such as a key generated for SSH, the recipient must perform the following operations to convert their public and private keys:

{% highlight bash %}
openssl rsa -in %RSA PRIVKEY% -outform pem > %PRIVKEY%.pem
openssl rsa -in %RSA PRIVKEY% -pubout -outform pem > %PUBKEY%.pem
{% endhighlight %}

2) As the sender, generate a random key:

{% highlight bash %}
openssl rand -base64 32 > %KEY%.bin
{% endhighlight %}

The 32 bytes in the `-base64` flag generates a 256-bit key.

3) The sender encrypts the key:

{% highlight bash %}
openssl rsautl -encrypt -inkey %PUBKEY%.pem -pubin -in %KEY%.bin -out %KEY%.bin.enc
{% endhighlight %}

4) The sender encrypts the file:

{% highlight bash %}
openssl enc -aes-256-cbc -salt -in %FILE_TO_ENCRYPT% -out %ENCRYPTED_FILE%.enc -pass file:%ABSOLUTE_PATH_TO_KEY%.bin
{% endhighlight %}

1) The sender transmits the file and encrypted key to the recipient. The recipient now decrypts the key:

{% highlight bash %}
openssl rsautl -decrypt -inkey %PRIVKEY%.pem -in %KEY%.bin.enc -out %KEY%.bin
{% endhighlight %}

6) And the recipient now decrypts the file:

{% highlight bash %}
openssl enc -d -aes-256-cbc -in %ENCRYPTED_FILE%.enc -out %FILE% -pass file:%ABSOLUTE_PATH_TO_KEY%.bin
{% endhighlight %}

So, we are left with 5-6 steps. Unless you use [LibreSSL][], AES-GCM modes will not be available to you, meaning you will have to select the `aes-256-cbc` option when encrypting. AES-GCM is an authenticated encryption mode of AES, but authenticated encryption is not present in OpenSSL at the time of this article. If you must use OpenSSL, I recommend using the generally drop-in replacement, LibreSSL, with which you will have authenticated encryption modes.

With OpenSSL, we have a cumbersome process that doesn't even solve (unless you use LibreSSL) one of our two primary cryptographic concerns with PGP. Let's see what else we can use.

### Saltpack

[Saltpack][] is a  new cryptographic format developed by [Keybase][] that is built on top of the [NaCL][] cryptographic library. Saltpack was designed specifically to improve upon the security shortcomings of PGP. Details on the encryption spec can be found [here][saltpack-spec]. It provides authenticated encryption and forward secrecy, among other guarantees like repudiable authentication. How do you use it? There are two options.

#### Use the Keybase client

The sender and recipient must [install Keybase][].

1) Then, the sender encrypts the message:

{% highlight bash %}
keybase encrypt %RECIPIENT_KEYBASE_USERNAME% -m "%MESSAGE%"

#### Or, read the message in from a file

keybase encrypt %RECIPIENT_KEYBASE_USERNAME < %MESSAGEFILE%
{% endhighlight %}

2) And the recipient decrypts the message:

{% highlight bash %}
keybase decrypt -m "%MESSAGE%"

#### Or, from a file

keybase decrypt < %MESSAGEFILE%
{% endhighlight %}

There are also `sign` and `verify` commands available.

#### Use a Saltpack package for your programming language

Currently, there are Saltpack packages in [Go][saltpack-go] and [Python][saltpack-python]. However, the Go package is the one used by Keybase and is fully featured. The Python package lags behind in terms of feature support, at least according to the Python package's README on Github. You can still perform the same encryption, decryption, signing, and verifying with the Python package as with the Go package.

To install:

{% highlight bash %}

##### Go

go get github.com/keybase/saltpack

##### Python - requires Python 3

pip install saltpack
{% endhighlight %}

The Godocs contain example usage of the Go library, so let's look at what the Python usage would look like:

1) The sender encrypts the message:

{% highlight bash %}
python3 -m saltpack encrypt "%RECIPIENT_PUBKEY%" -m "%MESSAGE%" > %ENCRYPTED%.enc
{% endhighlight %}

1) The receiver decrypts the message:

{% highlight bash %}
python3 -m saltpack decrypt "%RECIPIENT_PRIVKEY%" < %ENCRYPTED%.enc
{% endhighlight %}

Saltpack, especially via the Keybase client, is a great choice for users. A server can run these commands via a CLI, while users also have the option of Keybase's apps or the Keybase website.

### Other

And finally, there are other alternatives, such as [libpqcrypto][], that require a development investment but could also serve as PGP replacements. There are also many NaCl clients that could be bootstrapped to support PGP-like behavior while taking advantage of stronger encryption. For "plug-and-play" encrypted email and file support, I recommend looking at Saltpack.

Thoughts on the article? Do you have other alternatives? Leave a comment!

[efail]: https://efail.de/
[matt-green-pgp-die]: https://blog.cryptographyengineering.com/2014/08/13/whats-matter-with-pgp/
[saltpack-pgp-issues]: https://saltpack.org/pgp-message-format-problems
[forward secrecy]: https://en.wikipedia.org/wiki/Forward_secrecy
[signal]: https://www.signal.org/
[authenticated encryption]: https://crypto.stackexchange.com/questions/12178/why-should-i-use-authenticated-encryption-instead-of-just-encryption
[gpg-mdc]: https://lists.gnupg.org/pipermail/gnupg-users/2018-May/060315.html
[libressl]: https://www.libressl.org/
[saltpack]: https://saltpack.org/
[keybase]: https://keybase.io/
[nacl]: https://nacl.cr.yp.to/
[saltpack-spec]: https://saltpack.org/encryption-format-v2
[install keybase]: https://keybase.io/download
[saltpack-go]: https://godoc.org/github.com/keybase/saltpack
[saltpack-python]: https://github.com/keybase/saltpack-python
[libpqcrypto]: https://libpqcrypto.org/index.html
