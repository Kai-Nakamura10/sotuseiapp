class VideosController < ApplicationController
  def index
    @videos = Video.includes(:user).with_attached_file.with_attached_thumbnail.order(created_at: :desc)
  end

  def new
    @video = Video.new
  end

  def edit
    @video = Video.find(params[:id])
  end

  def create
    @video = Video.new(video_params)
    @video.user = current_user
    if @video.save
      redirect_to videos_path, notice: "保存しました"
    else
      @videos = Video.with_attached_file.with_attached_thumbnail.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  private

  def video_params
    params.require(:video).permit(:title, :description, :visibility, :file, :thumbnail)
  end
end
