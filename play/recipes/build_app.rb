include_recipe "deploy"
include_recipe "play"

# Don't build unless we found a Play! application
if node[:play][:app][:found]
  # Get app information
  application = node[:play][:application]
  deploy = node[:deploy][application]
  
  # Get OpsWorks to 'deploy' the application (for example, if the application is in a Git repository, this will clone the repository etc...)
  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end
  
  # Build/package application
  execute "build-play-app-dist" do
    command "#{node[:play][:bin_path]} dist"
    cwd "#{deploy[:current_path]}"
  end
end