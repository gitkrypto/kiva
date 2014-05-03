Rails.application.routes.draw do
  get 'static_pages/home'

  resources :transactions
  resources :blocks
end