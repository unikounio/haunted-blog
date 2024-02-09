# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: [:show]
  before_action :check_authority, only: [:show]
  before_action :set_blog_for_owner, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def check_authority
    raise ActiveRecord::RecordNotFound if @blog.secret && unauthorized?
  end

  def unauthorized?
    current_user.nil? || !@blog.owned_by?(current_user)
  end

  def set_blog_for_owner
    @blog = current_user.blogs.find(params[:id])
  end

  def blog_params
    permitted_params = %i[title content secret]
    permitted_params << :random_eyecatch if current_user.premium?
    params.require(:blog).permit(*permitted_params)
  end
end
