#http://solutions.treypiepmeier.com/2010/02/28/installing-mysql-on-snow-leopard-using-homebrew/
require 'pathname'

link "/tmp/mysql.sock" do
  to "/var/lib/mysql/mysql.sock"
  owner node['current_user']
end

include_recipe "pivotal_workstation::mysql"
