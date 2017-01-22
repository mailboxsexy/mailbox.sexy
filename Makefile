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

include config.mk
include lib/macros.mk

.DEFAULT_GOAL := help

tmp_dir := $(root_dir)/tmp
$(tmp_dir):
	$(call msg,Creating tmp dir)
	$(D) mkdir -p $@
	$(call done)

# Downloads the alpine tarball into the tmp dir
tarball := $(tmp_dir)/$(alpine_file)
$(tarball): $(tmp_dir)
	$(call msg,Downloading alpine)
	$(D) wget '$(alpine_dl)' $(quiet_flag) -O '$@' --no-use-server-timestamps
	$(call done)

download: $(tarball) ## Download alpine

work_dir := $(tmp_dir)/alpine-$(alpine_flavor)-$(alpine_full_version)-$(alpine_arch)
$(work_dir): $(tmp_dir)
	$(call msg,Creating work dir)
	$(D) mkdir -p '$@'
	$(call done)

$(work_dir)/etc/alpine-release: $(work_dir)
	$(call msg,Extracting tarball)
	$(D) cd '$<' && tar $(verbose_flag) -xmf $(tarball)
	$(call done)

extract: download $(work_dir) $(work_dir)/etc/alpine-release ## Extract alpine to work dir

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

all: config download extract ## Run all the targets

clean: ## Remove temporary files
	$(call msg,Removing tmp dir)
	$(D) rm -rf '$(tmp_dir)'

# Adapted from 'Auto documented Makefile', added -h to grep so it
# doesn't confuse targets with makefiles
#
# http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
#
# TODO remove need for awk
help: ## This help
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "$(color_green)%-$(col_size)s$(color_blue)\t%s$(color_off)\n", $$1, $$2}'

# This makes rules run always, use it for files that already exist
always: 
.PHONY: always
