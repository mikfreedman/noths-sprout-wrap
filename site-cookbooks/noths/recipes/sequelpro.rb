include_recipe "sprout-osx-apps::sequelpro"

application_support = File.expand_path("~/Library/Application Support/Sequel Pro/Data")

template "sequelpro key mappings" do
  source "sequelpro/Favorites.plist"
  path   File.join(application_support, "Favorites.plist")
end