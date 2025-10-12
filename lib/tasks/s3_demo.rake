namespace :s3 do
  desc "Demo upload & list"
  task demo: :environment do
    bucket = S3Bucket.new
    bucket.head!
    Rails.logger.info "Using bucket OK"

    require "tempfile"
    Tempfile.create([ "demo", ".txt" ]) do |f|
      f.write("This is a demo file.")
      f.flush
      obj = bucket.upload_io(f, key: "demo.txt", content_type: "text/plain")
      Rails.logger.info "Uploaded to s3://#{obj.bucket_name}/#{obj.key}"
    end

    keys = bucket.list_keys(limit: 20)
    Rails.logger.info "Objects:\n#{keys.map { |k| " - #{k}" }.join("\n")}"
  end
end
