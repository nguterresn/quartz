---
title: The significance of handling errors gracefully
tags:
  - Python
date: "2024-09-14"
---

I've decided to write this after a meeting I had with a coworker. We were having a coding live session where we would point out things we could improve and tweaks we could add to turn things a bit more scalable. The coding language was Python, but honestly speaking, this could be almost about any languague.

The program we were reviewing had to do a few tasks — some successively, others sporadically. However, the program would _crash_ in case of an error, even when caught. Moreover, we were using this approach to test: we would assert against an exception.

Nevertheless, the end goal of the program was achived - it worked - and the errors were being caught during the unit test phase. However, this way of developing is _conceptually wrong_.
When one recommends to handle the errors gracefully, is to avoid crashing a program due to one or more defined behaviour.

When an exception is _raised_, it should come as an undefined behaviour and not as an known error (defined behaviour). On a simple `try`/`catch` pair, the error can be gracefully managed:

```python
try:
  function_that_can_crash(first_argument, second_argument)
except Exception as e:
  # Or do something else with the error, e.g. log, print
  return e
else
  return 0
```

And NOT as something like:

```python
try:
  function_that_can_crash(first_argument, second_argument)
except Exception as e:
  raise Exception
else
  return 0
```

In the first example, the exception is correctly caught and transformed into a _error_ value. In the second example, the exception leads the program to crash.

Now, why is this so important? As I stated before, the program does a bunch of stuff which we can split in:

- Feature A
- Feature B

In the most recent code changes, the feature A codebase was slightly altered. Eventually, an exception is raised and the program crashes. The has it program crashed over changes on feature A and can't both. However, in case where the errors are gracefully managed, the user could still use the feature B where the feature A would just not work as expected.







