class Api::UploadsController < ApplicationController

  def presigned_post
    file_name = params.require(:file_name)
    content_type = params.require(:content_type)

    # S3 に格納するキー（保存先パス）
    key = "raw/#{current_user.id}/#{SecureRandom.uuid}/#{file_name}"

    s3      = Aws::S3::Resource.new(region: ENV.fetch("AWS_REGION"))
    bucket  = s3.bucket(ENV.fetch("S3_UPLOAD_BUCKET"))

    # 制約（サイズや Content-Type）を付けるのがポイント
    presigned = bucket.presigned_post(
      key: key,
      acl: "private",
      content_type: content_type,
      success_action_status: "201",
      # 署名の有効期限
      expires: 15.minutes.from_now,
      # ポリシー条件（ここで脆弱性を抑える）
      policy: {
        conditions: [
          ["content-length-range", 0, 5 * 1024 * 1024 * 1024], # 0~5GB
          ["eq", "$Content-Type", content_type]
        ]
      }
    )

    render json: {
      url: presigned.url,      # 例: https://<bucket>.s3.amazonaws.com
      fields: presigned.fields,# form で送る hidden フィールド群
      key: key                 # 後でDB保存や変換ジョブに使う
    }
  end
end
