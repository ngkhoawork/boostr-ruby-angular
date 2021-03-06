class Teams::IndexSerializer < Teams::BaseSerializer
  attributes :leader_name

  has_many :members
  has_many :children, serializer: Teams::ChildSerializer
  has_one :parent
  has_one :leader
end
