node['git_projects'].each do |address|
  name = address.split("/").last.sub(".git", "")
  git "checkout #{name}" do
    destination File.join(node[:sprout][:home], "workspace", name)
    repository  address
    revision    "master"
    action      :checkout
    user        node["current_user"]
  end
end
