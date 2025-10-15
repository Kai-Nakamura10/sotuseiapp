class VideoTagsController < ApplicationController
  before_action :set_video

  def create
    if params[:tag_id].present?
      @tag = Tag.find(params[:tag_id])
    else
      name = params[:name].to_s.strip
      @tag = Tag.find_or_create_by!(name: name)
    end

    @video.tags << @tag unless @video.tags.exists?(@tag.id)
    VideoTag.find_or_create_by!(video: @video, tag: @tag)

    respond_to do |f|
      f.html { redirect_to @video, notice: "タグをつけました" }
      f.turbo_stream
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    @video.video_tags.find_by!(tag_id: @tag.id).destroy!
    respond_to do |f|
      f.html { redirect_to @video, notice: "タグを外しました" }
      f.turbo_stream
    end
  end

  private

  def set_video
    @video = Video.find(params[:video_id])
  end
end
