Rails.application.routes.draw do
  resources :action_items
  resources :user_activities
  resources :wishlist_items
  resources :notifications
  resources :product_questions
  resources :payment_audit_logs
  resources :download_links
  resources :reviews
  resources :cart_items
  resources :carts

  # Add this line to create a route for the user dashboard
  get "dashboard", to: "users#dashboard", as: :dashboard

  # Add this line to create a route for the user profile
  get "profile", to: "users#profile", as: :profile

  # Add this line to create a route for the current user's cart
  get "cart", to: "carts#current", as: :current_cart

  resources :orders
  resources :product_images
  resources :products
  resources :categories

  # Seller routes
  resources :sellers, only: [ :show, :new, :create, :edit, :update ]
  get "seller/dashboard", to: "sellers#dashboard", as: "seller_dashboard"
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  root "static#home"

  get "search", to: "products#search", as: :search


  controller :static do
    get "contact"
    get "about"
    get "help_center"
    get "privacy_policy"
    get "term_of_service"
    get "pricing"
  end

  # Admin routes
  namespace :admin do
    root to: "dashboard#index"

    # Dashboard
    get "dashboard", to: "dashboard#index"

    # Users management
    resources :users do
      member do
        post "toggle_admin"
        post "impersonate"
      end
      collection do
        get "stop_impersonating"
      end
    end

    # Products management
    resources :products do
      member do
        post "toggle_featured"
        post "toggle_status"
      end
    end

    # Orders management
    resources :orders do
      member do
        post "process_payment"
        post "refund"
        get "download_invoice"
      end
    end

    # Sellers management
    resources :sellers do
      member do
        post "verify"
        post "suspend"
        get "products"
        get "orders"
        get "analytics"
      end
    end

    # Categories management
    resources :categories do
      member do
        get "products"
      end
      collection do
        post "reorder"
      end
    end

    # Settings (super admin only)
    get "settings", to: "settings#index"
    patch "settings", to: "settings#update"
    get "settings/security", to: "settings#security"
    get "settings/maintenance", to: "settings#maintenance"
    post "settings/backup", to: "settings#backup"
    get "settings/logs", to: "settings#logs"
    post "settings/clear_cache", to: "settings#clear_cache"
    post "settings/restart_application", to: "settings#restart_application"

    # Analytics
    get "analytics", to: "analytics#index"
    get "analytics/sales", to: "analytics#sales"
    get "analytics/products", to: "analytics#products"
    get "analytics/customers", to: "analytics#customers"
    get "analytics/export", to: "analytics#export"
  end

  # Add this line to define the deals route
  # Add this line to your existing routes.rb file
  get "deals", to: "deals#index", as: :deals

  # Your existing new_arrivals route
  get "new_arrivals", to: "products#new_arrivals", as: :new_arrivals

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  # Add this inside your existing routes.rb file
  resources :wishlist_items do
    collection do
      delete :clear, as: :clear
    end
  end
end
