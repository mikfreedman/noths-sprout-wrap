node['git_projects'].each do |address|
  git "checkout #{address.split("/").last}" do
    destination File.expand_path("~/workspace")
    repository address
    revision    "master"
    action      :checkout
    user node["current_user"]
  end
end
