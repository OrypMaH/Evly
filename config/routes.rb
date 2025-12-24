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
  resources :events, only: [:edit, :new, :create, :update, :destroy] do
    member do
      get :available_departments
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
  resources :users, only: [:new, :create, :edit, :update] do
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
  resources :roles, only: [ :new, :create, :edit, :update, :destroy] do
    member do
      post :assign_user
      delete :remove_user
    end
  end
  resources :departments, only: [ :index, :new, :edit, :create, :update, :destroy] do
    scope module: :department_resources do
      resources :roles, only:[:index]
      resources :plans, only: [:index, :new]
      resources :events, only: [:index]
      resources :users, only: [:index]
    end
    collection do
      get :manage_user_roles  #страница управления ролями
    end
  end
  resources :plan_events, only: [ :edit, :create, :update, :destroy]
  
  resources :plans do
    collection do
      post :available_for_events  # POST /plans/available_for_events
    end
    member do
      post :bulk_add_events  # Массовое добавление мероприятий
      get :add_events      # Страница добавления мероприятий
      post :add_event      # Добавление мероприятия в план
      delete :remove_event # Удаление мероприятия из плана
      patch :reorder       # Изменение порядка мероприятий
    end
  end
end