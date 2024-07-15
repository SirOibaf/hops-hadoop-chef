# Install and start Docker
Chef::Recipe.send(:include, Hops::Helpers)

group 'docker' do
  gid node['hops']['docker']['group_id']
  action :create
  not_if "getent group docker"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

cookbook_file node['hops']['docker']['hopsfsmount-seccomp-profile'] do
  source 'hopsfsmount_seccomp_profile.json'
  owner 'root'
  mode '0755'
  action :create
end

service_name='docker'

# Start the docker deamon
kagent_config service_name do
  action :systemd_reload
end

service service_name do
  action :enable
end
