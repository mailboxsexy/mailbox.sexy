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
# Use this variable when you want to spit more info about what's
# happening
verbose_flag := -v
dev_null :=
endif

# Don't show commands by default and some variables to skip output
ifeq ($(V),)
D := @
# Make programs not spit anything
quiet_flag := -q
verbose_flag :=
# &>/dev/null is shorter but not supported by ash?
dev_null := >/dev/null 2>&1
endif

# Call this variable with a short text to show a waiting message
# $(call msg,Nobody expects the Spanish Inquisition!)
msg = @ printf "$(color_yellow)%b$(color_off)"

# Call this variable alone to show a DONE message
# $(call done)
done = @ printf "%b\n" "$(color_green)\t✔$(color_off)"

# Print information about a variable
# $(call info_about_var,variable_name)
info_about_var = @ printf "%-$(large_col_size)b\t%b\n" "$(color_green)$1" "$(color_blue)$($1)$(color_off)"

# Runs command inside Alpine
run_alpine = $D systemd-nspawn $(quiet_flag) -D $(work_dir) -M $(mailbox_domain)

# Configures postfix
postconf = $(run_alpine) /usr/sbin/postconf -e

# This target builds any template using the variables defined in the
# makefile.  If you need to leave a literal $variable, just define a
# variable like this
#
# variable := $$variable
#
# It's a dirty hack to replace the variable by itself.  Otherwise
# `envsubst` will remove the variable and you'll end up with a broken
# template.
#
# Where the templates are:
render_template := $(tmp_dir)/templates
# To render a template, call it like this
#   target: $(render_template)/the_template
$(render_template)/%: templates/%.in
	$D mkdir -p $(dir $@)
	$D envsubst <$< >$@

# Useful for enabling services
rc_update := $(work_dir)/etc/runlevels
# This is a magic rule to enable OpenRC services
$(rc_update)/%:
	$(msg) 'Enabling $(notdir $@)'
	$(run_alpine) /sbin/rc-update $(quiet_flag) add $(notdir $@) $(notdir $(dir $@))
	$(done)
