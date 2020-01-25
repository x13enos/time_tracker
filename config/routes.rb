Rails.application.routes.draw do

  namespace :v1 do
    resources :auth, only: :create do
      delete :destroy, on: :collection
    end

  end

end
