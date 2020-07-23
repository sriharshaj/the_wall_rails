class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    render json: {posts: Post.all}
  end

  def create
    @post = @user.posts.new
    assign_params_to_post
  end

  def show
    begin
      @post = Post.find(params[:id])
      render json: @post
    rescue ActiveRecord::RecordNotFound => e
      post_not_found
    end
  end

  def update
    begin
      @post = @user.posts.find(params[:id])
      assign_params_to_post
    rescue ActiveRecord::RecordNotFound => e
      post_not_found
    end
  end

  def destroy
    begin
      @post = @user.posts.find(params[:id])
      @post.destroy
      render status: :accepted
    rescue ActiveRecord::RecordNotFound => e
      post_not_found
    end
  end

  private

  def assign_params_to_post  
    @post.assign_attributes(post_params)
    if @post.valid?
      @post.save
      render json: @post, status: :created
    else
      render json: {error: @user.error_messages}, status: :bad_request
    end
  end

  def post_not_found
    render json: {
      error: "Cannot find the post"
    }, status: :not_found
  end

  def post_params
    params.permit(:body)
  end
end
