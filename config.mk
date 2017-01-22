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

alpine_flavor       := minirootfs
alpine_version      := 3.5
alpine_full_version := $(alpine_version).0
alpine_arch         := x86_64
alpine_file         := alpine-$(alpine_flavor)-$(alpine_full_version)-$(alpine_arch).tar.gz
alpine_dl           := https://fr.alpinelinux.org/alpine/v$(alpine_version)/releases/$(alpine_arch)/$(alpine_file)

# The column size for printing stuff like config and help
col_size := 20
large_col_size := 30
