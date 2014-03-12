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

launchagent_path = "#{node['sprout']['home']}/Library/LaunchAgents/homebrew.mxcl.mysql.plist"

execute "load the mysql into launchctl" do
  command "launchctl unload #{launchagent_path} && launchctl load -w #{launchagent_path}"
  user    node['current_user']
  action  :nothing
end

template "add mysql LaunchAgent" do
  path     launchagent_path
  source   "mysql/homebrew.mxcl.mysql.plist"
  owner    node['current_user']
  notifies :run, "execute[load the mysql into launchctl]"
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

ruby_block "Checking that mysql is running" do
  block do
    Timeout::timeout(60) do
      until system("ls /tmp/mysql.sock")
        sleep 1
      end
    end
  end
end

execute "Reset password if required" do
  command "mysql -u root -ppassword -e 'exit;' && mysqladmin -u root -ppassword password ''; true"
end

execute "Allow root access from all hosts" do
  command "mysql -u root -e \"GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';\""
end