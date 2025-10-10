def create_presigned
  key = "raw/#{current_user.id}/#{SecureRandom.uuid}/${filename}"
  post = Aws::S3::Presigner.new.presigned_post(
    bucket: ENV["UPLOAD_BUCKET"],
    key: key,
    acl: "private", # 公開しない
    content_length_range: 0..(50.gigabytes),
    success_action_status: "201"
  )
  render json: { url: post.url, fields: post.fields }
end
