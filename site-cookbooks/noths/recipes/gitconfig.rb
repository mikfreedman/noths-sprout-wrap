template "#{node['sprout']['home']}/.gitconfig" do
  source "dot_files/gitconfig"
  owner node['current_user']
end
