class VideosController < ApplicationController
  def index
    @videos = Video.includes(:user).with_attached_file.with_attached_thumbnail.order(created_at: :desc)
  end

  def new
    @video = Video.new
  end

  def show
    @video = Video.find(params[:id])
  end

  def edit
    @video = current_user.videos.find(params[:id])
  end

  def update
    @video = current_user.videos.find(params[:id])
    if @video.update(video_params)
      redirect_to videos_path(@video)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @video = current_user.videos.find(params[:id])
    @video.destroy!
    redirect_to videos_path
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
