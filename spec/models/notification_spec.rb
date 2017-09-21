require 'rails_helper'

describe Notification do
  let(:company) { create :company }

  context 'validation' do
    it { should validate_presence_of(:name) }
  end
end
