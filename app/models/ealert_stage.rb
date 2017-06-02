class EalertStage < ActiveRecord::Base
  belongs_to :company
  belongs_to :ealert
  belongs_to :stage
end
