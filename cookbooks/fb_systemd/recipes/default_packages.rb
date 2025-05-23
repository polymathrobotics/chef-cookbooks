#
# Cookbook Name:: fb_systemd
# Recipe:: default_packages
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

systemd_packages = ['systemd', 'systemd-sysv']

case node['platform_family']
when 'rhel', 'fedora'
  systemd_packages << 'systemd-libs'
  # Starting with Fedora 41, systemd-sysv is no longer supported and does not
  # exist in the repo
  if node.fedora? && node.os_min_version?('41', true)
    systemd_packages.delete('systemd-sysv')
  end
when 'debian'
  systemd_packages += %w{
    libpam-systemd
    libsystemd0
    libudev1
  }

  unless node.container?
    systemd_packages << 'udev'
  end

  # older versions of Debian and Ubuntu are missing some extra packages
  if (node.ubuntu? && node['platform_version'].to_i < 14) ||
     (node.debian? && node['platform_version'].to_i < 8)
    systemd_packages += %w{
      libnss-myhostname
      libnss-mymachines
      systemd-container
      systemd-coredump
    }
  end
else
  fail 'fb_systemd is not supported on this platform.'
end

package 'systemd packages' do
  # It is important we upgrade all packages that we intend to install
  # in one transaction to avoid either broken dependencies or upgrading
  # something in this transaction and then later missing a notification
  # for a package rule specific to an optional package.
  package_name lazy {
    if node['fb_systemd']['journal-remote']['enable'] &&
       node['platform_family'] == 'debian' &&
       !['trusty', 'jessie'].include?(node['lsb']['codename'])
      systemd_packages << 'systemd-journal-remote'
    end
    if node['fb_systemd']['timesyncd']['enable'] &&
        node['platform_family'] == 'debian'
      systemd_packages << 'systemd-timesyncd'
    end
    if node.dig('packages', 'systemd', 'version')
      systemd_version = FB::Version.new(node['packages']['systemd']['version'])
      has_split_rpms = node.debian? || ((node.fedora? || node.centos?) &&
          systemd_version >= FB::Version.new('249'))
      if node['fb_systemd']['networkd']['enable'] && has_split_rpms
        systemd_packages << 'systemd-networkd'
      end
      if node['fb_systemd']['resolved']['enable'] && has_split_rpms
        systemd_packages << 'systemd-resolved'
      end
      if node['fb_systemd']['nspawn']['enable'] && has_split_rpms
        systemd_packages << 'systemd-container'
      end
    end
    systemd_packages
  }
  only_if { node['fb_systemd']['manage_systemd_packages'] }
  action :upgrade
end
