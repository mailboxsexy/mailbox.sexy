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
root_dir    := $(patsubst %/,%,$(dir $(mkfile_path)))
tmp_dir     := $(root_dir)/tmp

# Get the config
include config.mk
# And some macros
include lib/macros.mk

# This is the target run when you run `make`, it shows a helpful
# message.
.DEFAULT_GOAL := help

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
	$D touch $@ # we touch it so it doesn't get downloaded everytime
	$(done)

download: $(tarball) ## Download alpine

## Extract
# 
# Creates a work directory and extracts Alpine into it

work_dir := $(tmp_dir)/alpine-$(alpine_flavor)-$(alpine_full_version)-$(alpine_arch)
$(work_dir): $(tmp_dir)
	$(msg) 'Creating work dir'
	$D install -dm 755 -o root -g root '$@'
	$(done)

$(work_dir)/etc/alpine-release: $(work_dir)
	$(msg) 'Extracting tarball'
	$D cd '$<' && tar $(verbose_flag) -xmf $(tarball)
	$D chmod 755 '$(work_dir)' # if the work_dir doesn't have 755 services can't run
	$D touch '$@' # we touch it so it doesn't get extracted everytime
	$(done)

extract: $(work_dir) $(work_dir)/etc/alpine-release ## Extract alpine to work dir

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

$(work_dir)/home/$(mailbox_user)/:
	$(msg) 'Creating $(mailbox_user) user'
	$(run_alpine) /usr/sbin/adduser \
	  -h /home/$(mailbox_user) \
		-s /bin/false -D \
		-g $(mailbox_user) \
		$(mailbox_user)
	$(done)

$(work_dir)/home/$(mailbox_user)/Maildir/: $(work_dir)%:
	$(msg) 'Installing maildir'
	$(run_alpine) /usr/bin/install -dm700 -o $(mailbox_user) \
	  -g $(mailbox_user) $* $*cur $*new $*tmp
	$(done)

$(work_dir)/etc/hostname: always
	$(msg) 'Setting hostname'
	$D echo $(mailbox_domain) >$@
	$(done)

$(work_dir)/etc/hosts: $(render_template)/hosts
	$(msg) 'Setting hosts'
	$D install -m 644 -o root -g root $< $@
	$(done)

# Installs our services
$(work_dir)/etc/init.d/%: $(render_template)/%
	$(msg) 'Installing $(notdir $<)'
	$D install -m 750 -o root -g root $< $@
	$(done)

prepare_deps := $(work_dir)/etc/inittab $(work_dir)/etc/localtime \
	$(work_dir)/var/cache/apk/APKINDEX.%.tar.gz \
	$(work_dir)/home/$(mailbox_user)/ \
	$(work_dir)/home/$(mailbox_user)/Maildir/ \
	$(work_dir)/etc/hostname \
	$(work_dir)/etc/hosts \
	$(work_dir)/etc/init.d/fakenet \
	$(work_dir)/etc/init.d/mailbox

prepare: $(prepare_deps) ## Prepares Alpine

## Install
# 
# Install packages on Alpine

packages := postfix postfix-pcre tor dovecot openrc unbound darkhttpd

install: ## Install packages
	$(msg) 'Installing packages'
	$(run_alpine) /sbin/apk $(quiet_flag) --no-progress add $(packages) $(dev_null)
	$(done)

## Configure
#
# Run configuration tasks
#

# This file is created by tor on first run
hostname_file := $(tor_hostname_dir)/hostname

## Local
#
# Stuff that runs with the `local` openrc file

local_dir := $(work_dir)/etc/local.d

# Installs local scripts
$(local_dir)/%.start: $(render_template)/%
	$(msg) 'Installing $(notdir $<)'
	$D install -m 750 -o root -g root $< $@
	$(done)

local_deps := $(rc_update)/default/local \
	$(local_dir)/resolv.start \
	$(rc_update)/default/fakenet \
	$(rc_update)/default/mailbox
local: $(local_deps) ## Configure local scripts

## Postfix configuration
# 
$(work_dir)/etc/postfix/header_checks: $(render_template)/header_checks
	$(msg) 'Installing header_checks'
	$D install -m 644 -o root -g root $< $@
	$(done)

