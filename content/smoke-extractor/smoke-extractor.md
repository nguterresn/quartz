---
title: How can you make your own portable Smoke Extractor
tags:
  Electronics
date: "2022-07-31"
---

### Introduction

One of my [2022 goals](year-2021-recap.md) was to _create_ something - a product or a service. Since then, I've been working on a personal, portable and small **smoke extractor**.

![Smoke extractor gif](img/se_gif.gif)

I started learning about DC/DC Boost Converters when I noticed the fans that required more power were not supplied with 5V, they were, instead, supplied with 12V or 24V. This finding pushed me into learning about [boost converter's hardware design](boost-converter.md) and requirements which would lead to my end goal.

### Design and challenges

After learning about the boost converters, the design part was the _next big thing_. Designed the entire case and tried to keep a minimalist look while minimizing any empty spot and creating a solid aesthetic object.

![Front Render of the Smoke extractor](img/FRHvhZbXMAE5xFc.jpeg)

![Back Render of the Smoke extractor](img/FRHvhtBXIAIHwYs.jpeg)

The renders above are from my the first attempt to finish the design. And, as always tends to happen, the design was far from finished. My first idea was to split the case in two:

* the front, which would take the pcb and the smoke filter.
* the back, which would act like a lid and would have some screws to attach the design together.

After the first printing attempt, I realized right away this was not the best idea - the front part was hard to print, specially on the side part where the smoke extractor is (even with printed supports, the print had a bad quality). Therefore, the solution was to split the design in three parts, adding a middle layer which holds both front and back together.

![Front Final Render of the Smoke extractor](img/front-sep.png)

![Back Final Render of the Smoke extractor](img/back-sep.png)

![Complete Final Render of the Smoke extractor](img/complete-sep.png)

Also, if you were attentive, you could notice the back from the first renders didn't have the honeycomb pattern. The older back was way too weak and was causing the fan to bend backwards, mainly caused by the screws force on the bottom. The new back is robust enough.

### One smart fool

Until this point, the project looks awesome, right? I thought so. However, this project was (and is) supposed to be open-source but there are no files or documentation about it. Let me explain.

I've started this project with the [boost converter PCB](boost-converter.md), but eventually I aimed for more - I wanted to learn more about electronics and PCB design. Something which started to be a single boost converter board that would convert 5V to 12V, became a _battery-powered-charged-converter-from-3.7V-or-5V-to-9V-or-12V_ - **complex enough**.

I lost the motivation right away. Every right step, every successful design, I would add more complexity in each of them.

![Smoke extractor Version 1.1 Overengineering](img/smoke_extractor_1_1.png)

My worst enemy was no one but myself. Realized this when the design, together with the single boost board PCB, turned out to be an amazing prototype. However, as I had already added more complexity on top of it, no longer had the files to share.

In my opinion, **Albert Einstein** described this problem accurately:

> _Any intelligent fool can make things bigger, more complex, and more violent. It takes a touch of genius - and a lot of courage - to move in the opposite direction._

It is time to have this touch.

### Supply chain and product improvements saved me from self disappointment

Supply chain issues are usually very bad thing and everyone working at a tech company knows what I am talking about. This could be my case if I didn't have to redesign everything from scratch anyway.

Turns out, [the boost converter I have been using the whole time](https://www.digikey.se/en/products/detail/diodes-incorporated/PAM2421AECADJR/4033256), is, for everyone's surprise, out of stock. It _sucks_!... but, comes in the right time as well!

Let's also take this chance to look back and to polish the prototype edges.

### Electrical issues

As for today, the product, in order to work correctly, needs to **draw around 600mA at 5V**. This might change with the next boost converter chip, but this is a good starting point to aim for **80% of efficiency**.

600mA, at most of the USB default ports, is already too much, since most of the USB default ports can only provide current from 100mA to 500mA. When I connected the smoke extractor, fully assembled, to my computers USB dock, it was causing my desk light (also powered by the same dock), to flicker every half a second. Something was not right, pretty obvious huh!

To know more about this issue, I created a post on [Reddit](https://www.reddit.com/r/AskElectronics/comments/vs3w11/question_about_current_draw_from_usb_hub_and/). I wanted to know exactly what was happening and what was I missing. Luckily, an amazing person decided to help me and explain why my desk lamp was flickering:

> Probably overcurrent detection triggering, then resetting and waiting a reasonable time for inrush current to finish before triggering again.

Easy explanation, thanks [triffid_hunter](https://www.reddit.com/user/triffid_hunter/)!

As I was reading his explanation, I knew this had to be fixed. How could I fix this?

Nevertheless, this might not be the problem I think it is. The next board will be battery powered and charged through USB-C. Its normal operation does not include the USB-C input to be the main source power.

### Next changes on version 2.0

For the version v2.0, if I'm even allowed to call it that, the smoke extractor will include a lithium 18350 battery, the charger circuit and consecutive safety circuit (discharge, overcharge, etc) and a battery level button followed by some tiny lights to return feedback to the user.
Addionally, will add the option to purchase the Bill of Materials straight from [JLCPCB](https://jlcpcb.com/parts).

![Smoke extractor v2 front](img/smokeextractorv2.jpg)

![Smoke extractor v2 back](img/smokeextracotrv2back.jpg)

### Version 2.05

I've changed the design a bit. It covers the fan completely and makes the enclosure slightly more sturdy.

![img](../img/FumeExtractorv2.png)

Two boost converters is stupid — single boost converter approach. USB-C can only charge. SMD button was from a really bad quality (hard to click), replaced by a classic TH 6x6mm. 3mm LEDs are a waste of space, current and money, replaced by simple 0603 SMD ones.

![Smoke extractor 2v05 Front](img/SE_2v05.jpg)

### Version 2.06

Previous version had an issue with the battery indicator — it would only work if the battery was charging. That's just a terrible UX.

After researching for a bit, [here](https://www.instructables.com/Li-Ion-battery-level-indicator/) and [there](https://www.youtube.com/watch?v=rZq2v7two1s), I've applied the following circuit:

![Battery Level Indicator](img/BatteryIndicator.jpg)

The circuit below has 1 Red LED, 1 Yellow LED and 2 Green LEDs. The Red LED has a voltage drop of $2.3V$ which allows the circuit to have a _stable_ voltage to measure the battery against. The rest of the circuit follows two rules: the comparator and the voltage divider.

A comparator outputs 1 if the $V_{+}$ is higher than the $V_{-}$.
Afterwards, I just had to come up with a window of values between 0 and $2.3V$ which would fit well within the values of the $V_{-}$ voltage divider, between $1.32V @ 3.2V$ and $1.72V @ 4.2V$.

The resistor values might not be _ideal_ but I prefer to optimize the number of different resistors I need. This will reduce the BOM cost and the time it takes to assemble the board.

After holding it for a bit, I didn't like the [previous enclosure for the smoke extractor](#version-205). The fact that I could harm myself while trying to hold it, made me hate the design. I should be able to use with comfort.

I've added back the [original back part](#design-and-challenges).

### The end

This [previous iteration](#version-206) represents the final revision of the board. I do not intend to make further revisions beyond this point. It has been more than one year since I've started working on this, with a few breaks in the middle.
Overall, I've learned a lot. Not only skill wise but also about planning and organization. Planning is key and simplicity helps — it can save so much time.
I made this for myself, but I hope someone can look at this product and find it useful.
