class DomainConstraint
  def self.matches?(request)
    Seller.exists?(custom_domain: request.host, domain_verified: true)
  end
end

Rails.application.routes.draw do
  # Devise routes for authentication
  devise_for :users
  # Custom domain handling
  constraints(DomainConstraint) do
    get "/", to: "stores#show"
    get "/products", to: "stores#products"
    get "/about", to: "stores#about"
    get "/contact", to: "stores#contact"
  end

  # Stores index route
  get "stores", to: "stores#index", as: :stores

  # Store display routes
  scope "stores/:slug", as: "store" do
    get "/", to: "stores#show"
    get "/products", to: "stores#products"
    get "/about", to: "stores#about"
    get "/contact", to: "stores#contact"
    post "/contact", to: "stores#send_contact"
    get "/categories", to: "stores#categories"
    get "/categories/:id", to: "stores#category", as: :category_products
  end

  # Seller store management
  namespace :sellers do
    resource :store, only: [ :edit, :update ] do
      collection do
        get :theme, :analytics
        patch :update_theme
        resources :categories, controller: "store_categories"
      end
    end
  end

  # Shopping Cart System
  resources :carts do
    collection { get :current }
    member { delete :empty }
  end
  resources :cart_items
  get "cart", to: "carts#current", as: :current_cart

  # Checkout Process
  get "checkout", to: "checkout#index", as: :checkout
  post "checkout", to: "checkout#create", as: :checkout_create
  get "buy_now/:product_id", to: "checkout#buy_now", as: :buy_now_get
  post "buy_now/:product_id", to: "checkout#buy_now", as: :buy_now

  # Orders & Downloads
  resources :orders
  resources :order_items
  resources :download_links
  get "download/:token", to: "download_links#download", as: :download_file

  # Product Catalog
  # Category aliases for cleaner URLs (must be before resources :categories)
  get "categories/courses", to: redirect("/categories/courses-education")
  get "categories/software", to: redirect("/categories/software-applications")
  get "categories/digital", to: redirect("/categories/digital-content")
  get "categories/tools", to: redirect("/categories/tools-services")
  get "categories/physical", to: redirect("/categories/physical-products")
  
  resources :categories
  resources :products do
    member do
      post "add_item_to_cart", as: :add_item_to
      post "add_to_cart", to: "cart_items#create"  # Route for add_to_cart_path(product)
    end
    collection { get :new_arrivals }
    resources :reviews, only: [ :index, :new, :create ]
    resources :product_questions, only: [ :index, :new, :create ]
  end
  resources :reviews
  resources :product_questions
  resources :product_images

  # Product Discovery
  get "search", to: "products#search", as: :search
  get "deals", to: "deals#index", as: :deals
  get "deals/flash-sales", to: "deals#flash_sales", as: :flash_sales
  get "deals/clearance", to: "deals#clearance", as: :clearance
  get "deals/bundles", to: "deals#bundles", as: :bundles
  get "deals/weekly-offers", to: "deals#weekly_offers", as: :weekly_offers
  get "new-arrivals", to: "products#new_arrivals", as: :new_arrivals
  get "best-sellers", to: "products#best_sellers", as: :best_sellers

  # Seller Area
  resources :sellers, except: [ :destroy ] do
    collection do
      get :dashboard, :store_settings
      patch :update_store_settings
      post :verify_domain
    end
  end

  # Seller Dashboard (singular namespace for /seller/products, /seller/sales, etc.)
  namespace :seller do
    get "/", to: "dashboard#index", as: :root
    resources :products do
      collection do
        get :bulk_new
        post :bulk_create
        get :bulk_template
      end
    end
    get :sales, to: "dashboard#sales"
    get :earnings, to: "dashboard#earnings"
  end

  # User Account Area
  namespace :account do
    get "/", to: "dashboard#index", as: :root
    get :profile, to: "profile#show"
    patch :profile, to: "profile#update"
    get :orders, to: "orders#index"
    get "orders/:id", to: "orders#show", as: :order
    get :downloads, to: "downloads#index"
    get :wishlist, to: "wishlist#index"
    delete "wishlist/clear", to: "wishlist#clear", as: :clear_wishlist
    get "payment-methods", to: "payment_methods#index", as: :payment_methods
    post "payment-methods", to: "payment_methods#create"
    delete "payment-methods/:id", to: "payment_methods#destroy", as: :payment_method
    get :settings, to: "settings#index"
    patch :settings, to: "settings#update"
    resources :addresses
  end

  # User Collections
  resources :wishlist_items do
    collection { delete :clear }
  end
  get "wishlist", to: "wishlist_items#index", as: :wishlist

  # User Activity & Notifications
  resources :notifications, :user_activities, :action_items, :payment_audit_logs

  # Static Pages
  root "static#home"
  controller :static do
    get :contact, :about, :help_center, :privacy_policy, :term_of_service, :pricing
  end

  # Admin Area
  namespace :admin do
    root to: "dashboard#index"
    get :dashboard

    resources :users do
      member { post :toggle_admin, :impersonate }
      collection { get :stop_impersonating }
    end
    resources :sellers do
      member { post :verify, :suspend }
      collection { get :products, :orders, :analytics }
    end
    resources :products do
      member { post :toggle_featured, :toggle_status }
    end
    resources :categories do
      member { get :products }
      collection { post :reorder }
    end
    resources :orders do
      member { post :process_payment, :refund }
    end

    resources :action_items, :cart_items, :carts, :download_links, :notifications,
              :payment_audit_logs, :product_images, :product_questions, :reviews,
              :user_activities, :wishlist_items

    # Analytics
    get "analytics", to: "analytics#index"
    namespace :analytics do
      get :sales, :products, :customers, :export
    end

    # Settings
    get "settings", to: "settings#index"
    patch "settings", to: "settings#update"
    namespace :settings do
      get :security, :maintenance, :logs
      post :backup, :clear_cache, :restart_application
    end

    # System Monitoring
    get "system", to: "system#index"
    namespace :system do
      get :logs, :cache, :jobs
      post :cache
    end
  end

  # System & Health Checks
  get "up", to: "rails/health#show", as: :rails_health_check
end
