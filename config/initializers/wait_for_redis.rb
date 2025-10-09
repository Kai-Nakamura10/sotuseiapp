# Wait for Redis to become available on process start (prevents Sidekiq from crashing
# immediately if Redis is temporarily unavailable during container startup).
# This implementation uses a plain TCP connection so it doesn't depend on the
# redis gem being loaded during the boot sequence.
require 'uri'
require 'socket'

redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
uri = URI.parse(redis_url)
host = uri.host || 'localhost'
port = uri.port || 6379

deadline = Time.now + 30
Thread.new do
  begin
    loop do
      begin
        Socket.tcp(host, port, connect_timeout: 1) do |sock|
          sock.close
        end
        Rails.logger.info("Redis available at #{host}:#{port}")
        break
      rescue => e
        if Time.now > deadline
          Rails.logger.error("Redis did not become available within 30s: #{e.class}: #{e.message}")
          break
        end
        Rails.logger.info("Waiting for Redis (#{host}:#{port})... #{e.class}: #{e.message}")
        sleep 1
      end
    end
  rescue => e
    Rails.logger.error("wait_for_redis thread error: #{e.class}: #{e.message}")
  end
end
