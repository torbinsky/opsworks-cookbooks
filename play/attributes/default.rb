#
# Cookbook Name:: play
# Recipe:: default
#
# Copyright 2013, Torben Werner
#
#

default[:play][:app][:identifier] = 'play'
default[:play][:app][:found] = false
default[:play][:dist][:version] = '2.1.3'
default[:play][:app][:mainclass] = 'play.core.server.NettyServer'
default[:play][:lib_path] = '/usr/local/lib/play'
default[:play][:bin_path] = '/usr/local/bin/play'
default[:play][:app][:bin_path] = '/usr/local/bin/play_app'
default[:play][:app][:config_file] = '/etc/playapp.conf'
default[:play][:app][:proc_ident] = 'playappserver'
default[:play][:dist][:s3][:enabled] = false
default[:play][:dist][:s3][:region] = nil
default[:play][:dist][:s3][:bucketname] = nil
default[:play][:dist][:name] = "play-#{node[:play][:dist][:version]}"
default[:play][:dist][:remote_loc] = "http://downloads.typesafe.com/play/#{node[:play][:dist][:version]}/#{node[:play][:dist][:name]}.zip"

# Detect if a Play! application exists in this OpsWorks stack
node[:deploy].each do |application, deploy|
  if !node[:play][:app][:found] && deploy[:application_type] == "other" && application.start_with?(node[:play][:app][:identifier])
    default[:play][:app][:found] = true
    default[:play][:application] = application
    break # Only one app per instance is supported right now, probably doesn't make sense to do more in most cases anyways
  end
end

# Assuming the instance is a dedicated app instance we should take most/all the memory for the JVM
# TODO: Find a 
default[:play][:jvm][:xms]['t1.micro'] = '64M'
default[:play][:jvm][:xmx]['t1.micro'] = '256M'
default[:play][:jvm][:xms]['m1.small'] = '512M'
default[:play][:jvm][:xmx]['m1.small'] = '1024M'
default[:play][:jvm][:xms]['m1.medium'] = '1G'
default[:play][:jvm][:xmx]['m1.medium'] = '3G'
default[:play][:jvm][:xms]['m1.large'] = '512M'
default[:play][:jvm][:xmx]['m1.large'] = '1G'
default[:play][:jvm][:xms]['m2.xlarge'] = '1G'
default[:play][:jvm][:xmx]['m2.xlarge'] = '7G'
default[:play][:jvm][:xms]['m1.xlarge'] = '1G'
default[:play][:jvm][:xmx]['m1.xlarge'] = '16G'
default[:play][:jvm][:xms]['m3.xlarge'] = '1G'
default[:play][:jvm][:xmx]['m3.xlarge'] = '14G'
default[:play][:jvm][:xms]['c1.medium'] = '512M'
default[:play][:jvm][:xmx]['c1.medium'] = '1G'
default[:play][:jvm][:xms]['c1.xlarge'] = '3G'
default[:play][:jvm][:xmx]['c1.xlarge'] = '6G'