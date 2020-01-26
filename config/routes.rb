Rails.application.routes.draw do

  namespace :v1 do
    resources :auth, only: :create do
      delete :destroy, on: :collection
    end
    resources :time_records, only: :index
    put "/users", controller: :users, action: :update
  end

  post "/graphql", to: "graphql#execute"
end
