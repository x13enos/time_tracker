Rails.application.routes.draw do

  mount TimeTrackerExtension::Engine, at: "/"

  get 'reports/:id', to: 'reports#show'

  namespace :v1 do
    namespace :admin do
      resources :users, only: :index
    end
    resources :auth, only: [:create, :index] do
      delete :destroy, on: :collection
    end
    resources :time_records, only: [:index, :create, :update, :destroy]
    resources :reports, only: :index
    resources :projects, only: [:index, :create, :update, :destroy] do
      resources :project_users, only: [:create, :destroy]
    end
    resources :users, only: :index do
      put :update, on: :collection
      put :change_workspace, on: :collection
    end
    resources :workspaces, only: [:index, :create, :update, :destroy] do
      resources :workspace_users, only: [:index, :create, :destroy]
    end
    resources :tags, except: [:new, :show, :edit]
    namespace :users do
      resources :passwords, only: :create do
        put :update, on: :collection
      end
      resources :invitations, only: [] do
        put :update, on: :collection
      end
      resources :registrations, only: :create
    end
  end
end
