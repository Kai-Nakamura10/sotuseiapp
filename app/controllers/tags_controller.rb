class TagsController < ApplicationController
  def index
    @tags = Tag.order(:name)
  end

  def show
    @tag = Tag.find(params[:id])
    @videos = @tag.videos.includes(:tags).order(created_at: :desc)
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      redirect_to tags_path, notice: "タグを作成しました"
    else
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy!
    redirect_to tags_path, notice: "タグを削除しました"
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
