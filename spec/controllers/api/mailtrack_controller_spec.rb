require 'rails_helper'

RSpec.describe Api::MailtrackController, type: :controller do

  describe 'GET #open_mail' do
    it 'should track opened email' do
      create :email_thread

      pixel = "aXA9MTI4LjEyOC4xMjguMSZlbWFpbD1leGFtcGxlQGdtYWlsLmNvbSZkZXZpY2U9c29tZSBpbmZvJnRocmVhZF9pZD0xMjM0NQ==.png"

      expect do
        get :open_mail, pixel: pixel
        expect(response).to be_success
      end.to change(EmailOpen, :count).by(1)
    end
  end

  describe 'POST #create_thread' do
    it 'should create email thread by thread id' do
      expect do
        post :create_thread, thread_id: "123456"
        expect(response).to be_success
      end.to change(EmailThread, :count).by(1)
    end

    it 'should not create email thread' do
      create :email_thread, email_thread_id: "12345"

      expect do
        post :create_thread, thread_id: "12345"
        expect(response.status).to eq(422)
      end.to_not change(EmailThread, :count)
    end
  end
end