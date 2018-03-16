ActiveAdmin.register User do
  permit_params :email, :password, :first_name, :last_name, :title, :company_id, :is_legal, roles: []

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
    actions do |action|
      link_to "Login As", "/switch_user?scope_identifier=user_#{action.id}", :target => '_blank'
    end
  end

  show do |user|
    attributes_table do
      #We want to keep the existing columns
      User.column_names.each do |column|
        row column
      end
      #This is where we add a new column
      row :login_as do
        link_to "#{user.name}", "/switch_user?remember=true&scope_identifier=user_#{user.id}", :target => '_blank'
      end
    end
  end

  filter :email
  filter :is_legal
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs 'User Details' do
      f.input :email
      f.input :password
      f.input :first_name
      f.input :last_name
      f.input :title
      f.input :is_legal
      f.input :company
      if current_user.is?(:superadmin)
        f.input :roles, as: :check_boxes, collection: User::ROLES
      end
    end
    f.actions
  end

  controller do
    def update
      if params[:user][:password].blank?
        params[:user].delete("password")
      end
      super
    end
  end
end
