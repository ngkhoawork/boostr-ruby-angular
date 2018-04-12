require 'rails_helper'

RSpec.describe Operative::DatafeedService, datafeed: :true do
  context 'fullday' do
    subject(:subject) { Operative::DatafeedService.new(api_config, Date.today) }

    describe '#perform' do
      it 'requests to download files' do
        expect(Operative::GetFileService).to(
          receive(:new).with(api_config, Date.today.strftime('%m%d%Y'), intraday: false).and_return(fileservice)
        )

        expect(fileservice).to receive(:perform)
        expect(fileservice).to receive(:error).and_return(nil)
        expect(fileservice).to receive(:data_filename_local).and_return('')
        expect(fileservice).to receive(:hhmm).and_return('')

        expect(Operative::ExtractVerifyService).to receive_message_chain(:new, :perform).and_return({})
        expect(Operative::ImportSalesOrdersService).to receive_message_chain(:new, :perform).and_return({})
        expect(Operative::ImportSalesOrderLineItemsService).to receive_message_chain(:new, :perform).and_return({})
        expect(Operative::ImportInvoiceLineItemsService).to receive_message_chain(:new, :perform).and_return({})
        subject.perform
      end
    end
  end

  context 'intraday' do
    subject(:subject) { Operative::DatafeedService.new(api_config, Date.today, intraday: true) }

    describe '#perform' do
      it 'requests to download files' do
        expect(Operative::GetFileService).to(
          receive(:new).with(api_config, Date.today.strftime('%m%d%Y'), intraday: true).and_return(fileservice)
        )

        expect(fileservice).to receive(:perform)
        expect(fileservice).to receive(:error).and_return(nil)
        expect(fileservice).to receive(:data_filename_local).and_return('')
        expect(fileservice).to receive(:hhmm).and_return('')

        expect(Operative::ExtractVerifyService).to receive_message_chain(:new, :perform).and_return({})
        expect(Operative::ImportSalesOrdersService).to receive_message_chain(:new, :perform).and_return({})
        expect(Operative::ImportSalesOrderLineItemsService).to receive_message_chain(:new, :perform).and_return({})
        expect(Operative::ImportInvoiceLineItemsService).to receive_message_chain(:new, :perform).and_return({})
        subject.perform
      end
    end
  end

  def company
    @_company ||= create :company
  end

  def fileservice
    @_fileservice ||= double
  end

  def api_config
    @_api_config ||= create :operative_datafeed_configuration, company: company
  end
end
