require 'rails_helper'

RSpec.describe DatafeedConfigurationDetails, type: :model do
  describe '.get_pattern_id' do
    calculation_patterns = { 'Invoice Units' => 0, 'Recognized Revenue' => 1, 'Invoice Amount' => 2 }
    calculation_patterns.each do |name, id|
      it "returns #{id} for #{name}" do
        expect(DatafeedConfigurationDetails.get_pattern_id(name)).to be id
      end
    end

    it 'renurns nil for missing value' do
      expect(DatafeedConfigurationDetails.get_pattern_id(nil)).to be nil
    end
  end

  describe '.get_pattern_name' do
    calculation_patterns = { 'Invoice Units' => 0, 'Recognized Revenue' => 1, 'Invoice Amount' => 2 }
    calculation_patterns.each do |name, id|
      it "returns #{name} for #{id}" do
        expect(DatafeedConfigurationDetails.get_pattern_name(id)).to eq name
      end
    end

    it 'renurns nil for missing value' do
      expect(DatafeedConfigurationDetails.get_pattern_name(nil)).to be nil
    end
  end

  describe '.get_product_mapping_id' do
    product_mapping = { 'Product_Name' => 0, 'Forecast_Category' => 1 }
    product_mapping.each do |name, id|
      it "returns #{id} for #{name}" do
        expect(DatafeedConfigurationDetails.get_product_mapping_id(name)).to be id
      end
    end

    it 'renurns nil for missing value' do
      expect(DatafeedConfigurationDetails.get_product_mapping_id(nil)).to be nil
    end
  end

  describe '.get_product_mapping_name' do
    product_mapping = { 'Product_Name' => 0, 'Forecast_Category' => 1 }
    product_mapping.each do |name, id|
      it "returns #{name} for #{id}" do
        expect(DatafeedConfigurationDetails.get_product_mapping_name(id)).to eq name
      end
    end

    it 'renurns nil for missing value' do
      expect(DatafeedConfigurationDetails.get_product_mapping_name(nil)).to be nil
    end
  end
end
