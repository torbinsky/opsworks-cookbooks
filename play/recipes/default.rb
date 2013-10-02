#
# Cookbook Name:: play
# Recipe:: default
#
# Copyright 2013, Torben Werner
#
#

include_recipe 'java'

#Download play from s3
if !File.directory?("#{node[:play][:lib_path]}")
  # Get the packaged Play! distribution
  if node[:play][:dist][:s3][:enabled]
    # Download Play! from S3 bucket (allows distro customization, direct AWS access, etc...)
    include_recipe 's3'
    s3_aware_remote_file "#{Chef::Config[:file_cache_path]}/#{node[:play][:dist][:name]}.zip" do
      source "#{node[:play][:dist][:s3][:region]}://#{node[:play][:dist][:s3][:bucketname]}/#{node[:play][:dist][:name]}.zip"
      access_key_id node[:config][:aws][:s3][:access_key]
      secret_access_key node[:config][:aws][:s3][:secret]
      owner "root"
      group "root"
      mode "644"
      action :create
    end
  else
    # Download Play! from Typesafe's site or other file locations...
    remote_file "#{Chef::Config[:file_cache_path]}/#{node[:play][:dist][:name]}.zip" do
      source "#{node[:play][:dist][:s3][:region]}://#{node[:play][:dist][:s3][:bucketname]}/#{node[:play][:dist][:name]}.zip"
      owner 'root'
      group 'root'
      mode '644'
    end
  end

  # Unzip the Play! distribution package
  bash "install-play-lib" do
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
    unzip #{node[:play][:dist][:name]}.zip
    mv #{Chef::Config[:file_cache_path]}/#{node[:play][:dist][:name]} #{node[:play][:lib_path]}
    ln -s #{node[:play][:lib_path]}/play #{node[:play][:bin_path]}
    EOH
  end
end