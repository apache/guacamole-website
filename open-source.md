---
layout: page 
title: Open Source
permalink: /open-source/

menu-title:  Contributing
menu-weight: 6
---

Guacamole is an open source project. It is entirely free in every sense (under the [MIT license](http://opensource.org/licenses/MIT)), and will always be so. It is supported by [Glyptodon LLC](http://glyptodon.org/), the company that formed out of Guacamole's creation, through donations to the project from the community, and by corporate sponsors that fund changes for the benefit of the community.

We believe this gives Guacamole distinct advantages over purely-commercial alternatives. It's open source nature means that the codebase is readily modifiable and extendable. It can be embedded in whole or in part in other projects. Because the source is publicly viewable, effort is made by the Guacamole team to keep the codebase clean and readable. As such, Guacamole is not a "black box"; you can read through the codebase and see exactly what it does and why. Commercial support is available, but because the source is open, there is no aspect of vendor lock-in to this support.

The MIT License
------------------------

The MIT license is exceedingly simple, and only three paragraphs long:

    Copyright (c) <year> <copyright holders>
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.

Guacamole is not public domain, but the MIT license is very permissive, and as long as you follow it's simple conditions ("The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software"), you can modify and include Guacamole in other projects to your heart's content, including commercial or proprietary projects.

Contributing {#contribute}
-----------------

If you believe you have a feature or bug fix that would benefit the project, feel free to contact us via IRC or email, or open a new ticket on [JIRA](https://glyptodon.org/jira/) with your patch attached. Code contributions are also always welcome, but do have to go through a review process. The code will more than likely be discussed and sent back a few times in order to bring the style and implementation in line with the rest of the Guacamole codebase. Alternatively, if you want to prioritize and fund specific changes to Guacamole, this is one of the main reasons [Glyptodon LLC](http://glyptodon.org/) was founded.

If you are planning to contribute code to the upstream project, you absolutely __must__ develop against the code from our [git repositories](https://github.com/glyptodon/). Patches against releases and copies of entire files will not be accepted, and we will need a [signed CLA](http://glyptodon.org/cla.html) on file, to ensure we have the legal right to include your code. Our full contribution guidelines can be found in the "CONTRIBUTING" file of either the guacamole-server or guacamole-client git repositories.

Another great way to pitch in is to actively help other users on [JIRA](https://glyptodon.org/jira/), in [the Guacamole forums](https://sourceforge.net/p/guacamole/discussion/), or on IRC. We have two IRC channels on irc.freenode.net: #guacamole-dev, which is development specific, and #guacamole-help, which is dedicated to generic help and support.

Finally, if you would like to simply donate money to the project, thank you! Such donations show appreciation and help fund further development.

<form class="standalone"
      action="https://www.paypal.com/cgi-bin/webscr"
      method="post" target="_top">

    <!-- PayPal parameters -->
    <input type="hidden" name="cmd"              value="_s-xclick">
    <input type="hidden" name="item_name"        value="Donation to Guacamole">
    <input type="hidden" name="hosted_button_id" value="53Z55SN74N9SS">

    <!-- Donate button -->
    <input type="submit" class="donate"
           value="Donate with PayPal"
           onclick="piwikTracker.trackGoal(6)">

</form>

Development {#develop}
-------------------

Public discussion of development efforts is done over IRC at freenode.net on the #guacamole-dev channel. If you wish to develop a Guacamole-based web application, or to develop new protocol support plugins for guacd, please consult the [API documentation](/api-documentation).

If you need help getting started, the manual contains several tutorials:

* [Adding protocol support](/doc/gug/custom-protocols.html)
* [Custom authentication](/doc/gug/custom-authentication.html)
* [Writing your own Guacamole-based application](/doc/gug/writing-you-own-guacamole-app.html)

