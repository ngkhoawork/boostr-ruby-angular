ActiveAdmin.register Company do
  permit_params :name, :ealert_reminder, :primary_contact_id, :billing_contact_id, :quantity,
  :cost, :start_date, :end_date, :requests_enabled,
  billing_address_attributes: [ :street1, :street2, :city, :state, :zip, :website, :phone ],
  physical_address_attributes: [ :street1, :street2, :city, :state, :zip ]

  index do
    selectable_column
    id_column
    column :name
    column :primary_contact
    column :billing_contact
    column :ealert_reminder
    column :requests_enabled
    actions
  end

  show do
    attributes_table do
      row :name
      row :primary_contact
      row :billing_contact
      row :ealert_reminder
      row :requests_enabled
    end

    panel "Billing Address" do
      table_for company.billing_address do
        column "Street Address", :street1
        column "Apt, Suite, etc.", :street2
        column :city
        column :state
        column :zip
        column :website
        column :phone
      end
    end

    panel "Physical Address" do
      table_for company.physical_address do
        column "Street Address", :street1
        column "Apt, Suite, etc.", :street2
        column :city
        column :state
        column :zip
      end
    end

    panel "License" do
      attributes_table_for company do
        row :quantity
        row :cost
        row :start_date
        row :end_date
      end
    end
  end

  filter :name

  form do |f|
    f.inputs "Company Details" do
      f.input :name
      f.input :primary_contact, as: :select, collection: f.object.users.map { |u| [u.email, u.id] }
      f.input :billing_contact, as: :select, collection: f.object.users.map { |u| [u.email, u.id] }
      f.input :ealert_reminder
      f.input :requests_enabled
    end

    f.inputs "Billing Address", for: [:billing_address, f.object.billing_address || Address.new] do |ba|
      ba.input :street1
      ba.input :street2
      ba.input :city
      ba.input :state
      ba.input :zip
      ba.input :phone
      ba.input :website
    end

    f.inputs "Physical Address", for: [:physical_address, f.object.physical_address || Address.new] do |pa|
      # pa.input :copy_billing, as: :boolean, label: "Copy Billing Address?"
      pa.input :street1
      pa.input :street2
      pa.input :city
      pa.input :state
      pa.input :zip
    end

    f.inputs "License" do
      f.input :quantity
      f.input :cost
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
    end

    f.actions
  end

end
