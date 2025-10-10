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
      respond_to do |format|
        format.html { redirect_to videos_path, notice: "保存しました" }
        format.json { render json: { id: @video.id }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @video.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def video_params
    params.require(:video).permit(:title, :description, :visibility, :file, :thumbnail, :source_key, :status)
  end
end
