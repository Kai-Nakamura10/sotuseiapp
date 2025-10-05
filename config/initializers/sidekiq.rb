Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') { 'redis://localhost:6379/0' } }
  sidekiq_config = YAML.load_file(Rails.root.join('config/sidekiq.yml'))
  config[:concurrency] = sidekiq_config[:concurrency]
  config[:queues] = sidekiq_config[:queues]
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') { 'redis://localhost:6379/0' } }
end
