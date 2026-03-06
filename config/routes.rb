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
  resources :educational_organizations, only: [:new, :create, :index]
  resources :events, only: [:edit, :show, :new, :create, :update, :destroy] do
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
      resources :plans, only: [:index, :new, :create, :edit, :show, :update]
      resources :events, only: [:index]
      resources :users, only: [:index]
      resources :directions, only: [:index, :new, :create, :edit, :show, :update, :destroy]
    end
    collection do
      get :manage_user_roles  #страница управления ролями
    end
  end
  resources :directions, only: [ :destroy] do
  end
  resources :plan_events, only: [ :edit, :create, :destroy]
  
  resources :plans, only: [:destroy] do
    # Стандартные вложенные ресурсы для plan_events
    collection do
      get :index, constraints: ->(req) { req.params[:for_bulk_add].present? }
    end
    resources :plan_events, only: [:create, :destroy] do
      collection do
        # POST /plans/:plan_id/plan_events/bulk_create
        post :bulk_create
      end
    end
  
    # GET /plans?for_events=true&department_id=X&start_date=...
  # Обычный index с фильтрацией через параметры
  member do
    post :bulk_add_events       # УДАЛИТЬ
    get :add_events             # УДАЛИТЬ
    post :add_event             # УДАЛИТЬ
    delete :remove_event        # УДАЛИТЬ
    patch :reorder              # ПЕРЕМЕСТИТЬ в plan_events
  end
  end 
end