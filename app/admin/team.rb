ActiveAdmin.register Team do
  permit_params :name, :parent_id

  index do
    selectable_column
    id_column
    column :name
    column :parent
    column 'Members', sortable: :members_count do |team|
      team.members_count
    end
    actions
  end
  filter :name
  filter :company
end
