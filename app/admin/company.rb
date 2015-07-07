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

    f.inputs "Contracts" do
      f.has_many :contracts do |c|
        if !c.object.nil?
          c.input :_destroy, as: :boolean, label: "Destroy?"
        end

        c.input :license
        c.input :start_date, as: :datepicker
        c.input :end_date, as: :datepicker
      end
    end

    f.actions
  end

end
