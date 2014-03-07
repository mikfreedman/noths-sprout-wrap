db_dump_dir = File.expand_path("~/workspace/database_dumps/")
db_dump     = File.join(db_dump_dir, "mysql.sql.gz")
db_name     = "noths_dump"
db_password = "password"
db_user     = "root"

bash "load noths_dump dump" do
  command "zcat #{db_dump} | mysql -u #{db_user} -p #{db_password} #{db_name}"
  action  :nothing
end

directory "create database dump directory #{db_dump_dir}" do
  path      db_dump
  recursive true
  action    :create
end

# remote_file "download noths_dump" do
#   path   db_dump
#   source "https://dumps.hq.noths.com/mysql.sql.gz"
#   not_if "mysql -u #{db_user} -p password #{db_password} -e exit;"
#   notifies :run, "bash[load noths_dump dump]", :immediately
# end
