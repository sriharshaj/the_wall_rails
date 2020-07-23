module Authenticable
  extend ActiveSupport::Concern

  def authenticate_user!
    render json: { message: 'Please log in' },
      status: :unauthorized unless logged_in?
  end

  def encode_token(payload)
    JWT.encode(payload, ENV['JWT_SECRET'])
  end

  private

  def logged_in?
    logged_in_user
  end

  def logged_in_user
    decoded_token = decode_token
    if decoded_token
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end
  end

  def decode_token
    if auth_header
      token = auth_header.split(' ')[1]
      begin
        JWT.decode(token, ENV['JWT_SECRET'], true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def auth_header
    request.headers['Authorization']
  end
end
