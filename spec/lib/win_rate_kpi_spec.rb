require 'rails_helper'

RSpec.describe TimePeriods do
  let!(:year) { Date.current.year }

  describe '#quarters' do
    it 'returns quarters from the start/end dates' do
      start_date = Date.new(year, 1, 10)
      end_date = Date.new(year, 5, 5)
      expect(subject.quarters(start_date..end_date)).to eq([
        start_date..start_date.end_of_quarter,
        end_date.beginning_of_quarter..end_date
      ])
    end

    it 'returns a single quarter if dates are within the same quarter' do
      start_date = Date.new(year, 1, 10)
      end_date = Date.new(year, 2, 5)
      expect(subject.quarters(start_date..end_date)).to eq([start_date..end_date])
    end
  end

  describe '#months' do
    it 'returns months from the start/end dates' do
      start_date = Date.new(year, 1, 10)
      end_date = Date.new(year, 3, 5)
      expect(subject.months(start_date..end_date)).to eq([
        start_date..start_date.end_of_month,
        Date.new(year, 2, 1)..Date.new(year, 2, 1).end_of_month,
        end_date.beginning_of_month..end_date
      ])
    end

    it 'returns a single quarter if dates are within the same quarter' do
      start_date = Date.new(year, 1, 10)
      end_date = Date.new(year, 1, 15)
      expect(subject.months(start_date..end_date)).to eq([start_date..end_date])
    end
  end

end
