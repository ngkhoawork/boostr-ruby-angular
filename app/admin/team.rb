ActiveAdmin.register Team do
  permit_params :name, :parent_id

  index do
    selectable_column
    id_column
    column :name
    column :parent
    actions
  end
end