# Remove defaults headers plus the ones that contain metadata about us
drop_headers := bcc content-length resent-bcc return-path
drop_headers += user-agent x-enigmail x-mailer x-originating-ip received
#
# First, postfix needs to use the system resolver instead of itself.
# This way it can resolv .onion addresses.
#
# Then, it loads its own hostname from tor configuration and allows por
# local delivery to user.  We'll create the mailbox user later on.
#
# Metadata is removed by `message_drop_headers` and
# `smtp_header_checks`.
#
# Also authenticates users against dovecot
#
# TODO: add `canonical` so every address is mailbox@hiddenservice.onion
# instead of user@hiddenservice.onion or user@mailbox.local or whatever
# the user prefers.
$(work_dir)/etc/postfix/main.cf: always
	$(msg) 'Configuring main.cf'
	$(postconf) smtputf8_enable=no # alpine doesn't build postfix with icu
	$(postconf) smtp_host_lookup=native
	$(postconf) ignore_mx_lookup_error=yes
	$(postconf) smtp_dns_support_level=enabled
	$(postconf) smtpd_relay_restrictions=permit_sasl_authenticated,defer_unauth_destination
	$(postconf) mydestination=$(mailbox_domain)
	$(postconf) mydomain=$(mailbox_domain)
	$(postconf) myhostname=$(mailbox_domain)
	$(postconf) inet_protocols=ipv4
	$(postconf) home_mailbox=Maildir/
	$(postconf) recipient_delimiter=+
	$(postconf) local_recipient_maps='unix:passwd.byname $$alias_maps'
	$(postconf) message_drop_headers='$(drop_headers)'
	$(postconf) smtp_header_checks=pcre:/etc/postfix/header_checks
	$(postconf) smtpd_sasl_type=dovecot
	$(postconf) smtpd_sasl_path=private/auth
	$(postconf) smtpd_sasl_auth_enable=yes
	$(postconf) smtpd_sasl_security_options=noanonymous
	$(postconf) smtp_sasl_security_options=noanonymous
	$(postconf) broken_sasl_auth_clients=yes
	$(postconf) smtpd_sasl_local_domain='$$myhostname'
	$(postconf) smtpd_sasl_authenticated_header=no
	$(postconf) inet_interfaces=$(mailbox_address)
	$(postconf) smtpd_tls_cert_file=/etc/ssl/dovecot/server.pem
	$(postconf) smtpd_tls_key_file=/etc/ssl/dovecot/server.key
	$(done)

$(work_dir)/etc/postfix/master.cf: always
	$(msg) 'Configuring master.cf'
	$(postconf) -M submission/inet='submission   inet   n   -   n   -   -   smtpd'
	$(postconf) -P 'submission/inet/syslog_name=postfix/submission'
	$(postconf) -P 'submission/inet/smtpd_tls_security_level=encrypt'
	$(postconf) -P 'submission/inet/smtpd_etrn_restrictions=reject'
	$(postconf) -P 'submission/inet/smtpd_sasl_type=dovecot'
	$(postconf) -P 'submission/inet/smtpd_sasl_path=private/auth'
	$(postconf) -P 'submission/inet/smtpd_sasl_security_options=noanonymous'
	$(postconf) -P 'submission/inet/smtpd_sasl_local_domain=$$myhostname'
	$(postconf) -P 'submission/inet/smtpd_sasl_auth_enable=yes'
	$(postconf) -P 'submission/inet/milter_macro_daemon_name=ORIGINATING'
	$(postconf) -P 'submission/inet/smtpd_client_restrictions=permit_sasl_authenticated,reject'
	$(postconf) -P 'submission/inet/smtpd_recipient_restrictions=permit_mynetworks,permit_sasl_authenticated,reject'
	$(done)

$(work_dir)/etc/postfix/aliases: always
	$D grep -q 'root: $(mailbox_user)' $@ || echo 'root: $(mailbox_user)' >>$@

postfix_deps := $(work_dir)/etc/postfix/header_checks \
	$(work_dir)/etc/postfix/main.cf \
	$(work_dir)/etc/postfix/master.cf \
	$(work_dir)/etc/postfix/aliases \
	$(rc_update)/default/postfix

postfix: $(postfix_deps) ## Configure postfix

$(work_dir)/etc/dovecot/local.conf: $(render_template)/dovecot.conf
	$D install -m 644 -o root -g root $< $@

$(work_dir)/etc/dovecot/users: always
	$(run_alpine) getent passwd $(mailbox_user) >$@

dovecot_deps := $(work_dir)/etc/dovecot/local.conf \
	$(work_dir)/etc/dovecot/users \
	$(rc_update)/default/dovecot

