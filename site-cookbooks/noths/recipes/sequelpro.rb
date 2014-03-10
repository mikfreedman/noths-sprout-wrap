include_recipe "sprout-osx-apps::sequelpro"

app_support = node[:application_support]

sequel_pro = File.join(app_support, "Sequel Pro")
sequel_pro_data = File.join(sequel_pro, "Data")

[sequel_pro, sequel_pro_data].each do |path|
	directory path do
		owner	node[:current_user]
	end
end

template "sequelpro favorites" do
	source "sequelpro/Favorites.plist"
	path   File.join(node[:sequel_pro_data], "Favorites.plist")
end