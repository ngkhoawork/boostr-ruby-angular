class Teams::ChildSerializer < Teams::BaseSerializer
  attributes :leader_name

  has_many :members
  has_one :parent
  has_one :leader
end
