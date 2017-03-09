require 'rails_helper'

RSpec.describe Operative::GetFileService, datafeed: :true do
  subject(:subject) { Operative::GetFileService.new(config) }
  let(:company) { Company.first }
  let(:config) { { company_name: 'King', host: 'test.com', login: 'login', password: 'secret' } }

  describe '#perform' do
    before(:each) do
      expect(File).to receive(:exists?).with('datafeed').and_return(false)
      expect(Dir).to receive(:mkdir).with('datafeed')
    end

    it 'downloads file via SFTP' do
      expect(Net::SFTP).to receive(:start).with('test.com', 'login', password: 'secret')
      subject.perform
    end

    it 'returns array of downloaded filenames' do
      allow(Net::SFTP).to receive(:start).and_return(:success)
      expect(subject.perform).to eql([
        "./datafeed/KING_CONTROLFILE_#{timestamp}_v3.csv",
        "./datafeed/KING_DataFeed_#{timestamp}_v3.tar.gz"
      ])
    end
  end

  def timestamp
    Date.today.strftime('%m%d%Y')
  end
end
