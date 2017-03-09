require 'rails_helper'

RSpec.describe Operative::DatafeedService, datafeed: :true do
  let(:company) { Company.first }
  let(:config) { { company_name: company.name, login: 'fs_king.u', password: 'hVmSKJfJ0YzA7w==', host: 'ftpprod.operativeone.com' } }
  subject(:subject) { Operative::DatafeedService.new(company.id) }

  describe '#perform' do
    it 'requests to download files' do
      expect(Operative::GetFileService).to receive_message_chain(:new, :perform).and_return([''])
      subject.perform
    end
  end
end
