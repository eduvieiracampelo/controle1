class TagsController < ApplicationController
  before_action :set_tag, only: [ :show, :edit, :update, :destroy ]

  def index
    @tags = Tag.order(:name)
  end

  def show; end

  def new
    @tag = Tag.new
  end

  def edit; end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      redirect_to @tag, notice: "Tag criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @tag.update(tag_params)
      redirect_to @tag, notice: "Tag atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tag.destroy
    redirect_to tags_path, notice: "Tag excluída com sucesso."
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
