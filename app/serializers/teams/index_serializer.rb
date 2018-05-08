class Teams::IndexSerializer < Teams::BaseSerializer
  attributes :leader_name

  has_many :members
  has_many :children
  has_one :parent
end
