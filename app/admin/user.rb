ActiveAdmin.register User do
  permit_params :email, :first_name, :last_name, :company_id, roles: []

  index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    column :company
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :company
      f.input :roles, as: :check_boxes, collection: User::ROLES
    end
    f.actions
  end
end
