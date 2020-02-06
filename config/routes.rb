Rails.application.routes.draw do

  namespace :v1 do
    resources :auth, only: [:create, :index] do
      delete :destroy, on: :collection
    end
    resources :time_records, only: [:index, :create, :update, :destroy]
    resources :reports, only: :index
    resources :projects, only: :index
    resources :users, only: :index do
      put :update, on: :collection
    end
  end

end
