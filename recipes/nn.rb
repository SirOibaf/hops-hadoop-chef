

include_recipe "hops::wrap"
include_recipe "hadoop::nn"

my_ip = my_private_ip()

nnPort = node[:hadoop][:nn][:port]

firstNN = "hdfs://" + private_recipe_ip("hops", "nn") + ":#{nnPort}"


hopsworksNodes = ""
if node[:hops][:use_hopsworks].eql? "true"
  hopsworksNodes = node[:hopsworks][:default][:private_ips].join(",")
end

allNNs = ""
for nn in private_recipe_hostnames("hops","nn")
   allNNs += "hdfs://" + "#{nn}" + ":#{nnPort},"
end
if allNNs != ""
   allNNs.chomp(",")
end


file "#{node[:hadoop][:home]}/etc/hadoop/core-site.xml" do 
  owner node[:hdfs][:user]
  action :delete
end

myNN = "hdfs://" + my_ip + ":#{nnPort}"
template "#{node[:hadoop][:home]}/etc/hadoop/core-site.xml" do 
  source "core-site.xml.erb"
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode "755"
  variables({
              :firstNN => myNN,
              :hopsworks => hopsworksNodes,
              :allNNs => allNNs
            })
end

