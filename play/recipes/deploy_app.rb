include_recipe "deploy"
include_recipe "play"

# Don't deploy unless we found a Play! app
if node[:play][:app_found]
  # Get app information
  application = node[:play][:application]
  deploy = node[:deploy][application]
  
  # Install unzip package
  package "unzip" do
    action :install
  end
  
  # Ensure Play! application has been built
  include_recipe "play::build_app"
  
  bash "deploy-play-app-dist" do
    code <<-EOH
    # find dist zip
    cd #{deploy[:current_path]}/dist
    zippath=`find #{deploy[:current_path]}/dist -name '*.zip'`
    
    # unzip the dist zip
    unzip -o $zippath
    zipfile=$(basename "$zippath")
    distname="${zipfile%.*}"
    
    # replace the main class in the start script
    startscript=#{deploy[:current_path]}/dist/$distname/start
    sed -i 's/play.core.server.NettyServer/#{node[:play][:app][:mainclass]}/g' $startscript
    chmod 750 $startscript
    
    # move the built app to a location the script knows about (WARNING: rm -rf! careful!!!)
    deployedapp_path=#{deploy[:current_path]}/deployed_app
    # Probably should come up with a better method to do this...
    rm -rf $deployedapp_path
    mv #{deploy[:current_path]}/dist/$distname $deployedapp_path
    
    # copy the assets directory (https://github.com/playframework/playframework/issues/1079)
    mkdir -p $deployedapp_path/app/
    cp -r #{deploy[:current_path]}/app/assets $deployedapp_path/app/
    EOH
  end
  
  include_recipe "play::play_app_service"
  
  # Create/update the app configuration file
  ec2Type = node[:opsworks][:instance][:instance_type]
  xms = node[:play][:jvm][:xms][ec2Type]
  xmx = node[:play][:jvm][:xmx][ec2Type]
  template "#{node[:play][:app][:config_file]}" do
    source 'play.conf.erb'
    owner 'root'
    group 'root'
    mode '740'
    variables(
    :app_opts => node[:play][:app][:runargs]
    )
    action :create
    notifies :restart, resources(:service => ['play_app']), :delayed
  end
  
  # Create/update the app executable
  template "#{node[:play][:app][:bin_path]}" do
      source 'playapp.bin.erb'
      owner 'root'
      group 'root'
      variables(
        :xms => xms,
        :xmx => xmx,
        :startscript => "#{deploy[:current_path]}/deployed_app/start"
        )
      mode '750'
      action :create
      notifies :restart, resources(:service => ['play_app']), :delayed
  end
  
  # Create/update the app's init daemon script
  template "/etc/init.d/play_app" do
      source 'play_app.service.erb'
      owner 'root'
      group 'root'
      mode '755'
      action :create
      notifies :restart, resources(:service => ['play_app']), :delayed
  end
end