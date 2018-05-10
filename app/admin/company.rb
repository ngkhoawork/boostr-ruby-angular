ActiveAdmin.register Company do
  permit_params :name, :ealert_reminder, :influencer_enabled, :primary_contact_id, :billing_contact_id, :quantity,
  :cost, :start_date, :end_date, :requests_enabled, :publishers_enabled, :gmail_enabled, :gcalendar_enabled,
  :logi_enabled, :resource_link, :agreements_enabled, :leads_enabled, :contracts_enabled,
  billing_address_attributes: [ :street1, :street2, :city, :state, :zip, :website, :phone ],
  physical_address_attributes: [ :street1, :street2, :city, :state, :zip ],
  egnyte_integration_attributes: [ :id, :app_domain, :deals_folder_name, :connect_email, :enabled ]

  index do
    selectable_column
    id_column
    column :name
    column :primary_contact
    column :billing_contact
    column :ealert_reminder
    column :requests_enabled
    column :influencer_enabled
    column :publishers_enabled
    column :gmail_enabled
    column :gcalendar_enabled
    column :egnyte_integration_enabled
    column :egnyte_integration_app_domain
    column :logi_enabled
    column :resource_link
    column :agreements_enabled
    column :contracts_enabled
    column :leads_enabled
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
      row :publishers_enabled
      row :gmail_enabled
      row :gcalendar_enabled
      row :logi_enabled
      row :resource_link
      row :agreements_enabled
      row :contracts_enabled
      row :leads_enabled
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

    panel "Egnyte Integration" do
      attributes_table_for company do
        row('Enabled') { |company| company.egnyte_integration&.enabled }
        row('App Domain') { |company| company.egnyte_integration&.app_domain }
        row('Deals Folder Name') { |company| company.egnyte_integration&.deals_folder_name }
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
      f.input :publishers_enabled
      f.input :gmail_enabled
      f.input :gcalendar_enabled
      f.input :logi_enabled
      f.input :resource_link
      f.input :agreements_enabled
      f.input :contracts_enabled
      f.input :leads_enabled
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

    panel "Egnyte Integration" do
      f.inputs for: [:egnyte_integration, f.object.egnyte_integration || EgnyteIntegration.new] do |ei|
        ei.input :app_domain
        ei.input :deals_folder_name, hint: 'deals will be kept in'

        if ei.object.connected?
          ei.input :enabled
        else
          ei.input :connect_email, hint: 'email with auth link will be sent to'
          ei.input :enabled, input_html: { disabled: true }, hint: 'will be clickable after auth get completed'
        end
      end
    end

    f.actions
  end

  controller do
    after_filter :send_connect_egnyte_email, only: :update

    private

    def send_connect_egnyte_email
      if egnyte_integration.non_connected? && egnyte_connect_email.present? && egnyte_integration.app_domain.present?
        EgnyteMailer.company_connection(egnyte_connect_email, build_egnyte_auth_link).deliver_now
      end
    end

    def egnyte_connect_email
      params[:company]&.[](:egnyte_integration_attributes)&.[](:connect_email)
    end

    def build_egnyte_auth_link
      Egnyte::Actions::BuildAuthorizationUri.new(
        domain: egnyte_integration.app_domain,
        redirect_uri: company_oauth_callback_api_egnyte_integration_url(protocol: 'https', host: host),
        auth_record: egnyte_integration
      ).perform
    end

    def egnyte_integration
      resource.egnyte_integration
    end

    def host
      ENV['HOST'] || request.domain
    end
  end
end
