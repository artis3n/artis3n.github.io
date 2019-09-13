---
layout: post
title: "Post-Quantum Cryptography, Part 2: Supersingular Isogenies"
description: "An overview of the post-quantum cryptography function Supersingular Isogeny Diffie-Hellman."
tags: quantum crypto
---

![Fractal header](/img/quantum_cryptography/fractal_header.jpg)

In the [first part][pqc1] of this series, I discussed some basics of quantum mechanics and how they apply to quantum computing. In this part, I'll continue that discussion by examining the proposed families of post-quantum functions, beginning with Supersingular Isogeny Diffie-Hellman.

First, [what is post-quantum cryptography][]? Post-quantum crypto (PQC) is the use of classical methods (as opposed to quantum mechanics) to create functions that will be resistant to known quantum attacks. [Quantum cryptography][], on the other hand, exploits the principles of quantum mechanics to achieve cryptographic goals. The hope of PQC is that it will be a drop-in replacement to current cryptographic methods. As I mentioned in the previous article, [Shor's Algorithm][] and [Grover's Algorithm][] are algorithms designed to run on a quantum computer. With enough qubits, Shor's Algorithm can be used to break asymmetric encryption schemes, such as RSA. A modified version of Shor's Algorithm can be used to break elliptic curve cryptography. Grover's Algorithm cannot break symmetric encryption schemes but does cut down the amount of work necessary to brute force symmetric schemes by half (AES-256 will have the same security guarantees as AES-128 does today). Shor's and Grover's algorithms are quantum cryptanalysis, but it is likely possible to mitigate their effects using PQC functions.

### Supersingular Isogeny Diffie Hellman

There are several families of PQC functions. The first we will look at is [supersingular isogenies][], specifically, [Supersingular Isogeny Diffie-Hellman][] (SIDH). I assume that you are familiar with [Diffie-Hellman][] (DH). If you are not, the linked Stack Exchange post is a great concise explanation of how DH works. SIDH mirrors the functionality of DH in a quantum-resistant manner. I am not going to go into detail on [elliptic curve cryptography][] (ECC) now, although I may discuss it in another post at a later date. The article I linked to is an extremely excellent explanation of how elliptic curve cryptography works from Cloudflare. We will need to know a little bit about elliptic curves, however, as SIDH relies on additional properties applied to elliptic curves. In brief, elliptic curves are curves defined over a finite field, represented by the [Weierstrass form][], _y<sup>2</sup> = x<sup>3</sup> + ax + b_, and are _non-singular_, meaning that there must be a unique tangent line at every point on the curve; the curve does not self-intersect or contain any cusps. Elliptic curves are defined over a finite field _K_. All elliptic curves have a special point called the [point at infinity][] and a group structure of _K_-rational points defined over that _K_-field.

An _[isogeny][]_ is a special type of [morphism][] between elliptic curves. This means that the mapping between curves is surjective - each point on the second curve is mapped to by at least one point on the first curve - and the points on the curves are defined over a finite space, known as the isogeny's kernel.  An isogeny between two elliptic curves is a rational morphism that maps a point at infinity on curve 1 to a point at infinity on curve 2. An isogeny can be uniquely identified by its "kernel" - the subgroup of points on the source curve that map to the point at infinity of a target curve. Isogenies are typically represented as a set of formulas<sup id="f1">[1](#velu)</sup>.

