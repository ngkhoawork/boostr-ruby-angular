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

  show do
    attributes_table do
      row :name
      row :primary_contact
      row :billing_contact
    end

    panel "Licenses" do
      table_for company.contracts do
        column "name" do |contract|
          contract.license.name
        end

        column "start date" do |contract|
          contract.start_date
        end

        column "end date" do |contract|
          contract.end_date
        end
      end
    end
  end

  form do |f|
    f.inputs "Company Details" do
      f.input :name
      f.input :primary_contact, as: :select, collection: f.object.users.map { |u| [u.email, u.id] }
      f.input :billing_contact, as: :select, collection: f.object.users.map { |u| [u.email, u.id] }
    end

    f.inputs "Contracts" do
      f.has_many :contracts do |c|
        if !c.object.nil?
          c.input :_destroy, :as => :boolean, :label => "Destroy?"
        end

        c.input :license
        c.input :start_date
        c.input :end_date
      end
    end

    f.actions
  end

end
