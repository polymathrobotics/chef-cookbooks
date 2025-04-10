# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if node.debian?
  mirror = 'http://httpredir.debian.org/debian'
  security_mirror = 'http://security.debian.org/'
elsif node.ubuntu?
  mirror = 'http://archive.ubuntu.com/ubuntu'
  security_mirror = 'http://security.ubuntu.com/ubuntu'
end

default['fb_apt'] = {
  'allow_modified_pkg_keyrings' => false,
  'apt_update_log_path' => nil,
  'config' => {},
  'distro' => nil,
  'keymap' => {},
  # deprecated, use keymap instead
  'keys' => {},
  'keyserver' => 'keys.gnupg.net',
  'mirror' => mirror,
  'preferences' => {},
  'preserve_sources_list_d' => false,
  'preserve_unknown_keyrings' => false,
  # deprecated, use sources instead
  'repos' => [],
  'security_mirror' => security_mirror,
  'sources' => {},
  'update_delay' => 86400,
  'want_backports' => false,
  'want_non_free' => false,
  'want_source' => false,
}
