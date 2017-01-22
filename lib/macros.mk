# Copyright (c) 2017 Mailbox Sexy <hello@mailbox.sexy>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

include lib/colors.mk

# Use V=99 to see all the messages
ifeq ($(V),99)
D :=
quiet_flag :=
verbose_flag := -v
endif

# Don't show commands by default
ifeq ($(V),)
D := @
quiet_flag := -q
verbose_flag :=
endif

msg = @ printf "%b\t" "$(color_yellow)$1$(color_off)"
done = @  printf "%b\n" "$(color_green)[DONE]$(color_off)"
info_about_var = @ printf "%-$(large_col_size)b\t%b\n" "$(color_green)$1" "$(color_blue)$($1)$(color_off)"
