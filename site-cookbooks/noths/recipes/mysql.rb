#http://solutions.treypiepmeier.com/2010/02/28/installing-mysql-on-snow-leopard-using-homebrew/
require 'pathname'

template "/etc/my.cnf" do
  source "mysql/my.cnf"
end

include_recipe "pivotal_workstation::mysql"
