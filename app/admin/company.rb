ActiveAdmin.register Company do
  permit_params :name, :primary_contact_id, :billing_contact_id

  index do
    selectable_column
    id_column
    column :name
    column :primary_contact
    column :billing_contact
    actions
  end

  form do |f|
    f.inputs "Company Details" do
      f.input :name
      f.input :primary_contact, as: :select, collection: f.object.users.map { |u| [u.email, u.id] }
      f.input :billing_contact, as: :select, collection: f.object.users.map { |u| [u.email, u.id] }
    end
    f.actions
  end

end
