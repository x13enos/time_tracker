Rails.application.routes.draw do

  namespace :v1 do
    resources :auth, only: [:create, :index] do
      delete :destroy, on: :collection
    end
    resources :time_records, only: [:index, :create, :update, :destroy]
    resources :reports, only: :index
    resources :projects, only: [:index, :create, :update, :destroy] do
      put :assign_user, on: :member
      put :remove_user, on: :member
    end
    resources :users, only: :index do
      put :update, on: :collection
    end
    resources :workspaces, only: [:index, :create, :update, :destroy] do
      resources :workspace_users, only: [:create, :destroy]
    end
    resources :tags, except: [:new, :edit]
    namespace :users do
      resources :passwords, only: :create do
        put :update, on: :collection
      end
      resources :invitations, only: [] do
        put :update, on: :collection
      end
    end
  end

end
