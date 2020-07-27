require 'rails_helper'

RSpec.describe "Users", type: :request do
  let (:user) { FactoryBot.create :user }

  describe '#create' do
    context 'when user params are valid' do
      let (:user_attributes) { FactoryBot.attributes_for :user }
      before do
        headers = {"ACCEPT" => "application/json"}
        post users_path, params: user_attributes, headers: headers
      end

      it 'creates new user' do
        username = user_attributes[:username]
        expect(User.find_by(username: username)).not_to be_nil
      end

      it 'responds with 201' do
        expect(response).to have_http_status 201
      end

      it 'responds with user' do
        response_body = JSON.parse response.body
        expect(response_body).to include('user')

        username = user_attributes[:username]
        @user_hash = response_body['user']
        @user = User.find_by(username: username)
        excluded_fields = ['created_at', 'updated_at']

        expect(@user_hash.except! *excluded_fields).
          to eq @user.attributes.except!(*excluded_fields)
      end

      it 'responds with auth token' do
        response_body = JSON.parse response.body
        expect(response_body).to include('token')
      end
    end

    context 'when user params are not valid' do
      let (:user_attributes) { FactoryBot.attributes_for :user }
      before do
        user_attributes[:username] = ''
        headers = {"ACCEPT" => "application/json"}
        post users_path, params: user_attributes, headers: headers
      end

      it 'responds with error messages' do
        response_body = JSON.parse response.body
        expect(response_body).to include('error')
      end
      it 'responds with 400' do
        expect(response).to have_http_status 400
      end
    end
  end

  describe '#login' do
    context 'when user params are valid' do
      before do
        headers = { "ACCEPT" => "application/json" }
        auth_params = { username: user.username, password: 'test_password' }
        post login_path, params: auth_params, headers: headers
      end

      it 'responds with 200' do
        expect(response).to have_http_status 200
      end

      it 'responds with user' do
        response_body = JSON.parse response.body
        expect(response_body).to include('user')

        @user_hash = response_body['user']
        excluded_fields = ['created_at', 'updated_at']

        expect(@user_hash.except! *excluded_fields).
          to eq user.attributes.except!(*excluded_fields)
      end

      it 'responds with auth token' do
        response_body = JSON.parse response.body
        expect(response_body).to include('token')
      end
    end

    context 'when user params are not valid' do
      before do
        headers = { "ACCEPT" => "application/json" }
        auth_params = { username: user.username, password: 'password_test' }
        post login_path, params: auth_params, headers: headers
      end

      it 'responds with error message' do
        response_body = JSON.parse response.body
        expect(response_body).to include('error')
      end

      it 'responds with 400' do
        expect(response).to have_http_status 400
      end
    end
  end

  describe '#auto_login' do
    context 'when auth token is valid' do
      before do
        post login_path,
          params: {username: user.username, password: 'test_password'}
        token = 'JWT ' + JSON.parse(response.body)['token']
        headers = {'AUTHORIZATION' => token, "ACCEPT" => "application/json"}
        get auto_login_path, headers: headers
      end

      it 'responds with 200' do
        expect(response).to have_http_status 200
      end

      it 'responds with user' do
        response_body = JSON.parse response.body
        excluded_fields = ['created_at', 'updated_at']

        expect(response_body.except! *excluded_fields).
          to eq user.attributes.except!(*excluded_fields)
      end
    end

    context 'when auth token is not valid' do
      before do
        headers = {"ACCEPT" => "application/json"}
        get auto_login_path, headers: headers
      end

      it 'responds with 401' do
        expect(response).to have_http_status 401
      end
    end
  end
end
