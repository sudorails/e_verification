EVerification::Application.routes.draw do

  root :to => 'dashboards#index'

  get "help_topics/" => 'help_topics#index', :as => :help_topics

  get "help_topics/how-to-make-applicant" => 'help_topics#make_customer', :as => :make_customer
  get "help_topics/how-to-make-co-applicant" => 'help_topics#make_co_applicant', :as => :make_co_applicant
  get 'pending_customers' => "reports#pending", :as => :pending_customers
  get 'completed_customers' => "reports#completed", :as => :completed_customers
  get 'progress_customers' => "reports#progress", :as => :progress_customers

  resources :branches
  resources :reports do
   get :generated_report
   get :generate_report
  end
  resources :co_applicant_serveys
  get "customers/completed_customers_today"
  get "customers/in_progress_today"
  get "customers/old_pending_customers"
  get "customers/daily_customers"
  get "customers/assigned_data_today"
  get "customers/daily_pending_customers"
  get "customers/daily_completed_customers"
  get "customers/daily_progress_customers"
  get "reports/show"
  get "co_applicant_businesses/index"
  get "reports/to_excel" => "reports#to_excel", :as => :excel
  get "customers/search_results" => "customers#customer_search", :as => :search
  get "dashboards/index"
  get "headshot_demo/index"
  get "customers/cust_residential"
  get "customers/cust_business"
  get "customers/cust_pending"
  get "customers/cust_in_progress"
  get "customers/cust_completed"
  get "customers/customer_search_results" => "customers#search", :as => :customer_search
  post "headshot/capture" => 'headshot#capture', :as => :headshot_capture

  #resources :searches
  resources :work_serveys
  resources :webcam_pictures
  resources :customers
  resources :tabs do
   get :tab_status
  end
  resources :profiles
  resources :customer_documents

  resources :co_applicant_businesses do
   member do
     post :business_verification
     get :business_verification
     post :accept
     get :accept
     post :re_indicated
     get :re_indicated
   end
  end

  resources :co_applicants do
    member do
     post :co_applicant_verification
     get :co_applicant_verification
     post :accept
     get :accept
     post :re_indicated
     get :re_indicated
    end

  end
  resources :co_applicant_work_details
  resources :customer_verifications
  resources :business_verifications
  resources :co_applicant_verifications
  resources :client_verifications
  resources :serveys

  resources :customers do
    member do
     post :customer_verification
     get :customer_verification
     get :print_customer
     post :customer_work_servey_verification
     get :customer_work_servey_verification
     post :accept
     get :accept
     post :re_indicated
     get :re_indicated
    end
  end
  resources :businesses do
   member do
     post :business_verification
     get :business_verification
     post :accept
     get :accept
     post :re_indicated
     get :re_indicated
   end
  end

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  devise_for :users, :controllers => { :registrations => "registrations" } do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

end
