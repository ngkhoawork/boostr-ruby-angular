require 'rails_helper'

RSpec.describe SalesProcess, 'model' do
  describe 'scopes' do
    context 'active' do
      before do
        create :sales_process, active: true
        create :sales_process, active: false
      end

      it 'returns active sales processes' do
        expect(SalesProcess.count).to eq(2)
        expect(SalesProcess.is_active(true).count).to eq(1)
      end

      it 'return inactive sales processes' do
        expect(SalesProcess.count).to eq(2)
        expect(SalesProcess.is_active(false).count).to eq(1)
      end
    end
  end
end

RSpec.describe SalesProcess, 'validation' do
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:company_id) }
end

RSpec.describe SalesProcess, 'association' do
  it { should belong_to(:company) }
  it { should have_many(:stages) }
  it { should have_many(:teams) }
end