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

# The local address for mailbox.sexy
mailbox_address     ?= 127.0.0.2
# The local domain for mailbox.sexy
mailbox_domain      ?= mailbox.local
# The local user
mailbox_user        ?= mailbox
# The container name
mailbox_container   ?= mailbox

# Tor's DNS
tor_dns_port         ?= 5400
# Virtual network
tor_virtual_network  ?= 10.192.0.0/10
# Where is the private key and hostname.onion
tor_hostname_dir     ?= /var/lib/tor/$(mailbox_domain)
# Transparent port
tor_transparent_port ?= 9041

alpine_flavor       := minirootfs
alpine_version      := 3.5
alpine_full_version := $(alpine_version).1
alpine_arch         := x86_64
alpine_file         := alpine-$(alpine_flavor)-$(alpine_full_version)-$(alpine_arch).tar.gz
alpine_dl           := https://nl.alpinelinux.org/alpine/v$(alpine_version)/releases/$(alpine_arch)/$(alpine_file)

# The column size for printing stuff like config and help
col_size := 20
large_col_size := 30

# Make everything available to targets
export
