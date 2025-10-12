require "aws-sdk-s3"
class S3Bucket
  def initialize(bucket: ENV["AWS_S3_BUCKET"], region: ENV.fetch("AWS_REGION", "ap-northeast-1"))
    @bucket_name = bucket or raise "AWS_S3_BUCKET is not set"

    @client  = Aws::S3::Client.new(
      region: region,
      access_key_id:     ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )
    @resource = Aws::S3::Resource.new(client: @client)
    @bucket   = @resource.bucket(@bucket_name)

    # 非推奨API回避：推奨の TransferManager を用意
    @tm = Aws::S3::TransferManager.new(client: @client)
  end

  # 存在/権限チェック
  def head!
    @client.head_bucket(bucket: @bucket_name)
    true
  rescue Aws::S3::Errors::NotFound, Aws::S3::Errors::NoSuchBucket
    raise "Bucket '#{@bucket_name}' not found"
  rescue Aws::S3::Errors::Forbidden
    raise "Access forbidden to bucket '#{@bucket_name}'"
  end

  # 便利: ローカルパスを直接アップロード
  def upload_path(path, key:, content_type:)
    raise ArgumentError, "file not found: #{path}" unless File.exist?(path)
    @tm.upload_file(            # ← 戻り値は true。例外が出なければアップロード完了
      path,
      bucket: @bucket_name,
      key: key,
      content_type: content_type
    )
    @resource.bucket(@bucket_name).object(key)
  end

  # IO系（Tempfile/StringIOなど）をアップロード
  # - Tempfile/ファイルに近いもの: 一時パスを使って TransferManager に渡す
  # - StringIO/メモリIO: put_objectで単発アップロード
  def upload_io(io, key:, content_type:)
    if io.respond_to?(:path) && io.path && File.exist?(io.path)
      io.rewind if io.respond_to?(:rewind)
      @tm.upload_file(io, bucket: @bucket_name, key: key, content_type: content_type)
    else
      body = io.respond_to?(:read) ? (io.rewind if io.respond_to?(:rewind); io.read) : io.to_s
      @client.put_object(bucket: @bucket_name, key: key, body: body, content_type: content_type)
    end
    @resource.bucket(@bucket_name).object(key)
  end

  def list_keys(prefix: nil, limit: 100)
    enum = prefix ? @bucket.objects(prefix: prefix) : @bucket.objects
    enum.take(limit).map(&:key)
  end
end
