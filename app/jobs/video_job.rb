class VideoJob < ApplicationJob
  queue_as :default

  def perform(video_id)
    video = Video.find_by(id: video_id)
    return unless video&.file&.attached?

    needs_duration  = video.duration_seconds.blank?
    needs_thumbnail = !video.thumbnail.attached?
    return unless needs_duration || needs_thumbnail

    src = Tempfile.new(["video", File.extname(video.file.filename.to_s)])
    src.binmode
    src.write(video.file.download)
    src.flush

    movie = FFMPEG::Movie.new(src.path)

    duration = movie.duration.to_i
    video.update_column(:duration_seconds, duration) if needs_duration

    if needs_thumbnail
      thumb = Tempfile.new(%w[thumb .jpg])
      thumb.binmode
      seek = duration >= 5 ? 5 : 0
      movie.screenshot(thumb.path, seek_time: seek, resolution: "640x360")
      thumb.rewind

      video.thumbnail.attach(
        io: thumb,
        filename: "video_#{video.id}_thumb.jpg",
        content_type: "image/jpeg"
      )
    end
  rescue => e
    Rails.logger.error("[VideoJob] video_id=#{video_id} #{e.class}: #{e.message}")
    raise
  ensure
    src.close!   if src
    thumb.close! if defined?(thumb) && thumb
  end
end
