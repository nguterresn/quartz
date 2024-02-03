---
title: Board to help you test end of line on your access control system
tags:
  - PCB Design
  - CAD Design
  - Access Control
date: "2023-06-29"
---

I think I've started to work on a [End of Line testing board](https://github.com/nguterresn/end-of-line-board) back in the summer of 2022, but never actually used it or wrote about it. Recently, I've revisited this in order to make it a _releasable_ product.

![render](https://user-images.githubusercontent.com/38976366/162028981-bbf3a0d9-4f4c-46dd-9886-34df5c543ee9.jpg)

Back when I started designing this board, I wrote some documents about the **End Of Line technology** and uploaded it to my github, [here](https://github.com/nguterresn/end-of-line-board/tree/master/docs).

The image above does not mirror how the board is 100% - I've changed the front screw terminals from three 2P to one 6P, reducing the cost and the amount of components to solder. Nevertheless, you can take the 3D view of the PCB down in the [README](https://github.com/nguterresn/end-of-line-board) as the source of truth.


So far, I believe most of the people use **2k2 as the main resistor and 1k as the secondary** one, and, although the board labels state these values, you can use whatever you would like - the footprint is the same (0603).
I've also used push/latch buttons to mock the behaviour of a contact sensor without taking so much space. You can argue that any slide switch would do the same here, but I think we would just end up discussing about personal preferences. I choose these ones because I _do believe_ it is closest to a contact sensor: most of the times is closed (button is pressed) and only is open a few times (button is released).

It is pretty easy to use this board for testing your access control system. As stated before, **whenever the button is pressed it will have the same behaviour as a closed contact sensor**, and the opposite happens when it is released. **The small slider buttons can trigger a _cut_ or a _short_**, and it doesn't matter if the latch button is pressed or released. Each screw terminal output pair should be connected to your access control system.

Just as a final note: the repository doesn't include any BOM file, but the KiCad project as all the symbols used linked with a [LCSC](https://www.lcsc.com) code. So, if you are interested to order the board, and the all the respective components, it should be straightforward.



