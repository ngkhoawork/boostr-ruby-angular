require 'rails_helper'

RSpec.describe Operative::ImportSalesOrdersService, datafeed: :true do
  subject(:subject) { Operative::ImportSalesOrdersService.new(sales_order_file) }
  let(:company) { Company.first }
  let(:sales_order_file) { './datafeed/sales_order_file.csv' }
  let(:transform) { double() }

  describe '#perform' do
    it 'opens file' do
      expect(File).to receive(:open).with(sales_order_file, 'r:ISO-8859-1').and_return(sales_order_file)
      subject.perform
    end

    it 'parses CSV file' do
      allow(File).to receive(:open).with(sales_order_file, 'r:ISO-8859-1').and_return(sales_order_file)
      expect(Transforms::SalesOrderTransform).to receive(:new).with(sales_order_file).and_return(transform)
      expect(transform).to receive(:transform)
      subject.perform
    end
  end
end
