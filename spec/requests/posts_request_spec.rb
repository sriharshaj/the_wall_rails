require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let (:user) { FactoryBot.create :user }
  before { FactoryBot.create_list(:post, 10, user: user) }

  describe '#index' do
    before { get posts_path}

    it 'responds with all posts' do
      response_body = JSON.parse response.body
      expect(response_body).to include 'posts'
      expect(response_body['posts'].length).to eql Post.count
    end

    it 'responds with 200' do
      expect(response).to have_http_status 200
    end
  end

  describe '#create' do
    context 'when logged in' do
      before do
        post login_path,
          params: {username: user.username, password: 'test_password'}
        token = 'JWT ' + JSON.parse(response.body)['token']
        @headers = {'AUTHORIZATION' => token, "ACCEPT" => "application/json"}
      end

      context 'when post params are valid' do
        before do
          @post_body = 'body test'
          post posts_path, params: {body: @post_body}, headers: @headers
        end
  
        it 'creates the post' do
          expect(Post.last.body).to eql @post_body
        end
  
        it 'responds with post' do
          response_body = JSON.parse response.body
          expect(response_body['id']).to eq Post.last.id
          expect(response_body['body']).to eq Post.last.body
        end
  
        it 'responds with 201' do
          expect(response).to have_http_status 201
        end
      end

      context 'when post params are invalid' do
        before do
          post posts_path, params: {body: ''}, headers: @headers
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

    context 'when logged out' do
      before { post posts_path, params: {body: @post_body} }
      it 'responds with 401' do
        expect(response).to have_http_status 401
      end
    end
  end

  describe '#show' do
    let (:post_obj) { FactoryBot.create :post, user: user }

    context 'when logged in' do
      before do
        post login_path,
          params: {username: user.username, password: 'test_password'}
        token = 'JWT ' + JSON.parse(response.body)['token']
        @headers = {'AUTHORIZATION' => token, "ACCEPT" => "application/json"}
      end

      context 'when post is found' do
        before { get post_path(post_obj.id), headers: @headers }
        it 'responds with post' do
          response_body = JSON.parse response.body
          expect(response_body['id']).to eq Post.last.id
          expect(response_body['body']).to eq Post.last.body
        end

        it 'responds with 200' do
          expect(response).to have_http_status 200
        end
      end

      context 'when post is not found' do
        before { get post_path(post_obj.id + 1), headers: @headers }
        it 'responds with 404' do
          expect(response).to have_http_status 404
        end
      end
    end

    context 'when logged out' do
      before { get post_path(post_obj.id), headers: @headers }
      it 'responds with 401' do
        expect(response).to have_http_status 401
      end
    end
  end

  describe '#update' do
    let (:updated_body) { 'updated body' }
    let (:post_obj) { FactoryBot.create :post, user: user }

    context 'when logged in' do
      before do
        post login_path,
          params: { username: user.username, password: 'test_password' }
        token = 'JWT ' + JSON.parse(response.body)['token']
        @headers = {'AUTHORIZATION' => token, 'ACCEPT' => 'application/json' }
      end

      context 'when post is found and owned' do
        context 'when post params are valid' do
          before do
            patch post_path(post_obj.id), params: { body: updated_body },
              headers: @headers
          end

          it 'updates post' do
            post_obj1 = Post.find(post_obj.id)
            expect(post_obj1.body).to eq updated_body
          end

          it 'responds with post' do
            response_body = JSON.parse response.body
            expect(response_body['id']).to eq post_obj.id
            expect(response_body['body']).to eq updated_body
          end

          it 'responds with 201' do
            expect(response).to have_http_status 201
          end
        end

        context 'when post params are invalid' do
          before do
            patch post_path(post_obj.id), params: { body: '' },
              headers: @headers
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

      context 'when post is not found' do
        before { patch post_path(post_obj.id + 1), 
          params: { body: updated_body }, headers: @headers }
        it 'responds with 404' do
          expect(response).to have_http_status 404
        end
      end

      context 'when post is not owned' do
        before do
          user_obj = FactoryBot.create :user
          post_obj = FactoryBot.create :post, user: user_obj
          patch post_path(post_obj.id),
            params: { body: updated_body } , headers: @headers
        end

        it 'responds with 404' do
          expect(response).to have_http_status 404
        end
      end
    end

    context 'when logged out' do
      before { patch post_path(post_obj.id),
        params: { body: updated_body } }

      it 'responds with 401' do
        expect(response).to have_http_status 401
      end
    end
  end

  describe '#destroy' do
    let (:post_obj) { FactoryBot.create :post, user: user }
    context 'when logged in' do
      before do
        post login_path,
          params: { username: user.username, password: 'test_password' }
        token = 'JWT ' + JSON.parse(response.body)['token']
        @headers = {'AUTHORIZATION' => token, 'ACCEPT' => 'application/json' }
      end

      context 'when post is found and owned' do
        before do
          @post_id = post_obj.id
          delete post_path(@post_id), headers: @headers
        end

        it 'destroys post' do
          expect(Post.find_by_id(@post_id)).to be_nil
        end
        it 'responds with 202' do
          expect(response).to have_http_status 202
        end
      end

      context 'when post is not found' do
        before { delete post_path(post_obj.id + 1), 
          headers: @headers }
        it 'responds with 404' do
          expect(response).to have_http_status 404
        end
      end

      context 'when post is not owned' do
        before do
          user_obj = FactoryBot.create :user
          post_obj = FactoryBot.create :post, user: user_obj
          delete post_path(post_obj.id),
              headers: @headers
        end

        it 'responds with 404' do
          expect(response).to have_http_status 404
        end
      end
    end

    context 'when logged out' do
      before { delete post_path(post_obj.id) }

      it 'responds with 401' do
        expect(response).to have_http_status 401
      end
    end
  end
end
