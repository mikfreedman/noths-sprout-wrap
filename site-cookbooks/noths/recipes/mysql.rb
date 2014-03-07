template "/etc/my.cnf" do
  source "mysql/my.cnf"
end

file "#{node['sprout']['home']}/Library/LaunchAgents/homebrew.mxcl.mysql.plist" do
  action :delete
end

#http://solutions.treypiepmeier.com/2010/02/28/installing-mysql-on-snow-leopard-using-homebrew/
require 'pathname'

# The next two directories will be owned by node['current_user']
DATA_DIR = "/usr/local/var/mysql"
PARENT_DATA_DIR = "/usr/local/var"

[ "/Users/#{node['current_user']}/Library/LaunchAgents",
  PARENT_DATA_DIR,
  DATA_DIR ].each do |dir|
  directory dir do
    owner node['current_user']
    action :create
  end
end

package "mysql"

ruby_block "copy mysql plist to ~/Library/LaunchAgents" do
  block do
    active_mysql = Pathname.new("/usr/local/bin/mysql").realpath
    plist_location = (active_mysql + "../../"+"homebrew.mxcl.mysql.plist").to_s
    destination = "#{node['sprout']['home']}/Library/LaunchAgents/homebrew.mxcl.mysql.plist"
    system("cp #{plist_location} #{destination} && chown #{node['current_user']} #{destination}") || raise("Couldn't find the plist")
  end
end

ruby_block "mysql_install_db" do
  block do
    active_mysql = Pathname.new("/usr/local/bin/mysql").realpath
    basedir = (active_mysql + "../../").to_s
    data_dir = "/usr/local/var/mysql"
    system("mysql_install_db --verbose --user=#{node['current_user']} --basedir=#{basedir} --datadir=#{DATA_DIR} --tmpdir=/tmp && chown #{node['current_user']} #{data_dir}") || raise("Failed initializing mysqldb")
  end
  not_if { File.exists?("/usr/local/var/mysql/mysql/user.MYD")}
end

execute "load the mysql plist into the mac daemon startup thing" do
  command "launchctl load -w #{node['sprout']['home']}/Library/LaunchAgents/homebrew.mxcl.mysql.plist"
  user node['current_user']
  not_if { system("launchctl list com.mysql.mysqld") }
end

ruby_block "Checking that mysql is running" do
  block do
    Timeout::timeout(60) do
      until system("ls /tmp/mysql.sock")
        sleep 1
      end
    end
  end
end
