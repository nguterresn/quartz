---
title: How to drive a 2 wheels bot
tags:
  - Robotics
  - ESP32
  - BattleButBot
date: "2024-07-27"
---

## Introduction

Having two motors to drive on a bot, how can one make it turn left? Or right?
The premisse is quite simple:

- To turn right while going forward, the left motor should drive _faster_ than the right one.
- To turn left while going forward, the right motor should drive _faster_ than the left one.

The inverse happens when the bot is driving backwards and the same can be acheived, just in a different perspective, by driving one motor _slower_ than the other.

The most basic approach to the premisse exposed above would be to, when aiming to turn the bot, drive one motor and stop the other one. In _pseudo code_ would be something like:

```C
// To turn right
motor_left(ON);
motor_right(OFF);

// To turn left
motor_left(OFF);
motor_right(ON);
```

The above idea could somehow work, but it would be extremely unlikely to produce any satisfatory outcome. The driving wouldn't be smooth and it would highly depend on the time the bot has configured to turn.

## Smoother driving

To achieve a smoother driving, the bot would have to be able to turn slowly or quickly, depending on the controller's input.

From now on, let's use a scale of 0 to 100 to materialize the velocity of the motors, where 0 is when a motor is not spinning and 100 is when it's spinning at maximum speed.

Changing just the speed of each motor, it could be possible to take the last _pseudo code_ example and tweak it a bit:

```C
// To turn right
motor_left(100);
motor_right(50);

// To turn left
motor_left(50);
motor_right(100);
```

Instead of turning off the motor, it could remain powered, but spinning less than the other. However, this would result in the same conclusion as in [the previous section](#introduction).

### Using a 2 dimensions axis direction

Ideally, one would want to be able to change the speed of `motor_left` and `motor_right` based on a input. Conceptually speaking, a two axis controller, such a joystick, would fit within the requirements. Both axis, X and Y could be used to tweak the spinning speed of each motor.

Let's take a look at the 2D X and Y axis:

![2D axis](../img/Axis2d.png)

Following what has been said, the small circle in red should lead to a slow forward right turn and the circle in blue should lead to a faster forward right turn.

Essentially, the one in red could have the left motor at full speed and the right one at slightly less speed.

![AxisRedExample](../img/AxisRedExampleTurn.png)

By contrast, the blue example would still have the left motor at full speed, but the right one would be slower. This results in a quicker turn to the right.

![Axis Blue Example](../img/AxisBlueExample.png)

### Slow down

The goal has always been to slow down one of the motors, but where should the speed be set from?

By looking at the [2 axis scenario](#using-a-2-dimensions-axis-direction), when the right motor speed decreases, so does the value of Y. Essentially, the speed of the right motor, can be based on something that relies on the axis Y.

Both arrows, the red and blue, materialize the maximum speed of the left motor and can be interpreted as hypotenuses. When one of the hypotenuses has a angle of 90 degress, both motors spin at the same speed. Therefore, the speed of the right motor should be based on the _opposite_ side of a triangle:

![Opposite side of the triangle](../img/OppositeAxis.png)

![Opposite site turn](../img/SpeedOpposite.png)

The desired opposite side Y value can be measured by:

```C
#define SPEED_VALUE 100

uint8_t motor_left_speed = SPEED_VALUE;

double z = atan2(y, x);
uint8_t motor_right_speed = SPEED_VALUE * sin(z); // Always eq or less than 100
```

> [!info]
>
> The double variable _z_ is in radians, not degrees.

This ensures the bot has a smoother turn and its behaviour is based on a Joystick controller, the direction of the bot is pretty much figured out. However, this is not enough — there is something missing.

### Same direction, different speed

Instead of focusing only on one motor, the focus should be on both. The direction is set: the bot will turn left or right based on a turn angle. But, what if the same turn needs to performed quicker? Or slower?

There is a need for one more Joystick – one which only controllers how fast a angle based turn should be done.

![Rad Speed Example](../img/AxisRadSpeedBased.png)

The speed should be based on this newly added joystick, while the direction (how the bot turns) should be managed by the second joystick.

```C
int speed = analogRead(JOYSTICK_1_SPEED);
int direction_y = analogRead(JOYSTICK_2_Y);
int direction_x = analogRead(JOYSTICK_2_X);

double z = atan2(y, x);
uint8_t speed_sin_y = speed * sin(z);
// To turn right
motor_left(speed);
motor_right(speed_sin_y);

// To turn left
motor_left(speed_sin_y);
motor_right(speed);
```

That's all folks! Have safe drives ;)

