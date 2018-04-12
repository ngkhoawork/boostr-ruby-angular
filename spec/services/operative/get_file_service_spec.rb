require 'rails_helper'

describe Operative::GetFileService, datafeed: :true do
  subject(:subject) { Operative::GetFileService.new(api_config, timestamp) }

  context 'FTP host parsing' do
    it 'detects bare hostname' do
      api_config(base_link: 'ftpprod.operativeftphost.com')

      expect(Net::SFTP).to receive(:start).with('ftpprod.operativeftphost.com', 'email@test.com', password: 'password')

      subject.perform
    end

    it 'detects uri and parses host' do
      api_config(base_link: 'ftp://ftpprod.operativeftphost.com/Datafeed')

      expect(Net::SFTP).to receive(:start).with('ftpprod.operativeftphost.com', 'email@test.com', password: 'password')

      subject.perform
    end

    it 'handles nil value' do
      api_config(base_link: nil)

      expect(Net::SFTP).to receive(:start).with(nil, 'email@test.com', password: 'password')

      subject.perform
    end
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

  context 'intraday' do
    subject(:subject) { Operative::GetFileService.new(api_config, timestamp, intraday: true) }

    it 'downloads latest intraday file' do
      allow(Net::SFTP).to receive(:start).and_return(:success)
      subject.instance_variable_set(:@hhmm, '_1130')
      subject.perform
      expect(subject.data_filename_local).to eql ".#{Dir.tmpdir}/KING_DataFeed_#{timestamp}_1130_v3_intraday.tar.gz"
    end

    it 'picks latest intraday file' do
      set_intraday_candidates(subject)

      expect(subject.data_filename_remote).to eql "./datafeed/KING_DataFeed_#{timestamp}_2130_v3_intraday.tar.gz"
      expect(subject.data_filename_local).to eql ".#{Dir.tmpdir}/KING_DataFeed_#{timestamp}_2130_v3_intraday.tar.gz"
    end
  end

  def company
    @_company ||= create :company, name: 'King'
  end

  def api_config(opts={})
    defaults = {
      company: company
    }

    @_api_config ||= create :operative_datafeed_configuration, defaults.merge(opts)
  end

  def timestamp
    Date.today.strftime('%m%d%Y')
  end

  def set_intraday_candidates(subject)
    arr = [
      "KING_DataFeed_03272018_1509_v3_intraday.tar.gz",
      "KING_DataFeed_03272018_2130_v3_intraday.tar.gz",
      "KING_DataFeed_03272018_1212_v3_intraday.tar.gz",
      "KING_DataFeed_03272018_0912_v3_intraday.tar.gz"
    ]

    subject.instance_variable_set(:@intraday_candidates, arr)
  end
end
