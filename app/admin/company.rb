ActiveAdmin.register Company do
  permit_params :name, :ealert_reminder, :influencer_enabled, :primary_contact_id, :billing_contact_id, :quantity,
  :cost, :start_date, :end_date, :requests_enabled, :publishers_enabled, :gmail_enabled, :gcalendar_enabled,
  billing_address_attributes: [ :street1, :street2, :city, :state, :zip, :website, :phone ],
  physical_address_attributes: [ :street1, :street2, :city, :state, :zip ],
  egnyte_integration_attributes: [ :id, :app_domain, :enabled ]

  index do
    selectable_column
    id_column
    column :name
    column :primary_contact
    column :billing_contact
    column :ealert_reminder
    column :requests_enabled
    column :influencer_enabled
    column :egnyte_enabled
    column :publishers_enabled
    column :gmail_enabled
    column :gcalendar_enabled
    column :egnyte_app_domain
    actions
  end

  show do
    attributes_table do
      row :name
      row :primary_contact
      row :billing_contact
      row :ealert_reminder
      row :requests_enabled
      row :influencer_enabled
      row :egnyte_enabled
      row :publishers_enabled
      row :gmail_enabled
      row :gcalendar_enabled
      row :egnyte_app_domain
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
      f.input :influencer_enabled
      f.input :egnyte_enabled
      f.input :publishers_enabled
      f.input :gmail_enabled
      f.input :gcalendar_enabled
      f.input :egnyte_app_domain
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
