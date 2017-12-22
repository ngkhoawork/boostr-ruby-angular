require 'rails_helper'

RSpec.describe Api::V2::EmailThreadsController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  before do
    valid_token_auth user
  end

  describe 'GET #index' do
    it 'should return email thread with email opens' do
      first_opened_email = create :email_open, guid: thread.email_guid, opened_at: Date.yesterday
      last_opened_email = create :email_open, guid: thread.email_guid, opened_at: Date.today

      get :all_threads, thread_ids: [ thread.thread_id, '77777' ]
      response_data = JSON.parse(response.body)['threads'][thread.thread_id].deep_symbolize_keys

      expect(response_data[:thread_guid]).to eq thread.email_guid
      expect(response_data[:email_opens_count]).to eq 2
      expect(response_data[:last_open][:guid]).to eq thread.email_guid
      expect(response_data[:last_open][:opened_at].to_date).to eq last_opened_email.opened_at
      expect(response_data[:last_open][:opened_at].to_date).to_not eq first_opened_email.opened_at
    end

    it 'should not return email threads' do
      expect do
        get :all_threads, thread_ids: ''
        expect(response.status).to eq(422)
      end
    end

    it 'should return thread without opening email' do
      get :all_threads, thread_ids: [ thread.thread_id ]
      response_data = JSON.parse(response.body)['threads'][thread.thread_id].deep_symbolize_keys

      expect(response_data[:email_opens_count]).to be_zero
      expect(response_data[:last_open]).to be_nil
    end
  end

  describe 'GET #create_thread' do
    it 'should create email thread by thread id' do
      params = {
        email_guid: '123456',
        thread_id: '111',
        gmail_query_string: {subject: "333", from: "test1@gmail.com", to: ["test@gmail.com"], body: "test"}
      }

      expect do
        post :create_thread, params
        expect(response).to be_success
      end.to change(EmailThread, :count).by(1)

      thread = EmailThread.last

      expect(thread.email_guid).to eq params[:email_guid]
      expect(thread.thread_id).to eq params[:thread_id]
      expect(thread.body).to_not be_nil
      expect(thread.subject).to_not be_nil
    end

    it 'should not create email thread' do
      thread = create :email_thread, email_guid: '12345'

      expect do
        get :create_thread, guid: thread.email_guid
        expect(response.status).to eq(422)
      end.to_not change(EmailThread, :count)
    end
  end

  describe 'GET #all_opens' do
    it 'should return 2 email opens by thread' do
      create_list :email_open, 2

      get :all_opens, email_thread_id: thread.thread_id
      response_data = JSON.parse(response.body)

      expect(response_data.size).to eq 2
    end

    it 'should not return error message that thread not found' do
      get :all_opens, email_thread_id: '00000'
      response_data = JSON.parse(response.body).symbolize_keys

      expect(response_data[:errors]).to eq "Email Thread Not Found"
    end
  end

  describe 'GET #all_emails' do
    it 'should return all email threads' do
      thread_with_opens

      get :all_emails
      response_data = JSON.parse(response.body).first.deep_symbolize_keys

      expect(response_data).to_not be_nil
      expect(response_data[:last_five_opens]).to_not be_empty
    end
  end

  describe 'GET #all_not_opened_emails' do
    it 'should return email threads by search' do
      thread '11'

      get :all_not_opened_emails
      response_data = JSON.parse(response.body)

      expect(response_data).to_not be_empty
    end
  end

  private

  def thread(email_guid = '12345')
    @_thread ||= create :email_thread,
                        email_guid: email_guid,
                        thread_id: '123',
                        subject: 'Possible deal',
                        recipient: 'John',
                        recipient_email: 'john@gmail.com',
                        user: user
  end

  def thread_with_opens
    @_email_open = create :email_open, guid: thread.email_guid, opened_at: Date.yesterday
  end
end