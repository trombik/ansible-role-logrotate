require "spec_helper"
require "serverspec"

package = "logrotate"
config_dir = case os[:family]
             when "freebsd"
               "/usr/local/etc"
             else
               "/etc"
             end
config  = "#{config_dir}/logrotate.conf"
conf_d_dir = "#{config_dir}/logrotate.d"
default_user = "root"
default_group = case os[:family]
                when /bsd/
                  "wheel"
                else
                  "root"
                end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  its(:content) { should match Regexp.escape("Managed by ansible") }
end

describe cron do
  it { should have_entry "0 * * * * logrotate #{config} >/dev/null" }
end

describe file(conf_d_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
end
