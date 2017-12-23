# Simple Textual Battery Monitor for Awesome Window Manager

# About

This is textual battery monitor for the
[Awesome Window Manager](https://awesomewm.org/).
It will show you the current battery charging status and whether AC is connected:

![Bat: 80% +AC](sample.png)

Tested (only basic tests) with Awesome 4.2.


# Installation

Copy (or link) the file `textual_battery_widget.lua` to `~/.config/awesome/`
and add the following to`~/.config/awesome/rc.lua`:

In the beginning (after all the other `require` statements):

    local textual_battery_widget_factory = require("textual_battery_widget")

And then where you want to have the widget displayed 

    textual_battery_widget_factory("BAT1", "ADP1", 30),

The first parameter is the name of your battery as found under
`/sys/class/power_supply/`, the second the name of your adapter and the third
an update period in seconds (which is optional and defaults to 10 seconds).

In my case, it's located between the _systray_ and the _clock_:

    wibox.widget.systray(),
    textual_battery_widget_factory("BAT1", "ADP1", 30),
    mytextclock,


# Unique Selling Point

For people who suffer from
[this bug](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/971061)
or a similar one which makes `acpi` display the wrong status of the battery
charging, this might be useful, as it does not rely on this piece of
information but rather checks, whether the adapter is present or not.


# TODO

- Errors are not really handled: If an error occurs, the widget will just show
  `bat error`.
- Maybe add a _mouse over_ message or a popup if the capacity drops below a
  certain value.
- Factor out (i.e. put in another file) the functions that just read from file.

Feel free to send pull requests :-)


# Other versions

This was inspired by the battery widget of
[streetturtle's `awesome-wm-widgets`](https://github.com/streetturtle/awesome-wm-widgets)
which was too pictorial for me and
[koenw's `awesome-batteryInfo`](https://github.com/koenw/awesome-batteryInfo)
which was not really handy to install.

See also the example in
[awesome's `timer` class](https://awesomewm.org/doc/api/classes/gears.timer.html).


# Alternatives

- I used `batterymon` for a while but wanted to get rid of the
  non-awesome-native stuff in my configuration; also it did not work
  sporadically.
- `cbatticon` might work (I did not test or use this).
