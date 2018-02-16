require 'rails_helper'

RSpec.describe Api::MailtrackController, type: :controller do

  describe 'GET #open_mail' do
    before do
      VCR.insert_cassette geo_position_stub[:remote_ip]
      @request.env['REMOTE_ADDR'] = geo_position_stub[:remote_ip]
      @request.env['HTTP_USER_AGENT'] = 'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) CriOS/61.0.3163.73 Mobile/15A402 Safari/602.1'

      expect(Geocoder).to receive(:search).and_return(geocoder_response_stub)
    end

    it 'should track opened email' do
      create :email_thread
      # encoded params email=example@gmail.com&guid=12345
      pixel = 'ZW1haWw9ZXhhbXBsZUBnbWFpbC5jb20mZ3VpZD0xMjM0NQ==.png'

      expect do
        get :open_mail, pixel: pixel
        expect(response).to be_success
      end.to change(EmailOpen, :count).by(1)

      expect(EmailOpen.last.ip).to eq geo_position_stub[:remote_ip]
      expect(EmailOpen.last.location).to eq geo_position_stub[:city]
      expect(EmailOpen.last.device).to eq 'iPhone, Chrome Mobile iOS'
      expect(EmailOpen.last.is_gmail).to be_truthy
    end
  end

  private

  def geo_position_stub
    @geo_position_stub ||= {
      remote_ip: '66.102.9.47',
      city: 'Mountain View'
    }
  end

  def geocoder_response_stub
    [Hashie::Mash.new(data: { city: geo_position_stub[:city] })]
  end
end