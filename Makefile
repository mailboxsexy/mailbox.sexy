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
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
root_dir := $(patsubst %/,%,$(dir $(mkfile_path)))

# Get the config
include config.mk
# And some macros
include lib/macros.mk

# This is the target run when you run `make`, it shows a helpful
# message.
.DEFAULT_GOAL := help

# Define a temporary directory
tmp_dir := $(root_dir)/tmp
# And create it
$(tmp_dir):
	$(msg) 'Creating tmp dir'
	$D mkdir -p $@
	$(done)

## Download
# 
# Downloads the alpine tarball into the tmp dir
tarball := $(tmp_dir)/$(alpine_file)
$(tarball): $(tmp_dir)
	$(msg) 'Downloading Alpine'
	$D wget '$(alpine_dl)' $(quiet_flag) -O '$@' --no-use-server-timestamps
	$(done)

download: $(tarball) ## Download alpine

## Extract
# 
# Creates a work directory and extracts Alpine into it

work_dir := $(tmp_dir)/alpine-$(alpine_flavor)-$(alpine_full_version)-$(alpine_arch)
$(work_dir): $(tmp_dir)
	$(msg) 'Creating work dir'
	$D mkdir -p '$@'
	$(done)

$(work_dir)/etc/alpine-release: $(work_dir)
	$(msg) 'Extracting tarball'
	$D cd '$<' && tar $(verbose_flag) -xmf $(tarball)
	$(done)

extract: download $(work_dir) $(work_dir)/etc/alpine-release ## Extract alpine to work dir

## Prepare the chroot
#
# This target does some adaptions to make the Alpine chroot work on the
# host system.

# This target runs always because the file already exists
$(work_dir)/etc/inittab: always
	$(msg) 'Configuring inittab'
	$D sed -re 's/^tty/# &/' -i '$@'
	$D grep -qw console '$@' || echo 'console::respawn:/sbin/getty 38400 console' >>'$@'
	$(done)

$(work_dir)/etc/localtime: /etc/localtime
	$(msg) 'Setting local time'
	$D cp -a $< $@
	$(done)

$(work_dir)/var/cache/apk/APKINDEX.%.tar.gz:
	$(msg) 'Updating apk database'
	$(run_alpine) /sbin/apk $(quiet_flag) update
	$(done)
	
prepare_deps := $(work_dir)/etc/inittab $(work_dir)/etc/localtime \
	$(work_dir)/var/cache/apk/APKINDEX.%.tar.gz

prepare: $(prepare_deps) ## Prepares Alpine

## Install
# 
# Install packages on Alpine

packages := postfix postfix-pcre tor dovecot openrc

install: ## Install packages
	$(msg) 'Installing packages'
	$(run_alpine) /sbin/apk $(quiet_flag) --no-progress add $(packages)
	$(done)

## Configure
#
# Run configuration tasks
#

# This file is created by tor on first run
hostname_file := /var/lib/tor/mailbox.sexy/hostname
rc_update     := $(work_dir)/etc/runlevels/default

# This is a magic rule to enable OpenRC services
$(rc_update)/%:
	$(msg) 'Enabling $(notdir $@)'
	$(run_alpine) /sbin/rc-update $(quiet_flag) add $(notdir $@) default
	$(done)

$(work_dir)/etc/postfix/main.cf: always
	$(msg) 'Configuring main.cf'
	$(run_alpine) /usr/sbin/postconf -e smtputf8_enable=no # alpine doesn't build postfix with icu
	$(run_alpine) /usr/sbin/postconf -e smtp_host_lookup=native
	$(run_alpine) /usr/sbin/postconf -e ignore_mx_lookup_error=yes
	$(run_alpine) /usr/sbin/postconf -e smtp_dns_support_level=enabled
	$(run_alpine) /usr/sbin/postconf -e smtpd_relay_restrictions=permit_sasl_authenticated,defer_unauth_destination
	$(run_alpine) /usr/sbin/postconf -e mydestination=$(hostname_file)
	$(done)

postfix: $(work_dir)/etc/postfix/main.cf $(rc_update)/postfix ## Configure postfix

$(work_dir)/etc/torrc: $(work_dir)/etc/tor/torrc.sample
	$(msg) 'Configuring tor'
	$D cp -a $< $@
	$D echo 'HiddenServiceDir $(dir $(hostname_file))' >>$@
	$D echo 'HiddenServicePort 25  127.0.0.1:25'       >>$@
	$D echo 'HiddenServicePort 587 127.0.0.1:587'      >>$@
	$D echo 'HiddenServicePort 995 127.0.0.1:995'      >>$@
	$(done)

tor: $(work_dir)/etc/torrc $(rc_update)/tor ## Configure tor

configure: postfix tor ## Configure mailbox.sexy

## Cleanup
# 
# Remove files from the Alpine chroot that shouldn't be there
# when the system is done installing and it's being packaged.
#
# Add files to remove on the cleanup_deps variable.

cleanup_deps := $(work_dir)/etc/localtime \
	$(work_dir)/var/cache/apk/APKINDEX.*.tar.gz

cleanup: $(cleanup_deps) ## Remove temporary files from Alpine
	$(msg) 'Removing tmp files'
	$D rm -rf $(verbose_flag) $^
	$(done)

## Configuration
#
# Prints the configuration.
#
# TODO just print everything defined on the current makefile.  we could
# use export and `env` but it's mixed with stuff from the parent shell.
config: always ## Show config
	$(call info_about_var,tmp_dir)
	$(call info_about_var,work_dir)
	$(call info_about_var,alpine_flavor)
	$(call info_about_var,alpine_version)
	$(call info_about_var,alpine_full_version)
	$(call info_about_var,alpine_arch)
	$(call info_about_var,alpine_file)
	$(call info_about_var,alpine_dl)

all: config download extract prepare install cleanup ## Run all the targets

boot: ## Boot into Alpine for testing
	$(msg) 'Starting Alpine'
	$(D) systemd-nspawn --boot --directory=$(work_dir)
	$(done)

clean: ## Remove temporary files
	$(call msg,Removing tmp dir)
	$D rm -rf '$(tmp_dir)'
	$(call done)

# Adapted from 'Auto documented Makefile', added -h to grep so it
# doesn't confuse targets with makefiles
#
# http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
#
# Removed need for awk since it's fugly
help: ## This help
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sed -r 's/:.*## /\t/' \
		| while read -r target message; do \
		  printf "$(color_green)%-$(col_size)s$(color_blue)\t%s$(color_off)\n" "$$target" "$$message" ;\
		done

# This makes rules run always, use it for files that already exist
always: 
.PHONY: always
