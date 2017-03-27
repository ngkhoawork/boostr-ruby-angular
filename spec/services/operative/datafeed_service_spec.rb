require 'rails_helper'

RSpec.describe Operative::DatafeedService, datafeed: :true do
  subject(:subject) { Operative::DatafeedService.new(api_config, Date.today) }

  describe '#perform' do
    it 'requests to download files' do
      expect(Operative::GetFileService).to receive(:new).and_return(fileservice)
      expect(fileservice).to receive(:perform)
      expect(fileservice).to receive(:error).and_return(nil)
      expect(fileservice).to receive(:data_filename_local).and_return('')
      expect(Operative::ExtractVerifyService).to receive_message_chain(:new, :perform).and_return({})
      expect(Operative::ImportSalesOrdersService).to receive_message_chain(:new, :perform).and_return({})
      expect(Operative::ImportSalesOrderLineItemsService).to receive_message_chain(:new, :perform).and_return({})
      subject.perform
    end
  end

  def company
    @_company ||= Company.first
  end

  def fileservice
    @_fileservice ||= double
  end

  def api_config
    @_api_config ||= create :api_configuration, company: company, api_email: 'email', password: 'password', base_link: 'ftpprod.operativeftphost.com'
  end
end