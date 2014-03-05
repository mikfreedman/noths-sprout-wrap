template "/etc/my.cnf" do
  source "mysql/my.cnf"
end

include_recipe "pivotal_workstation::mysql"
