---
layout: post
title: "Demystifying SOP and CSP, featuring CORS"
description: "Breaking down these crucial web security controls for any developer to understand."
tags: development appsec
---

In my experience, many developers are not aware of the Same Origin Policy nor of the Content Security Policy, or at least were not aware of more than one or two of the directives CSP supports. Let's lay out what these terms are and how they drastically improve the security of the web.

[Mozilla's MDN][mdn] docs describe the following:

[Same Origin Policy][sop] :
> Restricts how a document or script loaded from one origin can interact with a resource from another origin. It helps to isolate potentially malicious documents, reducing possible attack vectors.

[Content Security Policy][csp] :
> An added layer of security that helps to detect and mitigate certain types of attacks, including Cross-Site Scripting (XSS) and data injection attacks. These attacks are used for everything from data theft to site defacement to distribution of malware.

Great! Mystery solved, we can go home. You are now enlightened.

No? Ok, let's break these terms down.

## Same Origin Policy

The Same Origin Policy (SOP) is really the base of the web security model. Under this model, each website is given its own origin sandboxed from the rest of the internet. These isolated origins cannot read or modify data from another origin. This means that resources on one origin, such as JavaScript, cannot modify or read data from another origin. SOP is enforced by the browser. Its restrictions can be relaxed via a server response header, which we will discuss in a moment.

SOP will group resources under the same origin if they have the same three properties:

1. Host
1. Protocol
1. Port

The following interactions are prevented due to SOP:

![Different host SOP violation](/img/sop_csp/sop_host_malicious.svg)

Since mysite.com and malicious.com are clearly different hosts, SOP blocks data sharing between these separate origins.

![Different protocol SOP violation](/img/sop_csp/sop_protocol.svg)

Even though we are now under the same host, HTTPS and HTTP are different protocols, so SOP prevents data interaction and separates these two origins.

![Different port SOP violation](/img/sop_csp/sop_port.svg)

Since 443 and 4443 are different ports, SOP blocks data interaction and separates these two origins.

![Different subdomain SOP violation](/img/sop_csp/sop_host_mysite.svg)

Similar to the first example, subdomains are considered separate hosts. SOP will block data interaction between two subdomains.

### Understanding the Same Origin Policy

Of course, this might beg the question, 'but I need to access files from another origin! I have a CDN I pull jQuery from, I have analytics I need from Google, NewRelic is monitoring my site, and I have a subdomain I need to modify!'

Well, those will all work. SOP blocks data sharing from separate origins, __based on where the resource is executed__. JavaScript pulled from another origin and executed on your site is relegated to your site's origin. The exception is another subdomain on your site, which is not allowed by SOP.

### Enabling Subdomains Through SOP

In order for two subdomains of the same superdomain to share data, [you must redefine the __root domain__][change domain] for those subdomains. For example, if __a.mysite.com__ and __b.mysite.com__ wanted to read or modify data from each other, SOP would prevent that behavior. To change this, __a.mysite.com__ and __b.mysite.com__ must both run a script that sets:

{% highlight javascript %}
document.domain = "mysite.com"
{% endhighlight %}

Since __mysite.com__ is a superdomain of __a.mysite.com__, this setting is allowed (same for __b.mysite.com__). You are forbidden from changing your document's domain to one that you do not control. Running `document.domain = "google.com"` on the site __a.mysite.com__ will fail.

![SOP superdomain violation prevented](/img/sop_csp/sop_domain_violation.svg)

If both __a.mysite.com__ and __b.mysite.com__ change their document's domain to the same superdomain, suddenly both share the same host, port, and protocol, and SOP will allow data sharing.

![SOP superdomain escalation successful](/img/sop_csp/sop_domain_changed.svg)

Note that the site's port is held separately by the browser. Any time a call is made to set the value of `document.domain`, the domain's port value for SOP is set to `null`. This is done to prevent a situation where __a.mysite.com__ wants to modify data on __mysite.com__, so __a.mysite.com__ changes it's `document.domain` to `mysite.com`. The host value now matches, but __mysite.com__ may not want to give a subdomain permission to read or modify its content. Since a call to set `document.domain` was made on __a.mysite.com__, that subdomain's port value was set to `null`. If __mysite.com__ does not similarly make a call to set `document.domain = "mysite.com"` (yes, even though it's already `mysite.com`), then the port values for __a.mysite.com__ (`null`) and __mysite.com__ (80 or 443, presumably) will not match, ensuring SOP continues to prevent data sharing.

![SOP superdomain escalation failed](/img/sop_csp/sop_domain_failed.svg)

<!-- markdownlint-disable MD026 -->
### So what does SOP allow?
<!-- markdownlint-enable MD026 -->

SOP allows pretty much all resources __executed on your site__ to run cross-origin writes. This means that:

- `script src="..."></script>`
- `<link rel="stylesheet" href="...">`
- `<img>`, `<video>`, `<audio>`, `<object>`, `<applet>`
- Any `<iframe>` or `<frame>`

can write data to your page. These resources cannot typically read data from your page due to the SOP, only write to it. A Content Security Policy will protect your site from the actions of these resources, which we will discuss momentarily.

#### `about:blank` and `javascript:`

Note that scripts executed from pages with an `about:blank` or `javascript:` URL inherit the origin of the document that opened the URL. This means that [Cross-Site Scripting][xss] (XSS) execute with the inherited origin of the page it is running on. Also, code that opens a new tab/window can then write content into it, as the new tab/window inherits the origin of the page that created it. The former is bad. The latter can be "business as usual," but is often abused by malicious ads and adware (ALERT! YOUR COMPUTER HAS 37 VIRUSES CLICK HERE FOR A FREE SCAN!).

> ### Let's be clear here. CORS is an _anti-security_ mechanism.

## Cross-Origin Resource Sharing

In order to allow other origins to read data from your site, you must relax your SOP. You do so by defining a [Cross-Origin Resource Sharing][cors] (CORS) policy. CORS is applied via an HTTP header and allows access to resources from whitelisted domains. In a CORS header, you define the set of origins permitted to read data from your site. When a CORS violation occurs, the offending JavaScript does not receive any information about why its request failed, beyond that it did fail.

__Let's be clear here. CORS is an _anti-security_ mechanism.__ The security control is Same Origin Policy, implemented by default by your browser. By setting a CORS header, you are _disabling_ security controls on your site to serve certain content. This is not necessarily a bad thing and there are legitimate reasons to relax SOP in order for your website to function, but that context is important. I frequently see developers asking how to set up the CORS security control. You don't. You only disable it in increments.

A CORS policy is set on the `Access-Control-Allow-Origin` header. In this header, you list a series of space-separated URLs that are allowed to bypass SOP restrictions (remember, this is for those whitelisted sites to read or modify data on your site, not the other way around). I often see the insecure `Access-Control-Allow-Origin: *` set as the value for the header. What are we saying with this CORS policy? We are saying that _any_ site on the internet has permission to read or modify data on our site. That is certainly easier than defining and maintaining a whitelist of sites that need access, but let's please stop doing this, ok? An overly-permissive CORS policy, such as `*`, leads to [plenty of valid attacks][cors attacks]. The article mentions that `Access-Control-Allow-Origin` support in browsers is minimal. I want to point out that the article was written in 2016. By now, this header is supported [in every browser][cors support]. The attacks are still valid on misconfigured CORS policies.

### Preflight Requests

Some request methods require an additional preflight request to be sent before making the cross-origin request. A [preflight request][preflight] is an OPTIONS request automatically issued by a browser. This occurs when making a cross-origin request that changes state, with a request method other than GET or POST or when using certain non-whitelisted headers. The details are outlined [here][preflight details] but, again, your browser will issue this automatically as needed.

## Follow-up on CORS

For more information on CORS, I strongly recommend this video from Derbycon 2019: "To CORS, The Cause and Solution to Your SPA Problems."

[![CORS video](http://img.youtube.com/vi/tH-HG4b4GYQ/0.jpg)](http://www.youtube.com/watch?v=tH-HG4b4GYQ "To CORS: The Cause of and Solution to Your SPA Problems")

The presenters explain CORS in the most understandable format I've yet seen and show how nearly _every_ language's CORS libraries set insecure CORS defaults.

## Content Security Policy

Ok, so now we have a pretty good understanding of SOP and how CORS is used to relax SOP restrictions. Let's talk about where Content Security Policy (CSP) fits in.

CSP is a policy defined on the `Content-Security-Policy` HTTP header. A legacy version of the header was `X-Content-Security-Policy`. Use the current version. CSP's primary purpose is to prevent Cross-Site Scripting (XSS) attacks. XSS works by tricking a browser into running script under your site's origin, giving the malicious code access to read or modify the site content. We should not trust what we cannot verify!<sup id="f1">[1](#sri)</sup> The CSP allows us to define a whitelist of sources of trusted content. The browser will not execute or render any resource outside of that list. If an attacker is able to inject script on your site, the script will not run as it will not match the whitelist. The CSP header can be made up of [a number of different directives][csp directives].

An example CSP might look like:

{% highlight javascript %}
Content-Security-Policy: script-src 'self' www.google-analytics.com
{% endhighlight %}

`script-src` is a CSP directive. It allows you to define the whitelist of acceptable sources for JavaScript on your webpage. In this example, we are allowing JavaScript from `self`, our current page's origin, and any resources requested from `www.google-analytics.com`. Any script that tries to execute on the webpage that does not come from these two sources will be blocked by the browser.

The error will look like this:

Chrome:

> Refused to load the script 'script-uri' because it violates the following Content Security Policy directive: "your CSP directive".

Firefox:

> Content Security Policy: A violation occurred for a report-only CSP policy ("An attempt to execute inline scripts has been blocked"). The behavior was allowed, and a CSP report was sent.

### CSP in Reporting Mode

As the Firefox error suggests, CSP can be set to a "blocking" mode or a "reporting" mode. Under reporting, CSP will not block any content, just echo the alert onto the browser console. You must set the `report-uri` directive under reporting mode to a web endpoint set up to collect CSP error messages. Upon a CSP violation, the user's browser will POST the violation error in JSON to the configured endpoint. One such service to monitor those violations for your site is [Report URI][report uri]. The purpose of the reporting mode is to ensure you understand where all the resources on your site are coming from before fully enabling CSP and potentially breaking your site. You should keep a `report-uri` directive on your "blocking" policy to continue to be alerted to the types of attacks being made against your site and to warn about any potential CSP misconfigurations.

Use `Content-Security-Policy-Report-Only` as the header to set CSP in reporting mode. Use `Content-Security-Policy` as the header when you are ready for CSP to begin blocking content.

### Inline JavaScript

The inclusion of a CSP blocks any inline JavaScript and dynamic code evaluation by default, so injected JavaScript cannot assume your site's origin. This does mean that the webpage's trusted JavaScript must come from a JavaScript file and cannot be written in-line. That is a bad design pattern so you can now justify that refactor on the basis of improving security. In the event that you do want either of those features enabled under CSP, you would set your CSP like so:

{% highlight javascript %}
Content-Security-Policy: script-src 'unsafe-inline' 'unsafe-eval'
{% endhighlight %}

This policy allows inline JavaScript and dynamic code evaluation, respectively. But don't do that. Allowing inline scripts puts XSS strongly back on the table, whereas it would otherwise be blocked.

Note that `unsafe-inline` includes `style` tags as well as `javascript:` URLs. All styling must similarly occur in a separate file, not inline. But it bears repeating - preventing inline scripts is the strongest benefit of CSP. Do not enable this policy!

### CSP Directives

There are a [number of other CSP directives][csp directives] and I strongly encourage you to read through them via the linked page. Some notable directives:

`default-src`: Apply a default CSP against all resources, overriden by the specific CSP directives such as `script-src`.

`form-action`: Whitelist valid endpoints for `form` submissions.

`frame-ancestors`: Define what sources are allowed to embed your webpage, such as render inside an `iframe` on their site. Enabling this directive blocks [clickjacking][], so enable it!

`sandbox`: Enable an iframe-like sandbox for the requested content and apply a CSP to it. An empty value for the `sandbox` directive applies all restrictions to the content, which can be selectively enabled via values such as `allow-forms`. This directive is a little different, as it prevents actions the page can take rather than what resources the page can load. If specified, a page is treated as though it is loaded via an iframe, creating a wide range of effects. More details on the effects of sandboxing can be found [here][sandboxing spec]. This feature opens up a lot of possibilites for securely locking down areas of your site.

`require-sri-for`: Require the use of [Subresource Integrity][sri] for scripts and styles on the page. The value options for this directive are `script` and `style`.

`upgrade-insecure-requests`: Instructs browsers to upgrade any HTTP links on the webpage to HTTPS. This is a simple way to upgrade a legacy page with many HTTP links to HTTPS.

You should note that including a directive without defining a whitelist defaults that directive to `*`, which means allow everything. Specifying a `default-src` directive overrides this behavior, naturally.

### Crafting a CSP Policy

[Google's CSP page][google csp] has excellent guidance, with examples, on crafting a CSP from scratch. The goal is to identify what resources your site is actually loading and setting up a policy based on that information.

## That's a Wrap

I hope this article is a useful resource toward understanding SOP, CORS, and CSP and starts you on the path to enabling CORS and CSP correctly on your sites, if they are not already implemented.

<small><a name="sri">1</a>: Requests for static resources, e.g. vendored scripts that you know will not change, should use [subresource integrity][sri] as the verification mechanism for those resources. [↩](#f1 "return")</small>

[mdn]: https://developer.mozilla.org/en-US/
[sop]: https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy
[csp]: https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
[xss]: https://www.owasp.org/index.php/Cross-site_Scripting_(XSS)
[cors]: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
[preflight]: https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
[cors followup]: https://enable-cors.org/index.html
[change domain]: https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy#Changing_origin
[preflight details]: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#Simple_requests
[cors attacks]: https://portswigger.net/blog/exploiting-cors-misconfigurations-for-bitcoins-and-bounties
[sri]: https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity
[csp directives]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy#Directives
[clickjacking]: https://www.owasp.org/index.php/Clickjacking
[Report URI]: https://report-uri.com/
[sandboxing spec]: https://html.spec.whatwg.org/dev/origin.html#sandboxing
[google csp]: https://developers.google.com/web/fundamentals/security/csp/#real_world_usage
[cors support]: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#Browser_compatibility
