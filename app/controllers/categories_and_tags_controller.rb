class CategoriesAndTagsController < ApplicationController
  def index
    @categories = Category.order(:name)
    @tags = Tag.order(:name)
  end
end
