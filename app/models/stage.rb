class Stage < ActiveRecord::Base
  belongs_to :company
  has_many :deals
end
