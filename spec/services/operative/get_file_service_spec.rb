require 'rails_helper'

describe Operative::GetFileService, datafeed: :true do
  subject(:subject) { Operative::GetFileService.new(api_config, timestamp) }

  it 'downloads file via SFTP' do
    expect(Net::SFTP).to receive(:start).with('ftpprod.operativeftphost.com', 'email@test.com', password: 'password')
    subject.perform
  end

  it 'returns array of downloaded filenames' do
    allow(Net::SFTP).to receive(:start).and_return(:success)
    subject.perform
    expect(subject.data_filename_local).to eql ".#{Dir.tmpdir}/KING_DataFeed_#{timestamp}_v3.tar.gz"
  end

  it 'returns success status' do
    expect(subject.success).to be false
    allow(Net::SFTP).to receive(:start).and_return(:success)
    subject.perform
    expect(subject.success).to be true
  end

  context 'download errors' do
    it 'returns false on errors' do
      allow(Net::SFTP).to receive(:start).and_raise(SocketError, 'getaddrinfo: Name or service not known')
      subject.perform
      expect(subject.success).to be false
    end

    it 'returns error message on error' do
      allow(Net::SFTP).to receive(:start).and_raise(SocketError, 'getaddrinfo: Name or service not known')
      subject.perform
      expect(subject.error).to eql ['SocketError', 'getaddrinfo: Name or service not known']
    end
  end

  def company
    @_company ||= create :company, name: 'King'
  end

  def api_config
    @_api_config ||= create :operative_datafeed_configuration, company: company
  end

  def timestamp
    Date.today.strftime('%m%d%Y')
  end
end
