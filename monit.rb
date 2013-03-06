set_default(:postgresql_pid) { "/var/run/postgresql/9.1-main.pid" }

namespace :monit do
  desc "Setup all Monit configuration"
  task :setup do
    unicorn
    syntax
    reload
  end
  after "deploy:setup", "monit:setup"

  task(:unicorn, roles: :app) { monit_config "unicorn", "#{application}_unicorn" }

  %w[start stop restart syntax reload].each do |command|
    desc "Run Monit #{command} script"
    task command do
      with_sudo_user do
        sudo "service monit #{command}"
      end
    end
  end
end

def monit_config(name, d_name=nil, destination = nil)
  d_name ||= name
  destination ||= "/etc/monit/conf.d/#{d_name}.conf"
  template "monit/#{name}.erb", "/tmp/monit_#{d_name}"
  with_sudo_user do
    sudo "mv /tmp/monit_#{d_name} #{destination}"
    sudo "chown root #{destination}"
    sudo "chmod 600 #{destination}"
  end
end
