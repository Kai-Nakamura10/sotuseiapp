class VideoTagsController < ApplicationController
  before_action :set_video
  before_action :set_tag

  def create
    if @video.tags.exists?(@tag.id)
      respond_to do |f|
        f.html { redirect_to @video, alert: "このタグは既に追加されています" }
        f.turbo_stream
        f.json { render json: { error: "already_exists" }, status: :unprocessable_entity }
      end
      return
    end

    @video.tags << @tag
    respond_to do |f|
      f.html { redirect_to @video, notice: "タグを追加しました" }
      f.turbo_stream
      f.json { render json: { ok: true, tag_id: @tag.id }, status: :created }
    end
  end

  def destroy
    vt = @video.video_tags.find_by!(tag_id: @tag.id)
    vt.destroy!
    respond_to do |f|
      f.html { redirect_to @video, notice: "タグを削除しました" }
      f.turbo_stream
      f.json { head :no_content }
    end
  end

  private

  def set_video
    @video = Video.find(params[:video_id])
  end

  # :id（ネスト資源のid）でも :tag_id でも受けられるように
  def set_tag
    tag_id = params[:id] || params[:tag_id]
    if tag_id.present?
      @tag = Tag.find(tag_id)
    elsif params[:name].present?
      @tag = Tag.find_or_create_by!(name: params[:name].to_s.strip)
    else
      raise ActiveRecord::RecordNotFound, "tag id or name is required"
    end
  end
end
