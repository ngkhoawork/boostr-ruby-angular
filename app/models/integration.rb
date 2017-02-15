class Integration < ActiveRecord::Base
  belongs_to :integratable, polymorphic: true
end
