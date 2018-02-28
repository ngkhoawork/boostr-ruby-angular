FactoryGirl.define do
  factory :pmp_member do
    share 100
    from_date Date.new(2015, 7, 29)
    to_date Date.new(2015, 8, 29)
    pmp
    user
  end
end
