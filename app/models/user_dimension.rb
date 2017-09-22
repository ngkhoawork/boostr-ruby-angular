class UserDimension < ActiveRecord::Base
  belongs_to :team
  belongs_to :company
end
