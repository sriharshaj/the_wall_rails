class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:auto_login]

  def create
    @user = User.new
    @user.assign_attributes(user_params)
    if @user.valid?
      @user.save
      token = encode_token({user_id: @user.id})
      render json: {user: @user, token: token}, status: :created
    else
      render json: {error: @user.error_messages}, status: :bad_request
    end
  end

  def login
    @user = User.find_by(username: params[:username])

    if @user && @user.authenticate(params[:password])
      token = encode_token({user_id: @user.id})
      render json: {user: @user, token: token}
    else
      render json: {error: "Unable to log in with provided credentials."},
        status: :bad_request
    end
  end

  def auto_login
    render json: @user
  end

  private

  def user_params
    params.permit(:username, :password, :email)
  end
end
