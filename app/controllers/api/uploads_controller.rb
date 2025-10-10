class Api::UploadsController < ApplicationController
  def presigned_post
    file_name = params.require(:file_name)
    content_type = params.require(:content_type)
    key = "raw/#{current_user.id}/#{SecureRandom.uuid}/#{file_name}"
    s3      = Aws::S3::Resource.new(region: ENV.fetch("AWS_REGION"))
    bucket  = s3.bucket(ENV.fetch("S3_UPLOAD_BUCKET"))
    presigned = bucket.presigned_post(
      key: key,
      acl: "private",
      content_type: content_type,
      success_action_status: "201",
      expires: 15.minutes.from_now,
      policy: {
        conditions: [
          [ "content-length-range", 0, 5 * 1024 * 1024 * 1024 ],
          [ "eq", "$Content-Type", content_type ]
        ]
      }
    )

    render json: {
      url: presigned.url,
      fields: presigned.fields,
      key: key
    }
  end
end
