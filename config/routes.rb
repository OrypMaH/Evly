Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
 # get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root 'pages#index'
  resources :events, only: [ :index, :new, :edit, :create, :update, :destroy]
  resources :events do
    member do
      get :available_departments
      get :offer
      post :offer
      post :assign   # Назначить участие
    end
  end
  resources :offered_event_departments do
    member do
      patch :approve  # Утвердить участие
      patch :reject   # Отклонить участие
    end
  end
  resources :approved_event_departments do
    member do
      patch :approve  # Утвердить участие
      patch :reject   # Отклонить участие
    end
  end
  resources :users, only: [:new, :create, :edit, :update]
  resources :users do
    member do
      get :edit_roles
      patch :update_roles
      post :select_current_role
    end
    collection do
      get :manage_roles  #страница управления ролями
      get :search  # Создаст маршрут /users/search
    end
  end
  resource :session, only: [:new, :create, :destroy]
  resources :roles, only: [ :index, :new, :create, :edit, :update, :destroy]
  resources :roles do
    member do
      post :assign_user
      delete :remove_user
    end
  end
  resources :departments, only: [ :index, :new, :edit, :create, :update, :destroy]
  resources :departments do
    member do
      get :role_list
    end
    collection do
      get :manage_user_roles  #страница управления ролями
    end
  end
end