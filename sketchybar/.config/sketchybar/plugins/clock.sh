#!/bin/bash
#
# Chinese date, matching waybar's `{:L%A %m月%d日 %H:%M}` exactly.
#
# LC_TIME rather than LC_ALL or LANG: this is the only thing on the bar that
# should localise, and a blanket LANG would also flip the collation the
# workspace and taskbar scripts sort under.
#
# 24-hour on purpose, as on Linux: macOS renders %p in zh_CN as a literal
# "PM", not 上午/下午, so a 12-hour format would leave an English fragment in
# an otherwise Chinese string.
#
# %A is the full weekday (星期四); %a would give the bare 四. Month precedes
# day because Chinese orders date parts largest-to-smallest, so 08月06日 is
# the conventional form.
#
# %m/%d rather than %-m/%-d: BSD date does support the `-` no-padding flag,
# but waybar's libfmt does not, and an unpadded Mac beside a padded Linux box
# is a difference with nothing behind it.

sketchybar --set "$NAME" label="$(LC_TIME=zh_CN.UTF-8 date +'%A %m月%d日 %H:%M')"
