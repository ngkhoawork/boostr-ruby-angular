class Statistic < ActiveRecord::Base
  scope :by_pmp_id, -> (id) { where("pmp_ids @> ARRAY[?]::varchar[]", id)}
end
