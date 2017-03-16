require 'rails_helper'

RSpec.describe Operative::ExtractVerifyService, datafeed: :true do
  let(:company) { Company.first }
  let(:files) { './testfile_4148282_v3.tar.gz' }
  let(:tar_archive) { double() }
  subject(:subject) { Operative::ExtractVerifyService.new(files) }

  describe '#perform' do
    it 'requests to download files' do
      expect(Zlib::GzipReader).to receive(:open).with('./testfile_4148282_v3.tar.gz').and_return(tar_archive)
      expect(Gem::Package::TarReader).to receive(:new).with(tar_archive).and_return(tar_archive)
      expect(tar_archive).to receive(:rewind)
      expect(tar_archive).to receive(:each)
      expect(tar_archive).to receive(:close)
      subject.perform
    end
  end

  def sales_orders
    @_sales_orders ||= double('sales_orders', full_name: 'Sales_Order_03052017.csv')
    # allow(@_sales_orders).to receive(:full_name).and_return('Sales_Order_03052017.csv')
  end

  def sales_order_items
    @_sales_order_items ||= double('sales_order_items', full_name:'Sales_Order_Line_Items_03052017.csv') 
    # allow(@_sales_order_items).to receive(:full_name).and_return('Sales_Order_Line_Items_03052017.csv')
  end

  def invoice_items
    @_invoice_items ||= double('invoice_items', full_name: 'Invoice_Line_Item_03052017.csv')
    # allow(@_invoice_items).to receive(:full_name).and_return('Invoice_Line_Item_03052017.csv')
  end

  def extra_file
    @_extra_file ||= double('extra_file', full_name: 'Extra_File_03052017.csv')
    # allow(@_extra_file).to receive(:full_name).and_return('Extra_File_03052017.csv')
  end
end
