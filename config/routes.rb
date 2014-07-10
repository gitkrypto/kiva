Rails.application.routes.draw do
  root 'static_pages#home'

  resources :transactions,              only: [:show, :index] 
  resources :unconfirmed_transactions,  only: [:show, :index]
  resources :blocks,                    only: [:show, :index] 
  resources :accounts,                  only: [:show, :index]
  resources :pending_transactions,      only: [:show, :index]  
  resources :aliases,                   only: [:show, :index]  
  
  get '/search',                        to:   'search#search'
  get '/search/:search',                to:   'search#search'
  
  get '/json/transactions',             to:   'transactions#latest'
  get '/json/total_coins',              to:   'blocks#total_coins'
end