Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  scope module: :public do
    resources :essays,  only: [:index, :show], param: :slug
    resources :builds,  only: [:index]
    resources :books,   only: [:index]
    resources :field,   only: [:index, :show], param: :slug
    get "/now",     to: "now#show",     as: :now
    get "/feed",    to: "feed#index",   as: :feed
    get "/contact", to: "pages#contact", as: :contact
    get "/about",   to: "pages#about",   as: :about
    get "/uses",    to: "pages#uses",     as: :uses
  end

  get "/sitemap.xml", to: "sitemap#index", defaults: { format: :xml }

  namespace :admin do
    root "essays#index"
    resources :essays
    resources :builds
    resources :books
    resources :field do
      resources :field_items, only: [:create, :destroy, :update]
    end
    resource :now, only: [:edit, :update]
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "public/feed#index"
end
