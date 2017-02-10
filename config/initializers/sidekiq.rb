Sidekiq.configure_server do |config|
  config.redis = { url: 'clusterstuffcache.qak8xc.ng.0001.use1.cache.amazonaws.com:6379/12' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'clusterstuffcache.qak8xc.ng.0001.use1.cache.amazonaws.com:6379/12' }
end