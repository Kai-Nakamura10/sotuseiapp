class VideosController < ApplicationController
  def index
    @videos = Video.order(created_at: :desc)
    @video = Video.new
  end

  def create
    @video = Video.new(video_params)
    @video.user = current_user
    if @video.save
      redirect_to videos_path, notice: "保存しました"
    else
      @videos = Video.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  private

  def video_params
    params.require(:video).permit(:title, :description, :duration_seconds, :visibility, :file, :thumbnail)
  end
end
