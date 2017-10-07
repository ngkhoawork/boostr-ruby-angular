class PmpMember < ActiveRecord::Base
  belongs_to :pmp
  belongs_to :user
end