require 'sidekiq/web'

Rails.application.routes.draw do

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  ActiveAdmin.routes(self)

  devise_for :users, skip: 'invitation'
  devise_scope :user do
    get '/users/invitation/accept', to: 'api/invitations#edit',   as: 'accept_user_invitation'
    post '/api/users/invitation', to: 'api/invitations#create', as: nil
    put '/api/users/invitation/accept', to: 'api/invitations#update', as: 'user_invitation'
  end

  root 'pages#index'
  get 'styleguide' => 'pages#styleguide', as: :styleguide

  namespace :api do
    resources :users, only: [:index, :update] do
      collection do
        get :signed_in_user
      end
    end
    resources :clients, only: [:index, :show, :create, :update, :destroy] do
      resources :client_members, only: [:index, :create, :update, :destroy]
      resources :client_contacts, only: [:index] do
        collection do
          get :related_clients
        end
      end
    end
    resources :contacts, only: [:index, :create, :update, :destroy]
    resources :revenue, only: [:index, :create]
    resources :deals, only: [:index, :create, :update, :show, :destroy] do
      collection do
        get :pipeline_report
        get :pipeline_summary_report
      end
      resources :deal_members, only: [:index, :create, :update, :destroy]
      resources :deal_contacts, only: [:index, :create, :destroy]
    end
    resources :stages, only: [:index, :create, :show, :update]
    resources :products, only: [:index, :create, :update]
    resources :deal_products, only: [:create, :update, :destroy] do
      collection do
        put :update_total_budget
      end
    end
    resources :teams, only: [:index, :create, :show, :update, :destroy] do
      get :all_members
    end
    resources :custom_values, only: [:index]
    resources :time_periods, only: [:index, :create, :update, :destroy]
    resources :quotas, only: [:index, :create, :update]
    resources :forecasts, only: [:index, :show]
    resources :fields, only: [:index]
    resources :options, only: [:create, :update, :destroy]
    resources :tools, only: [:index]
    resources :notifications, only: [:index, :show, :create, :update, :destroy]
    resources :activities, only: [:index, :create, :show, :update, :destroy]
    resources :activity_types, only: [:index, :create, :show, :update, :destroy]
    resources :reports, only: [:index, :show]
    resources :sales_execution_dashboard, only: [:index] do
      collection do
        get :forecast
        get :kpis
        get :deal_loss_summary
        get :deal_loss_stages
        get :activity_summary
      end
    end
    resources :kpis, only: [:index]
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
