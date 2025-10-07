# s3_use_existing.rb
require "aws-sdk-s3"

REGION = ENV.fetch("AWS_REGION", "ap-northeast-1")
BUCKET = ENV.fetch("AWS_S3_BUCKET", "playinsightbucket")  # ← 既存バケット名

s3 = Aws::S3::Resource.new(
  region: REGION,
  access_key_id: ENV["AWS_ACCESS_KEY_ID"],
  secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
)
s3_client = s3.client

# 既存バケットの存在確認（存在しない/権限なしなら例外）
begin
  s3_client.head_bucket(bucket: BUCKET)
  puts "✅ Using existing bucket: #{BUCKET}"
rescue Aws::S3::Errors::NotFound, Aws::S3::Errors::NoSuchBucket
  abort "❌ Bucket '#{BUCKET}' not found in region #{REGION}."
rescue Aws::S3::Errors::Forbidden
  abort "❌ Access forbidden to bucket '#{BUCKET}'. Check IAM permissions."
end

bucket = s3.bucket(BUCKET)

# アップロード（ローカルファイルをS3へ）
File.write("demo.txt", "This is a demo file.")
obj = bucket.object("demo.txt")
obj.upload_file("demo.txt", content_type: "text/plain")
puts "✅ Uploaded: s3://#{bucket.name}/#{obj.key}"

# 一覧表示（確認用）
begin
  puts "📦 Objects in #{bucket.name}:"
  bucket.objects.each { |o| puts " - #{o.key}" }
rescue Aws::Errors::ServiceError => e
  warn "⚠️ List failed: #{e.class} #{e.message}"
end

# 片付け（S3バケットは削除しない！）
File.delete("demo.txt") if File.exist?("demo.txt")
