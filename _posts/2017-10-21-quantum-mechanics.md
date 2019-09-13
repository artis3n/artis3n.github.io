---
layout: post
title: "Post-Quantum Cryptography, Part 1: Quantum Computing"
description: "In which we establish a baseline of knowledge on quantum mechanics and its implications on computing."
tags: quantum crypto
---

![Quantum header](/img/quantum_cryptography/quantum_header.jpg)
> Anyone who can contemplate quantum mechanics without getting dizzy hasn't understood it.

\- _Niels Bohr, one of the fathers of quantum mechanics_

I would like to begin a series examining the various post-quantum cryptography schemes being explored by [NIST's Post-Quantum Cryptography][NIST pqc] project. To do so, I must begin with a brief overview of quantum mechanics. This post will cover this brief history and touch on quantum computing's impact on classical encryption standards. Follow-up articles will discuss the proposals for post-quantum cryptography. I have undergone no formal study of quantum mechanics, but I will try my best to illustrate the relevant points. This information is based on papers and articles I have read; I make no claim to being a quantum mechanics expert.

[NIST pqc]: https://csrc.nist.gov/Projects/Post-Quantum-Cryptography

### The Double-Slit Experiment

In 1801, a scientist named Thomas Young performed an experiment<sup id="f1">[1](#young)</sup> involving light and the behavior it exhibited when shone against a screen with two slits. Young observed that the light, instead of displaying two bars of light as he would have expected when shown against two slits in a screen, fanned out in a pattern of light and dark stripes. Young hypothesized that light was a form of wave, which would explain the pattern of stripes. As the wave of light hit the screen, it bent around the slits and collided with itself, creating the pattern of stripes. Young's [double-slit experiment][] demonstrated that light behaves like a wave.

Albert Einstein, however, had a different theory. He argued that only if light were actually made up of tiny particles - photons - could this effect - later known as the photoeletric effect - of the pattern of stripes be explained. If light were a series of photons, then the beam of light hitting the screen scattered the beam of photons. The individual particles interacting with each other on the other side of the slits created the pattern of dark and light stripes. Einstein hypothesized this in 1905, although he was not believed at the time. Einstein ended up winning the Nobel Prize for his paper on this topic. We now know that light can, in fact, behave as both a wave and a particle. This concept is known as [wave-particle duality][].

Modern physicists, recreating a form of Young's experiment, sent individual photons through a two-slit screen. The expectation was that the pattern of stripes behavior would not occur, as only a single photon was sent through the screen at a time. However, the results displayed the same pattern of stripes, as if the photons had been interacting as in the earlier experiments. Moreover, when the physicists put measuring devices on the slits themselves, they found that the pattern did not occur. In both cases a single photon was sent toward the slits; however, only in the latter instance, when the photon was measured at the slit itself, did the photon behave as the physicists expected. It was as if the act of measuring the photon changed the fundamental behavior of the particle. This confounded physicists. There is no explanation for this behavior in classical physics.

It is, instead, explained by [quantum physics][].

There are two theories among quantum physicists to explain the pattern of stripes behavior of the single photon experiment.

[double-slit experiment]: https://en.wikipedia.org/wiki/Double-slit_experiment
[wave-particle duality]: https://en.wikipedia.org/wiki/Wave-particle_duality
[quantum physics]: https://en.wikipedia.org/wiki/Quantum_mechanics

### Superposition

The first theory is [superposition][]. This idea focuses on what we know of the photon. We know that it leaves its original filament and we know that it strikes the screen somewhere. Everything else about the state of the photon is unknown. Because the path of the photon is unknown, superposition states that the photon passes through both slits simultaneously. Its two states interfere with each other as if two photons were colliding and that is why the striped behavior is observed. How can the single photon pass through both slits? Superposition argues, essentially, that if we do not know what the particle is doing, then it is doing everything. The photon is in a [superposition of states][]. This idea is popularly known in the parable of Erwin Schrödinger's cat thought experiment. [Schrödinger's cat][] is the idea that the state of a cat in a box with a vial of cyanide is unknown. Either the cat is alive or it has trodden on the vial, shattered it, and is dead. Since the state is unknown, the cat is simultaneously alive and dead. It is in a superposition of states. It is only upon removing the lid, directly interfering to observe, do the states converge on one of the possibilities.<sup id="f2">[2](#schrodinger)</sup>

[superposition]: https://en.wikipedia.org/wiki/Superposition_principle
[superposition of states]: http://physics.gmu.edu/~dmaria/590%20Web%20Page/public_html/qm_topics/superposition/superposition.html
[Schrödinger's cat]: https://en.wikipedia.org/wiki/Schr%C3%B6dinger%27s_cat

### Many-worlds

Are you getting dizzy yet? The alternative quantum theory to the double-slits experiment is no less bizarre. It is known as the [many-worlds theory][]. The theory essentially uses the [Schrödinger equation][] as a literal explanation of the behavior of the universes (yes, we'll get there in a second). The Schrödinger equation is a formula that describes the "changes over time of a physical system in which quantum effects are significant." This equation is in the family of quantum [wave functions][].

A wave function can basically be thought of as a series of probabilities, all adding up to 1. The wave function of a quantum object describes _all_ possibilities the object can undergo. When the object is observed, the wave function collapses into one of those possibilities. While I discuss wave functions here, they are not just a property of the many-worlds theory. They are mathematical functions that describe quantum possibilities, and are used in the literature regardless of the physicist's belief in superposition or many-worlds.

The many-worlds theory states that when the state of the photon (or cat) becomes unknown, the universe divides into _multiple_ universes, one for each possible state. In one universe, the photon goes through the left slit. In another universe, the photon goes through the right slit. These two universes interfere with each other in some way, causing the striped pattern of light. This literal interpretation is known as the [Everett Postulate][]:

> All isolated systems evolve according to the Schroedinger equation

[many-worlds theory]: https://www.thoughtco.com/many-worlds-interpretation-of-quantum-physics-2699358
[Everett Postulate]: https://arxiv.org/pdf/quant-ph/9709032v1.pdf
[Schrödinger equation]: https://en.wikipedia.org/wiki/Schr%C3%B6dinger_equation
[wave functions]: https://en.wikipedia.org/wiki/Wave_function

### The Quantum Computer

Regardless of which theory is correct, quantum mechanics answers many questions about the state of our universe. It also inspired [David Deutsch][], a British physicist, to begin working on the concept of quantum computing.<sup id="f3">[3](#deutsch)</sup> It was commonly assumed that computers operated according to classical physics. Deutsch believed they should instead obey quantum physics, as the laws of quantum physics were more fundamental. In Deutsch's first paper on the subject, he explained how quantum computers might operate. To describe this, I am going to borrow a passage from Simon Singh's excellent book, [The Code Book][]:

> Imagine that you have two versions of a question. To answer both questions using an ordinary computer, you would have to input the first version and wait for the answer, then input the second version and wait for the answer. In other words, an ordinary computer can address only one question at a time, and if there are several questions it has to address them sequentially. However, with a quantum computer, the two questions could then be combined as a superposition of two states and inputted simultaneously - the machine itself would then enter a superposition of two states, one for each question. Or, according to the many-worlds interpretation, the machine would enter two different universes, and answer each version of the question in a different universe. Regardless of the interpretation, the quantum computer can address two questions at the same time by exploiting the laws of quantum physics.

Just as classical computers represent data in bits (either 0 or 1), quantum computers represent data in [qubits][], or quantum bits. A qubit similarly represents either 0 or 1 but does so typically through the polarization of photons. And of course, a qubit can be both 0 and 1 at the same time<sup id="f4">[4](#wave-collapse)</sup>, in a superposition of states (or in a multiverse). Instead of tackling one operation at a time, a quantum computer could tackle x<sup>n</sup> operations at a time, where `x` is the number of directions the system vibrates or spins photons (the number of ways the system measures photons) and `n` is the number of photons available to the system. All current existing quantum computers work on a factor of 2<sup>n</sup>, based on a bit's 0 or 1 value. Depending on your quantum theory, a quantum computer could perform 2<sup>n</sup> operations simultaneously or would, in fact, be 2<sup>n</sup> computers, each in a separate universe, each performing one of the calculations. Are you dizzy now?

It is easy to see why quantum computing poses such a threat to modern encryption. Most encryption algorithms are based on "hard" computer science problems, like [factoring large primes][] or solving certain [discrete logarithm problems][]. These problems become _significantly_ less difficult if you can perform the majority of the calculations simultaneously. However, for some time no one was really sure how to create a quantum computer, or precisely how one could be used to imperil current encryption standards. [Peter Shor][] was instrumental in the latter effort. In 1994, Shor developed an algorithm that could be run by a quantum computer to factor a giant number, say a large prime. [Shor's algorithm][], run on a suitable quantum computer, could be used to break [RSA][]. At the same time, Shor presented another algorithm that could be used by a quantum computer to [solve discrete logarithm problems][]. [Lov Grover's algorithm][] could similarly be used by a quantum computer to logarithmically speed up the amount of time to brute force a solution to symmetric encryption ciphers like SHA and AES.

However, I will not go into quantum cryptanalysis or cryptography further here, as my intention with this series is to discuss post-quantum cryptography. What is the difference between quantum and post-quantum cryptography? I will begin that discussion in the [next part][pqc2] to this series as well as begin to look at the proposed solutions to post-quantum cryprography.

[David Deutsch]: https://en.wikipedia.org/wiki/David_Deutsch
[The Code Book]: https://simonsingh.net/books/the-code-book/
[qubits]: https://en.wikipedia.org/wiki/Qubit
[factoring large primes]: https://en.wikipedia.org/wiki/Integer_factorization
[discrete logarithm problems]: https://en.wikipedia.org/wiki/Discrete_logarithm
[Peter Shor]: https://en.wikipedia.org/wiki/Peter_Shor
[Shor's algorithm]: https://en.wikipedia.org/wiki/Shor%27s_algorithm
[RSA]: https://en.wikipedia.org/wiki/RSA_(cryptosystem)
[solve discrete logarithm problems]: https://crypto.stackexchange.com/questions/9574/what-is-the-difference-between-shors-algorithm-for-factoring-and-shors-algorit
[Lov Grover's algorithm]: http://cryptome.org/qc-grover.htm

[pqc2]: /posts/pqc-proposed-solutions

<small><a name="young">1</a>: He performed a series of experiments to come to these conclusions, but we are simplifying. [↩](#f1 "return")</small>

<small><a name="schrodinger">2</a>: Schrödinger actually created this example to highlight the ludicracy of the idea of superposition. Einstein and he communicated frequently about quantum mechanics, but neither was able to prove that it was innaccurate. They went on the define some of the founding, integral ideas to quantum mechanics. In terms of the cat, the reason it is not - actually - alive and dead is because a cat is on too macro a scale to be defined by quantum properties. Other particles around the cat "observe" it, collapsing its wave function onto either the alive or dead possibility. [↩](#f2 "return")</small>

<small><a name="deutsch">3</a>: Fun fact: Deutsch was a believer of the many-worlds theory. [↩](#f3 "return")</small>

<small><a name="wave-collapse">4</a>: It is a gross over-simplification to say that a qubit can represent both 0 and 1 at the same time. This fact is bandied around in the news when discussing quantum computing in order to avoid getting too technical, but it does mis-represent the actual behavior of a quantum computer. A qubit cannot represent both 0 and 1 - in fact, it doesn't represent 0 or 1, either. A qubit represents a wave function of probabilities - the probability that the value is 0 and the probability that the value is 1. When the qubit's task is completed and the state of the qubit is measured or the qubit [decoheres][], the wave function collapses into one of the probabilities, and the output of the qubit results in 0 or 1. However, the active qubit does not represent 0, 1, or 0 and 1, but the wave function. [↩](#f4 "return")</small>

[decoheres]: https://en.wikipedia.org/wiki/Quantum_decoherence