A [_supersingular_ elliptic curve][] is a certain type of elliptic curve with unusually high endomorphism rings of rank 4. This property is important from a mathematical perspective but is not something you need to understand for this article. Furthermore, the use of 'supersingular' is unrelated to the _non-singularity_ property of elliptic curves mentioned above. Supersingular elliptic curves are non-singular. 'Supersingular' refers to the fact that the [j-invariants][] of the elliptic curves have singular values. For the purposes of this article, you only need to understand that j-invariants are a mathematical function<sup id="f2">[2](#j-invariant)</sup>. This supersingularity property means that every j-invariant for supersingular elliptic curves will equal an algebraic integer. This property of j-invariants is important, as we will see in a moment.

SIDH works with a family of elliptic curves that are supersingular and isogenous - isogenies can be defined between any two curves in the family. SIDH works like this: party A wants to communicate with party B. Each party chooses two curves in the family and each derives a secret value. They select a point on one of their chosen curves and create a kernel mapping to the second curve (Group 1). Through the application of the isogeny formulas that are beyond the scope of this article, inputting their secret value into those functions, each party creates new kernels and new pairs of points (Group 2). These new points are shared between the two parties. A new isogeny is created based on a kernel derived from the shared points (Group 3). Each party runs these Group 3 points through the isogeny formulas as before, again inputting their individual secret values, in order to derive new points and isogenies/kernels (Group 4). Each party computes new coefficients of the new elliptic curves based on the Group 4 isogenies. Finally, each party computes the _j-invariant_ of their latest curve. If the handshake was successful, this j-invariant will be the same for both parties. Similar to the difficulty of determining the prime factors that produced some large number in DH knowing only the large number, given the knowledge of almost all of the information, e.g. the Group 1 and 2 points and the shared Group 3 points, it is very very hard to determine the Group 4 points and thus the j-invariant, thereby securing the communication between the two parties.

### Advantages and Disadvantages of SIDH

Now that we have an understanding of the key exchange process using SIDH, let's look at the advantages and disadvantages of using this PQC function. Most importantly, what is the security guarantee of SIDH? The current research describes the hardness of breaking SIDH, which is the hardness of computing an isogeny between isogenous supersingular elliptic curves, at:

![Hardness of breaking SIDH](/img/sidh/sidh_hardness.jpg)

where _p_ is some long number, e.g. a 768-bit number _2 * 2<sup>386</sup> * 3<sup>242</sup> - 1_ for 128-bit security. As we can see, the hardness difference between a classical computer and a quantum computer is very small, thereby successfully mitigating the threat of quantum computing on secure key exchange.

The biggest disadvantage of SIDH is that it is very computationally expensive, especially when compared to other PQC function families, such as lattice-based cryptosystems (which we will discuss in a later article). This makes the function much slower than its alternatives. This penalty is somewhat softened by the fact that SIDH keys are very small.

If you would like more resources to understand SIDH, I found [this video lecture][sidh video] useful, as well as [this silly metaphor][sidh aliens] about SIDH using aliens. [This article][sidh math] provides a great explanation of the mathematics around SIDH. [Cloudflare][sidh go] also has a very good article describing the mechanics of SIDH, as well as an implementation of SIDH in Go. In the next part of this series, we will examine lattice-based cryptography and the RLWE and NTRU PQC functions.

<small><a name="velu">1</a>: These are known as [Velu's formulas][]. [↩](#f1 "return")</small>

<small><a name="j-invariant">2</a>: For the curious, all elliptic curves used by SIDH are defined by the following j-invariant: [↩](#f2 "return")</small>
![J-Invariant function](/sidh/j-invariant_function.jpg)

[pqc1]: https://blog.quantummadness.com/posts/quantum-mechanics
[what is post-quantum cryptography]: https://downloads.cloudsecurityalliance.org/assets/research/quantum-safe-security/what-is-post-quantum-cryptography.pdf
[Quantum cryptography]: https://en.wikipedia.org/wiki/Quantum_cryptography
[Shor's Algorithm]: https://en.wikipedia.org/wiki/Shor%27s_algorithm
[Grover's Algorithm]: https://en.wikipedia.org/wiki/Grover%27s_algorithm
[supersingular isogenies]: https://en.wikipedia.org/wiki/Supersingular_isogeny_key_exchange
[Supersingular Isogeny Diffie-Hellman]: https://www.lvh.io/posts/supersingular-isogeny-diffie-hellman-101.html
[elliptic curve cryptography]: https://blog.cloudflare.com/a-relatively-easy-to-understand-primer-on-elliptic-curve-cryptography/
[Weierstrass form]: https://en.wikipedia.org/wiki/Weierstrass%27s_elliptic_functions
[point at infinity]: https://en.wikipedia.org/wiki/Point_at_infinity
[isogeny]: https://en.wikipedia.org/wiki/Isogeny
[morphism]: https://en.wikipedia.org/wiki/Morphism
[_supersingular_ elliptic curve]: https://en.wikipedia.org/wiki/Supersingular_elliptic_curve
[j-invariants]: https://en.wikipedia.org/wiki/J-invariant
[sidh video]: https://www.youtube.com/watch?v=PW5Vsu57o9I
[sidh aliens]: https://gist.github.com/defeo/163444a53252ba90cca6a3b550e6dd31
[Velu's formulas]: https://eprint.iacr.org/2011/430.pdf
[formulas grammarist]: http://grammarist.com/usage/formulas-vs-formulae/
[Diffie-Hellman]: https://security.stackexchange.com/a/45971
[sidh math]: https://crypto.anarres.info/2017/sidh
[sidh go]: https://blog.cloudflare.com/sidh-go/
