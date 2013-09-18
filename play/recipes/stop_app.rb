service 'play_app' do
  supports :restart => true, :start => true, :stop => true
  action :stop
end
