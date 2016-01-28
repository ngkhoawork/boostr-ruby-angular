ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :first_name, :last_name, :title, :company_id, roles: []

  index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    column :title
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
    f.inputs 'User Details' do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :first_name
      f.input :last_name
      f.input :title
      f.input :company
      f.input :roles, as: :check_boxes, collection: User::ROLES
    end
    f.actions
  end

  controller do
    def update
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end
      super
    end
  end

end

