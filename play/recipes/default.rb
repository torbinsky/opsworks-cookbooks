#
# Cookbook Name:: play
# Recipe:: default
#
# Copyright 2013, Torben Werner
#
#

include_recipe "java"
include_recipe "s3"

#Download play from s3
if !File.directory?("#{node[:play][:lib_path]}")
  # Get the packaged Play! distribution 
  if node[:play][:dist][:s3][:enabled]
    # Download Play! from S3 bucket (allows distro customization, direct AWS access, etc...)
    s3_aware_remote_file "#{Chef::Config[:file_cache_path]}/#{node[:play][:dist][:name]}.zip" do
      source "#{node[:play][:dist][:s3][:region]}://#{node[:play][:dist][:s3][:bucketname]}/#{node[:play][:dist][:name]}.zip"
      access_key_id node[:config][:aws][:s3][:access_key]
      secret_access_key node[:config][:aws][:s3][:secret]
      owner "root"
      group "root"
      mode "644"
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
  execute "unzip-play" do
    cwd Chef::Config[:file_cache_path]
    command "unzip #{node[:play][:dist][:name]}.zip"
  end

  # Install Play!
  execute "install-play-lib" do
    command "mv #{Chef::Config[:file_cache_path]}/#{node[:play][:dist][:name]} #{node[:play][:lib_path]}"
  end
  
  execute "install-play-bin" do
    command "ln -s #{node[:play][:lib_path]}/play #{node[:play][:bin_path]}"
  end
end