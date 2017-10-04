require 'rails_helper'

RSpec.describe Api::MailtrackController, type: :controller do

  describe 'GET #open_mail' do
    it 'should track opened email' do
      create :email_thread

      # encoded params email=example@gmail.com&guid=12345
      pixel = 'ZW1haWw9ZXhhbXBsZUBnbWFpbC5jb20mZ3VpZD0xMjM0NQ==.png'

      expect do
        get :open_mail, pixel: pixel
        expect(response).to be_success
      end.to change(EmailOpen, :count).by(1)
    end
  end
end