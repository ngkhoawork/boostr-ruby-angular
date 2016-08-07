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

  get '/api/sales_execution_dashboard/forecast', to: 'api/sales_execution_dashboard#forecast',   as: 'sales_execution_dashboard_forecast'
  get '/api/sales_execution_dashboard/deal_loss_summary', to: 'api/sales_execution_dashboard#deal_loss_summary',   as: 'sales_execution_dashboard_deal_loss_summary'
  namespace :api do
    resources :users, only: [:index, :update]
    resources :clients, only: [:index, :show, :create, :update, :destroy] do
      resources :client_members, only: [:index, :create, :update, :destroy]
    end
    resources :contacts, only: [:index, :create, :update, :destroy]
    resources :revenue, only: [:index, :create]
    resources :deals, only: [:index, :create, :update, :show, :destroy] do
      resources :deal_members, only: [:index, :create, :update, :destroy]
    end
    resources :stages, only: [:index, :create, :show, :update]
    resources :products, only: [:index, :create, :update]
    resources :deal_products, only: [:create, :update, :destroy]
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
    resources :sales_execution_dashboard, only: [:index]
    resources :kpis, only: [:index]

    resource :weighted_pipelines, only: [:show]
    resource :dashboard, only: [:show]
    resource :company, only: [:show, :update]
  end

  mount Sidekiq::Web => '/sidekiq'

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