dovecot: $(dovecot_deps) ## Configure dovecot

$(work_dir)/etc/tor/torrc: $(render_template)/torrc
	$(msg) 'Configuring tor'
	$D cat $@.sample $< >$@
	$(run_alpine) /bin/chown tor /etc/tor/torrc
	$(done)

tor: $(work_dir)/etc/tor/torrc $(rc_update)/default/tor ## Configure tor

$(work_dir)/etc/unbound/unbound.conf: $(render_template)/unbound.conf
	$(msg) 'Configuring unbound'
	$D install -m 644 -o root -g root $< $@
	$(done)

unbound_deps := $(work_dir)/etc/unbound/unbound.conf $(rc_update)/default/unbound

unbound: $(unbound_deps) ## Configure unbound

# It couldn't be more fugly, uh?
$(work_dir)/var/www/localhost/htdocs/mail/config-v1.1.xml: $(render_template)/config-v1.1.xml
	$(msg) 'Configuring darkhttpd'
	$D install -Dm644 -o root -g root $< $@
	$(done)

darkhttpd_deps := $(rc_update)/default/darkhttpd \
	$(work_dir)/var/www/localhost/htdocs/mail/config-v1.1.xml
darkhttpd: $(darkhttpd_deps) ## Configure darkhttpd

configure: local postfix dovecot tor unbound darkhttpd ## Configure mailbox.sexy

## Cleanup
# 
# Remove files from the Alpine chroot that shouldn't be there
# when the system is done installing and it's being packaged.
#
# Add files to remove on the cleanup_deps variable.

cleanup_deps := $(work_dir)/etc/localtime \
	$(work_dir)/var/cache/apk/APKINDEX.*.tar.gz \
	$(render_template)

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
	$(call info_about_var,mailbox_domain)
	$(call info_about_var,mailbox_address)
	$(call info_about_var,mailbox_user)
	$(call info_about_var,tor_virtual_network)
	$(call info_about_var,tor_transparent_port)
	$(call info_about_var,tor_hostname_dir)
	$(call info_about_var,tor_dns_port)
	$(call info_about_var,tmp_dir)
	$(call info_about_var,work_dir)
	$(call info_about_var,alpine_flavor)
	$(call info_about_var,alpine_version)
	$(call info_about_var,alpine_full_version)
	$(call info_about_var,alpine_arch)
	$(call info_about_var,alpine_file)
	$(call info_about_var,alpine_dl)
	$(call info_about_var,render_template)

all: config download extract prepare install configure cleanup ## Run all the targets

$(tmp_dir)/lib/macros.mk: lib/macros.mk
	$D install -Dm 644 -o root -g root $< $@

$(tmp_dir)/lib/colors.mk: lib/colors.mk
	$D install -Dm 644 -o root -g root $< $@

$(tmp_dir)/config.mk: config.mk
	$D install -Dm 644 -o root -g root $< $@

$(tmp_dir)/Makefile: $(render_template)/Makefile
	$D install -Dm 644 -o root -g root $< $@

$(tmp_dir)/mailbox.sexy: $(render_template)/mailbox.sexy
	$D install -Dm 644 -o root -g root $< $@

mailbox_dir  := $(mailbox_domain).$(shell date +%F).$(alpine_arch)
tarball_deps := $(render_template)/override.conf \
	$(render_template)/systemd-nspawn@debian.service \
	$(work_dir) \
	$(tmp_dir)/Makefile \
	$(tmp_dir)/lib/macros.mk \
	$(tmp_dir)/lib/colors.mk \
	$(tmp_dir)/config.mk \
	$(tmp_dir)/mailbox.sexy
tarball: $(tarball_deps) ## Create a tarball for distribution
	$(msg) "Tarballin'"
	$D tar $(verbose_flag) --transform='s/^$(notdir $(tmp_dir))/$(mailbox_dir)/' \
	  -cJf $(mailbox_dir).tar.xz \
	  $(patsubst $(dir $(tmp_dir))%,%,$^)
	$(done)

clean: ## Remove temporary files
	$(msg) 'Removing tmp dir'
	$D rm -rf '$(tmp_dir)'
	$(done)

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
	$(msg) '\nAdd V=99 for verbose mode\n'

email: clean
sexy: all
again: tarball

# This makes rules run always, use it for files that already exist
always: 
.PHONY: always
