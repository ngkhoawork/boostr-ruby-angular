class Teams::HierarchySerializer < Teams::BaseSerializer
  has_many :children, serializer: Teams::HierarchySerializer
  has_many :all_members, serializer: Users::BaseSerializer, key: :members
  has_many :all_leaders, serializer: Users::BaseSerializer, key: :leaders
end
