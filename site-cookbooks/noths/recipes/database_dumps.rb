db_dump_dir = File.expand_path("#{node[:sprout][:home]}/Downloads")
db_user     = "root"

[
	{
		:name   => "noths_uk",
		:source => ["http://dumps.hq.noths.com/mysql.sql.gz", "https://dumps.hq.noths.com/mysql.sql.gz"],
		:path   => File.join(db_dump_dir, "mysql_uk.sql.gz")
	},
	{
		:name   => "noths_de",
		:source => ["http://dumps.hq.noths.com/mysql_de.sql.gz", "https://dumps.hq.noths.com/mysql_de.sql.gz"],
		:path   => File.join(db_dump_dir, "mysql_de.sql.gz")
	}
].each do |details|

	remote_file "download #{details[:name]}" do
	  path   details[:path]
	  source details[:source]
	  action :create_if_missing
	end

	bash "load #{details[:name]}" do
	  code <<-BASH 
	    mysql -u#{db_user} -e 'CREATE DATABASE #{details[:name]};' && gzcat #{details[:path]} | mysql -u #{db_user} #{details[:name]} 
	  BASH
	  not_if  "mysql -u #{db_user} #{details[:name]} -e exit;"
	end

end

