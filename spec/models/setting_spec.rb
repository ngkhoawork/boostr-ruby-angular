require 'rails_helper'

RSpec.describe Setting, type: :model do
  describe '#valid' do
    before do
      valid_setting
    end
    
    it 'returns all valid setting models' do
      expect(Setting.valid.count).to eq(Setting::VALID_SETTINGS.count)
    end
  end

  describe '#get' do
    before do
      valid_setting
    end

    it 'returns setting value' do
      expect(Setting.get(:gcalendar_extension_url)).to eq('www')
      expect(Setting.get(:facebook_url)).to eq(nil)
    end
  end

  describe '.name' do
    it 'returns human readable setting name' do
      expect(setting.name).to eq('Facebook url')
      expect(valid_setting.name).to eq('GCalendar Extension URL')
    end
  end

  private

  def setting
    @_setting ||= create :setting, var: 'facebook_url', value: 'www.facebook.com'
  end

  def valid_setting
    @_valid_setting ||= create :setting, var: 'gcalendar_extension_url', value: 'www'
  end
end

RSpec.describe Setting, 'validation' do
  it { should validate_presence_of(:var) }
end
