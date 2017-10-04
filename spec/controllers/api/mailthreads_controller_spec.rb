require 'rails_helper'

RSpec.describe Api::MailthreadsController, type: :controller do
  describe 'GET #index' do
    it 'should return email thread with email opens' do
      first_opened_email = create :email_open, thread_id: thread.email_thread_id, opened_at: Date.yesterday
      last_opened_email = create :email_open, thread_id: thread.email_thread_id, opened_at: Date.today

      get :index, thread_ids: [thread.email_thread_id, '77777']
      response_data = JSON.parse(response.body)['threads'].first.deep_symbolize_keys

      expect(response_data[:email_thread_id]).to eq thread.email_thread_id
      expect(response_data[:email_opens_count]).to eq 2
      expect(response_data[:first_opened_email][:thread_id]).to eq thread.email_thread_id
      expect(response_data[:first_opened_email][:opened_at].to_date).to eq first_opened_email.opened_at
      expect(response_data[:first_opened_email][:opened_at].to_date).to_not eq last_opened_email.opened_at
    end

    it 'should not return email threads' do
      expect do
        get :index, thread_ids: ''
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'POST #create_thread' do
    it 'should create email thread by thread id' do
      expect do
        post :create_thread, thread_id: '123456'
        expect(response).to be_success
      end.to change(EmailThread, :count).by(1)
    end

    it 'should not create email thread' do
      thread = create :email_thread, email_thread_id: '12345'

      expect do
        post :create_thread, thread_id: thread.email_thread_id
        expect(response.status).to eq(422)
      end.to_not change(EmailThread, :count)
    end
  end

  describe 'GET #see_more_opens' do
    it 'should return 2 email opens by thread' do
      create_list :email_open, 2

      get :see_more_opens, thread_id: thread.email_thread_id
      response_data = JSON.parse(response.body).deep_symbolize_keys

      expect(response_data[:opened_emails].size).to eq 2
    end

    it 'should not return 2 email opens by thread' do
      get :see_more_opens, thread_id: '00000'
      response_data = JSON.parse(response.body).symbolize_keys

      expect(response_data[:opened_emails].size).to eq 0
    end
  end

  private

  def thread
    @_thread ||= create :email_thread, email_thread_id: '12345'
  end
end