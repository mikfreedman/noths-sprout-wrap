default['application_support'] = "#{node[:sprout][:home]}/Library/Application Support"
default['sequel_pro_data'] = File.join(node[:application_support], "/Sequel Pro/Data")