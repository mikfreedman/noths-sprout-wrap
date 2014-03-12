dest = File.join(node[:sprout][:home], "workspace", "notonthehighstreet")

git "checkout notonthehighstreet" do
  destination dest
  repository  "git@github.com:notonthehighstreet/notonthehighstreet.git"
  revision    "integration"
  action      :checkout
  user        node["current_user"]
  timeout     60 * 60 * 2
end

remote_file "download SSL certificate authority" do
  source "http://noths.com/ssl"
  path   File.join(node[:sprout][:home], "Downloads/rootCA.pem")
end

bash "trust SSL certificate authority" do
  code "security add-trusted-cert -d -k #{node[:sprout][:home]}/Library/Keychains/login.keychain ~/Downloads/rootCA.pem"
  user "root"
end

#
# DB setup
#

bash "copy database.yml.dist" do
  code "cp #{dest}/config/database.yml.dist #{dest}/config/database.yml"
  not_if { File.exist? "#{dest}/config/database.yml" }
  user node['current_user']
end


#
# Vagrant setup
#

bash "copy Vagrant.dist-1.1" do
  code   "cp #{dest}/Vagrantfile.dist-1.1 #{dest}/Vagrantfile"
  not_if { File.exist? "#{dest}/Vagrantfile" }
  user   node['current_user']
end

ruby_block "setup Vagrant sudoers file for NFS shares" do
  block do
    snippet = <<-SNIP
# Added by Chef to allow NFS exports for vagrant

Cmnd_Alias VAGRANT_EXPORTS_ADD = /usr/bin/su root -c echo '*' >> /etc/exports
Cmnd_Alias VAGRANT_NFSD = /sbin/nfsd restart
Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /usr/bin/sed -e /*/ d -ibak /etc/exports
%staff ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE

# Finish added by Chef
SNIP

    require 'chef/util/file_edit'
    sudoers = Chef::Util::FileEdit.new("/etc/sudoers")
    sudoers.insert_line_if_no_match(/Added by Chef to allow NFS exports for vagrant/, snippet)
    sudoers.write_file
  end
end

bash "install ssh key for vagrant" do
  code   "#{dest}/script/bootstrap_dev_host"
  not_if { File.exist? "#{node[:sprout][:home]}/.ssh/vagrant"}
  user   node['current_user']
end

bash "provision vagrant" do
  code "cd #{dest} && vagrant up --provision"
  user node['current_user']
end

# bash "bootstrap vagrant rails app" do
#   code "ssh dev \"bash -c 'cd /var/sites/notonthehighstreet/current && script/bootstrap'\""
#   user node['current_user']
# end