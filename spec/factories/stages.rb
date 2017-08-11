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

    factory :won_stage do
      name 'Won'
      probability 100
      open true
      active true
    end

    factory :closed_won_stage do
      name 'Closed Won'
      probability 100
      open false
      active true
    end

    factory :discuss_stage do
      name 'Discuss Requirements'
      probability 25
      open true
      active true
    end

    factory :proposal_stage do
      name 'Proposal'
      probability 50
      open true
      active true
    end

    factory :lost_stage do
      name 'Closed Lost'
      probability 0
      open false
      active true
    end
  end
end
