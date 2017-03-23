FactoryGirl.define do
  factory :stage do
    name 'Prospect'
    probability 10
    open true
    active true
    color '#ffe630'

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end

    factory :closed_won_stage do
      name 'Closed Won'
      probability 100
      open false
      active true
    end
  end
end
