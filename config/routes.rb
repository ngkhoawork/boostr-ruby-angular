require 'sidekiq/web'

Rails.application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  ActiveAdmin.routes(self)

  # Devise Auth
  devise_for :users, skip: 'invitation'
  devise_scope :user do
    get '/users/invitation/accept', to: 'api/invitations#edit',   as: 'accept_user_invitation'
    post '/api/users/invitation', to: 'api/invitations#create', as: nil
    put '/api/users/invitation/accept', to: 'api/invitations#update', as: 'user_invitation'
  end

  root 'pages#index'
  get 'styleguide' => 'pages#styleguide', as: :styleguide

  get 'switch_user', to: 'switch_user#set_current_user'
  get 'switch_user/remember_user', to: 'switch_user#remember_user'

  get 'extension_localstorage', to: 'extension_localstorage#index'

  namespace :api, defaults: { format: :json } do
    scope module: :v1, constraints: ApiConstraints.new(version: 1) do
      post 'forgot_password' => 'forgot_password#create'
      post 'resend_confirmation' => 'forgot_password#create'

      resources :user_token, only: [:create]

      resource :dashboard, only: [:show]
      resources :states, only: [:index]
      resources :forgot_password, only: [:create]
      resources :activity_types, only: [:index]
      resources :holding_companies, only: [:index]
      resources :ealerts, only: [:index, :show, :create, :update, :destroy] do
        post :send_ealert
      end
      resources :influencers, only: [:index, :show, :create, :update, :destroy]
      resources :activities, only: [:index, :create, :show, :update, :destroy]
      resources :contacts, only: [:index, :create, :update, :destroy]
      resources :deals, only: [:index, :create, :update, :show, :destroy] do
        resources :deal_products, only: [:create, :update, :destroy]
        resources :deal_assets, only: [:index, :update, :create, :destroy]
        resources :deal_contacts, only: [:index, :create, :update, :destroy]
      end
      resources :stages, only: [:index, :create, :show, :update]
      resources :clients, only: [:index, :show, :create, :update, :destroy] do
        get :sellers
        get :connected_contacts
        get :connected_client_contacts
        get :child_clients
        get :stats
        collection do
          get :filter_options
        end
        resources :client_members, only: [:index, :create, :update, :destroy]
        resources :client_contacts, only: [:index, :create, :update, :destroy] do
          collection do
            get :related_clients
          end
        end
      end

      resources :client_connections, only: [:index, :create, :update, :destroy]

      resources :reminders, only: [:index, :show, :create, :update, :destroy]
      resources :remindable, only: [] do
        get '/:remindable_type', to: 'reminders#remindable'
      end
      resources :forecasts, only: [:index, :show]
      resources :time_periods, only: [:index]
      resources :countries, only: [:index]
      resources :fields, only: [:index]
      resources :users, only: [:index, :update]
    end # API V1 END

    scope module: :v2, constraints: ApiConstraints.new(version: 2) do
      post 'forgot_password' => 'forgot_password#create'
      post 'resend_confirmation' => 'forgot_password#create'

      resources :user_token, only: [:create] do
        post :extension, on: :collection
      end
      resources :token_check, only: [:index]

      resource :dashboard, only: [:show]
      resources :states, only: [:index]
      resources :forgot_password, only: [:create]
      resources :activity_types, only: [:index]
      resources :activities, only: [:index, :create, :show, :update, :destroy]
      resources :contacts, only: [:index, :create, :update, :destroy]
      resources :deals, only: [:index, :create, :update, :show, :destroy] do
        get :pipeline_by_stages, on: :collection
        get :won_deals, on: :collection
        get :find_by_id, on: :member
        resources :deal_products, only: [:create, :update, :destroy]
        resources :deal_assets, only: [:index, :update, :create, :destroy]
        resources :deal_contacts, only: [:index, :create, :update, :destroy]
        resources :deal_members, only: [:index, :create, :update, :destroy]
      end
      resources :stages, only: [:index, :create, :show, :update]
      resources :clients, only: [:index, :show, :create, :update, :destroy] do
        get :sellers
        resources :client_members, only: [:index, :create, :update, :destroy]
        collection do
          get :search_clients
        end
        resources :client_contacts, only: [:index] do
          collection do
            get :related_clients
          end
        end
      end

      resources :reminders, only: [:index, :show, :create, :update, :destroy]
      resources :remindable, only: [] do
        get '/:remindable_type', to: 'reminders#remindable'
      end
      resources :forecasts, only: [:index, :show]
      resources :time_periods, only: [:index]
      resources :countries, only: [:index]
      resources :fields, only: [:index]
      resources :users, only: [:index, :update] do
        collection do
          get :signed_in_user
        end
      end

      resources :currencies, only: [:index] do
        collection do
          get :active_currencies
          get :exchange_rates_by_currencies
        end
      end

      resources :deal_custom_field_names, only: [:index]
      resources :products, only: [:index]

      resources :email_threads do
        get :all_opens

        collection do
          post :create_thread
          get :all_emails
          get :search_by
          get :all_not_opened_emails
          post :all_threads
        end
      end

      resources :gmail_extension, only: [:index]
      resources :calendar_extension, only: [:index]

      resources :validations, only: [] do
        collection do
          get :account_base_fields
          get :deal_base_fields
        end
      end

      resources :account_cf_names, only: [:index]
      resources :holding_companies, only: [:index]
      resources :contact_cf_names, only: [:index]
      resources :display_line_items, only: [:create]
      resources :display_line_item_budgets, only: [:create]
      resources :custom_field_names, only: [:index, :create, :show, :update, :destroy]
      resources :sales_processes, only: [:index, :create, :show, :update]
    end # API V2 END

    post '/slack/auth', to: 'slack_connect#auth'
    get '/slack/callback', to: 'slack_connect#callback'

    resources :data_models, only: [:index] do
      get :data_mappings, on: :collection
      get :reflections, on: :collection
      get :reflections_labels, on: :collection
    end

    namespace :dataexport, defaults: { format: :json }, constraints: ApiConstraints.new(dataexport: true) do
      resources :user_token, only: [:create]

      resources :users, only: [:index]
      resources :products, only: [:index]
      resources :ios, only: [:index]
      resources :accounts, only: [:index]
      resources :deals, only: [:index]
      resources :display_line_items, only: [:index]
      resources :stages, only: [:index]
      resources :deal_members, only: [:index]
      resources :deal_products, only: [:index]
      resources :deal_product_budgets, only: [:index]
      resources :io_members, only: [:index]
      resources :display_line_item_budgets, only: [:index]
    end

    resources :spend_agreements do
      resources :spend_agreement_deals, only: [:index, :create, :destroy] do
        collection do
          get :available_to_match
        end
      end
      resources :spend_agreement_ios, only: [:index]
      resources :spend_agreement_publishers, only: [:index, :create, :destroy]
      resources :spend_agreement_team_members, only: [:index, :create, :update, :destroy]
    end

    resources :dfp_imports do
      collection do
        post 'import'
      end
    end

    resources :datafeed, only: [] do
      collection do
        post 'import'
      end
    end

    resources :asana_connect, only: [:index] do
      collection do
        get :callback
      end
    end
    resources :agency_dashboards do
      collection do
        get :spend_by_product
        get :spend_by_advertisers
        get :related_advertisers_without_spend
        get :spend_by_category
        get :win_rate_by_category
        get :contacts_and_related_advertisers
        get :activity_history
      end
    end

    resources :time_dimensions, only: [:index] do
      collection do
        get :revenue_fact_dimension_months
      end
    end

    resources :countries, only: [:index]
    resources :api_configurations do
      collection do
        get :metadata
        get :service_account_email
        get :ssp_credentials
        get :workflowable_actions
        get :ssp_providers
      end
      member do
        post :delete_ssp
        post :update_ssp
        post :sync_hoopla_users
      end
    end
    resources :integration_types, only: [:index]
    resources :integration_logs, only: [:index, :show] do
      post :resend_request, on: :member
    end

    resources :integrations, only: [:create]
    resources :csv_import_logs, only: [:index, :show] do
      collection  do
        get :api_logs
      end
    end

    resources :users, only: [:index, :update] do
      collection do
        post 'import'
        post 'starting_page'
        get :signed_in_user
      end
    end
    resources :clients, only: [:index, :show, :create, :update, :destroy] do
      get :sellers
      get :connected_contacts
      get :connected_client_contacts
      get :stats
      collection do
        get :child_clients
        get :parent_clients
        get :search_clients
        get :filter_options
        get :category_options
        get :fuzzy_search
        post :csv_import
      end
      resources :client_members, only: [:index, :create, :update, :destroy]
      resources :client_contacts, only: [:index, :create, :update, :destroy] do
        collection do
          get :related_clients
        end
      end
    end
    resources :client_connections, only: [:index, :create, :update, :destroy]
    resources :deal_custom_field_names, only: [:index, :show, :create, :update, :destroy] do
      collection do
        get :csv_headers
      end
    end

    resources :deal_product_cf_names, only: [:index, :show, :create, :update, :destroy] do
      collection do
        get :csv_headers
      end
    end

    resources :account_cf_names, only: [:index, :show, :create, :update, :destroy] do
      collection do
        get :csv_headers
      end
    end
    resources :contact_cf_names, only: [:index, :show, :create, :update, :destroy]
    resources :deal_reports, only: [:index]

    resources :bps, only: [:index, :create, :update, :show, :destroy] do
      get :seller_total_estimates
      get :account_total_estimates
      get :unassigned_clients
      post :add_client
      post :assign_client
      post :add_all_clients
      post :assign_all_clients
      resources :bp_estimates, only: [:index, :create, :update, :show, :destroy] do
        get :status, on: :collection
      end
    end
    resources :temp_ios, only: [:index, :update]
    resources :display_line_items, only: [:index, :create, :show] do
      post :add_budget, on: :member
    end
    resources :display_line_item_budgets, only: [:index, :create, :update, :destroy]
    resources :contacts, only: [:index, :show, :create, :update, :destroy] do
      member do
        post :assign_account
        delete :unassign_account
        get :related_clients
        get :advertisers
      end
      collection do
        get :metadata
      end
    end
    resources :revenue, only: [:create] do
      collection do
        get :forecast_detail
        get :report_by_category, defaults: { format: :json }
        get :report_by_account, defaults: { format: :json }
      end
    end
    resources :ios, only: [:index, :show, :create, :update, :destroy] do
      put :update_influencer_budget
      post :import_content_fee, on: :collection
      post :import_costs, on: :collection
      get :export_costs, on: :collection
      get :spend_agreements
      resources :costs, only: [:create, :update, :destroy]
      resources :content_fees, only: [:create, :update, :destroy]
      resources :io_members, only: [:index, :create, :update, :destroy]
    end
    resources :pmps, only: [:index, :show, :create, :update, :destroy] do
      resources :pmp_members, only: [:create, :update, :destroy]
      resources :pmp_items, only: [:create, :update, :show, :destroy]
      get :no_match_advertisers, on: :collection
      post :bulk_assign_advertiser, on: :collection
      post :assign_advertiser, on: :member
    end
    resources :pmp_item_daily_actuals, only: [:index, :update, :destroy] do
      post :import, on: :collection
      post :assign_advertiser, on: :member
      post :bulk_assign_advertiser, on: :collection
      get :aggregate, on: :collection
    end
    resources :ssps, only: [:index]
    resources :deals, only: [:index, :create, :update, :show, :destroy] do
      resources :deal_products, only: [:create, :update, :destroy]
      collection do
        get :pipeline_deals
        get :pipeline_report
        get :pipeline_report_totals
        get :pipeline_report_monthly_budgets
        get :pipeline_summary_report
        get :won_deals
        get :filter_data
        get :all
        get :all_deals_header
      end
      member do
        post :send_to_operative
        post :send_to_google_sheet
        get :possible_agreements
      end
      resources :deal_members, only: [:index, :create, :update, :destroy]
      resources :deal_contacts, only: [:index, :create, :update, :destroy]
      resources :attachments, only: [:index, :update, :create, :destroy]
      get :spend_agreements
      put :assign_agreements
      get 'latest_log', to: 'integration_logs#latest_log'
    end
    resources :assets, only: [:create] do
      collection do
        get :metadata
      end
    end
    resources :deal_product_budgets, only: [:index, :create]
    resources :deal_products, only: [:index, :create]
    resources :stages, only: [:index, :create, :show, :update]
    resources :product_families, only: [:index, :create, :update, :destroy]
    resources :products, only: [:index, :create, :update] do
      resources :ad_units, only: [:index, :create, :update, :destroy]
    end
    resources :teams, only: [:index, :create, :show, :update, :destroy] do
      collection do
        get :all_members
        get :all_account_managers
      end
      get :members
      get :all_sales_reps
    end
    resources :custom_values, only: [:index]
    resources :currencies, only: [:index] do
      collection do
        get :active_currencies
        get :exchange_rates_by_currencies
      end
    end
    resources :exchange_rates, only: [:create, :update, :destroy] do
      collection do
        get :active_exchange_rates
      end
    end
    resources :time_periods, only: [:index, :create, :update, :destroy] do
      collection do
        get :current_year_quarters
      end
    end
    resources :quotas, only: [:index, :create, :update, :destroy] do
      post :import, on: :collection
    end
    resources :forecasts, only: [:index, :show] do
      collection do
        get :revenue_data
        get :pmp_data
        get :pmp_product_data
        get :pipeline_data
        get :old_detail
        get :detail
        get :old_product_detail
        get :product_detail
        post :run_forecast_calculation
      end
    end
    resources :fields, only: [:index] do
      collection do
        get :client_base_options
      end
    end
    resources :options, only: [:create, :update, :destroy]
    resources :validations, only: [:index, :update, :create, :destroy] do
      collection do
        get :account_base_fields
        get :deal_base_fields
        get :billing_contact_fields
      end
    end
    resources :tools, only: [:index]
    resources :notifications, only: [:index, :show, :create, :update, :destroy]
    resources :activities, only: [:index, :create, :show, :update, :destroy]
    resources :activity_types, only: [:index, :create, :update, :destroy] do
      put :update_positions, on: :collection
    end
    resources :holding_companies, only: [:index] do
      resources :account_dimensions, only: [:index]
    end
    resources :account_dimensions, only: [:index]
    resources :ealerts, only: [:index, :show, :create, :update, :destroy] do
      post :send_ealert
    end
    resources :reports, only: [:index] do
      collection do
        get :split_adjusted
        get :pipeline_summary
        get :product_monthly_summary
        get :quota_attainment
      end
    end
    resources :influencers, only: [:index, :show, :create, :update, :destroy]
    resources :influencer_content_fees, only: [:index, :show, :create, :update, :destroy] do
      post :update_budget
      post :import, on: :collection
    end
    resources :sales_execution_dashboard, only: [:index] do
      collection do
        get :forecast
        get :monthly_forecast
        get :kpis
        get :deal_loss_summary
        get :deal_loss_stages
        get :activity_summary
      end
    end
    resources :kpis, only: [:index]
    resources :kpis_dashboard, only: [:index]
    resources :where_to_pitch, only: [:index]
    resources :inactives, only: [] do
      collection do
        get :inactives
        get :seasonal_inactives
        get :soon_to_be_inactive
      end
    end
    resources :reminders, only: [:index, :show, :create, :update, :destroy]
    resources :remindable, only: [] do
      get '/:remindable_type', to: 'reminders#remindable'
    end

    resource :weighted_pipelines, only: [:show]

    resource :dashboard, only: [:show] do
      collection do
        get :pacing_alerts
      end
    end

    resource :company, only: [:show, :update]
    resources :initiatives, only: [:index, :create, :update, :destroy] do
      get 'smart_report', on: :collection
      get 'smart_report_deals', on: :member
    end
    resources :billing_summary, only: [:index] do
      member do
        put :update_cost
        put :update_cost_budget
        put :update_quantity
        put :update_content_fee_product_budget
        put :update_display_line_item_budget_billing_status
      end

      get 'costs', on: :collection

      get :export, on: :collection
      get :export_cost_budgets, on: :collection
    end
    resources :requests, only: [:index, :show, :create, :update, :destroy]

    get 'teams/by_user/:id', to: 'teams#by_user', as: :team_by_user

    resources :pacing_dashboard, only: [] do
      collection do
				get :pipeline_and_revenue
				get :activity_pacing
			end
    end

    resources :mailtrack, only: [] do
      get '/:pixel', to: 'mailtrack#open_mail', on: :collection
    end

    resources :filter_queries, only: [:index, :create, :update, :destroy]
    resources :publishers, only: [:index, :create, :update, :destroy] do
      collection do
        get :pipeline
        get :all_fields_report
        get :settings
        get :pipeline_headers
      end
      resources :attachments, only: [:index, :update, :create, :destroy]
    end
    resources :publisher_details, only: [:show] do
      member do
        get :associations
        get :activities
        get :fill_rate_by_month_graph
        get :daily_revenue_graph
      end
    end
    resources :publisher_custom_field_names, only: [:index, :create, :update, :destroy]
    resources :publisher_daily_actuals, only: [] do
      post :import, on: :collection
    end

    resources :active_pmps, only: [] do
      collection do
        post :import_item
        post :import_object
      end
    end

    resources :sales_stages, only: [:index, :create, :update] do
      put :update_positions, on: :collection
    end

    resources :publisher_members, only: [:create, :update, :destroy]
    resources :publisher_contacts, only: [:create, :update, :destroy]

    resources :custom_field_names, only: [:index, :create, :show, :update, :destroy]

    resource :egnyte_integration, only: [:show, :create, :update] do
      collection do
        get :oauth_settings
        get :company_oauth_callback
        get :user_oauth_callback
        get :navigate_to_deal
        get :navigate_to_account_deals
        put :disconnect_user
      end
    end

    resources :leads, only: [:index, :show, :update] do
      member do
        get :accept
        get :reject
        get :reassign
        get :map_with_client
        get :reject_from_email
        get :clients
      end

      collection do
        get :users
        post :import
        post :create_lead
      end
    end

    resources :assignment_rules, only: [:index, :create, :update, :destroy], controller: 'settings/assignment_rules' do
      member do
        get :add_user
        get :remove_user
      end

      collection do
        put :update_positions
        get :field_types
      end
    end

    resources :workflows, only: [:index, :create, :update, :destroy] do
      resources :workflow_criterions, only: [:destroy]
    end

    resources :sales_processes, only: [:index, :create, :show, :update]
    resources :statistics, only: [:show]

    resources :logi_configurations, only: [:index, :logi_callback] do
      get :logi_callback, on: :collection
    end

    resources :contracts, except: [:new, :edit] do
      resources :attachments, only: [:index, :update, :create, :destroy]
      get :settings, on: :collection
      post :import_special_terms, on: :collection
    end

    resources :ealert_templates, only: [:show, :update], param: :type do
      member do
        post :send_ealert
      end
    end

    get 'search', to: 'search#all'
    get 'search/count', to: 'search#count'
  end

  mount Sidekiq::Web => '/sidekiq'

  mount_griddler
  # TEMP
  get '/snapshot' => 'pages#snapshot'

  get '*path' => 'pages#index'
end
