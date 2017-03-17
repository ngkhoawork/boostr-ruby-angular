require 'rails_helper'

RSpec.describe Operative::GetFileService, datafeed: :true do
  subject(:subject) { Operative::GetFileService.new(api_config) }

  describe '#perform' do
    it 'downloads file via SFTP' do
      expect(Net::SFTP).to receive(:start).with('ftpprod.operativeftphost.com', 'email', password: 'password')
      subject.perform
    end

    it 'returns array of downloaded filenames' do
      allow(Net::SFTP).to receive(:start).and_return(:success)
      expect(subject.perform).to eql "./tmp/datafeed/KING_DataFeed_#{timestamp}_v3.tar.gz"
    end
  end

  def company
    @_company ||= create :company, name: 'King'
  end

  def api_config
    @_api_config ||= create :api_configuration, company: company, api_email: 'email', password: 'password', base_link: 'ftpprod.operativeftphost.com'
  end

  def timestamp
    Date.today.strftime('%m%d%Y')
  end
end
