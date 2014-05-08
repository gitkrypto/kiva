Rails.application.routes.draw do
  root 'static_pages#home'

  resources :transactions,  only: [:show, :index] 
  resources :blocks,        only: [:show, :index] 
  resources :accounts,      only: [:show, :index] 
  
  get '/search',            to:   'search#search'
  get '/search/:search',    to:   'search#search'
  
  get '/transactions-json', to:   'transactions#latest'
end