include_recipe "play"

service "play_app" do
  supports :restart => true, :start => true, :stop => true
  action :nothing
end
