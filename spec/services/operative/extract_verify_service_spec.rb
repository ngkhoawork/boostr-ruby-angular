require 'rails_helper'

RSpec.describe Operative::ExtractVerifyService, datafeed: :true do
  let!(:company) { create :company }
  let(:files) { './testfile_4148282_v3.tar.gz' }
  let(:tar_archive) { double() }
  subject(:subject) { Operative::ExtractVerifyService.new(files, timestamp) }

  describe '#perform' do
    it 'decompresses files' do
      expect(Zlib::GzipReader).to receive(:open).with('./testfile_4148282_v3.tar.gz').and_return(tar_archive)
      expect(Gem::Package::TarReader).to receive(:new).with(tar_archive).and_return(tar_archive)
      expect(tar_archive).to receive(:rewind)
      expect(tar_archive).to receive(:each)
      expect(tar_archive).to receive(:close)
      subject.perform
    end
  end

  def timestamp
    Date.today.strftime('%m%d%Y')
  end
end
