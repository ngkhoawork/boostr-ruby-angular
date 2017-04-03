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

  namespace :api do
    scope module: :v1, constraints: ApiConstraints.new(version: 1) do
      post 'forgot_password' => 'forgot_password#create'
      post 'resend_confirmation' => 'forgot_password#create'

      resources :user_token, only: [:create]

      resource :dashboard, only: [:show]
      resources :states, only: [:index]
      resources :forgot_password, only: [:create]
      resources :activity_types, only: [:index]
      resources :activities, only: [:index, :create, :show, :update, :destroy]
      resources :contacts, only: [:index, :create, :update, :destroy]
      resources :deals, only: [:index, :create, :update, :show, :destroy] do
        resources :deal_products, only: [:create, :update, :destroy]
        resources :deal_assets, only: [:index, :update, :create, :destroy]
      end
      resources :stages, only: [:index, :create, :show, :update]
      resources :clients, only: [:index, :show, :create, :update, :destroy] do
        get :sellers
        resources :client_members, only: [:index, :create, :update, :destroy]
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
      resources :users, only: [:index, :update]
    end

    resources :countries, only: [:index]
    resources :api_configurations
    resources :integration_types, only: [:index]
    resources :integration_logs, only: [:index, :show] do
      post :resend_request, on: :member
    end
    resources :csv_import_logs, only: [:index]

    resources :users, only: [:index, :update] do
      collection do
        post 'starting_page'
        get :signed_in_user
      end
    end
    resources :clients, only: [:index, :show, :create, :update, :destroy] do
      get :sellers
      resources :client_members, only: [:index, :create, :update, :destroy]
      resources :client_contacts, only: [:index] do
        collection do
          get :related_clients
        end
      end
    end
    resources :deal_custom_field_names, only: [:index, :show, :create, :update, :destroy]
    resources :deal_reports, only: [:index]
    
    resources :bps, only: [:index, :create, :update, :show, :destroy] do
      get :seller_total_estimates
      get :account_total_estimates
      get :unassigned_clients
      post :add_client
      post :add_all_clients
      resources :bp_estimates, only: [:index, :create, :update, :show, :destroy]
    end
    resources :temp_ios, only: [:index, :update]
    resources :display_line_items, only: [:index, :create]
    resources :display_line_item_budgets, only: [:index, :create]
    resources :io_csvs, only: [:create]
    resources :display_line_item_csvs, only: [:create]
    resources :contacts, only: [:index, :create, :update, :destroy]
    resources :revenue, only: [:index, :create]
    resources :ios, only: [:index, :show, :create, :update, :destroy] do
      resources :content_fees, only: [:create, :update, :destroy]
      resources :io_members, only: [:index, :create, :update, :destroy]
    end
    resources :deals, only: [:index, :create, :update, :show, :destroy] do
      resources :deal_products, only: [:create, :update, :destroy]
      collection do
        get :pipeline_report
        get :pipeline_summary_report
      end
      resources :deal_members, only: [:index, :create, :update, :destroy]
      resources :deal_contacts, only: [:index, :create, :update, :destroy]
      resources :deal_assets, only: [:index, :update, :create, :destroy]
    end
    resources :deal_product_budgets, only: [:index, :create]
    resources :deal_products, only: [:create]
    resources :stages, only: [:index, :create, :show, :update]
    resources :products, only: [:index, :create, :update]
    resources :teams, only: [:index, :create, :show, :update, :destroy] do
      collection do
        get :all_members
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
    resources :time_periods, only: [:index, :create, :update, :destroy]
    resources :quotas, only: [:index, :create, :update]
    resources :forecasts, only: [:index, :show]
    resources :fields, only: [:index]
    resources :options, only: [:create, :update, :destroy]
    resources :validations, only: [:index, :update]
    resources :tools, only: [:index]
    resources :notifications, only: [:index, :show, :create, :update, :destroy]
    resources :activities, only: [:index, :create, :show, :update, :destroy]
    resources :activity_types, only: [:index, :create, :show, :update, :destroy]
    resources :reports, only: [:index, :show]
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
    resource :dashboard, only: [:show]
    resource :company, only: [:show, :update]
  end

  mount Sidekiq::Web => '/sidekiq'

  mount_griddler
  # TEMP
  get '/snapshot' => 'pages#snapshot'

  get '*path' => 'pages#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
