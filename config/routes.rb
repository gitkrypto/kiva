Rails.application.routes.draw do
  root 'static_pages#home'

  resources :transactions,              only: [:show, :index] 
  resources :blocks,                    only: [:show, :index] 
  resources :accounts,                  only: [:show, :index]
  resources :aliases,                   only: [:show, :index]  
  #resources :unconfirmed_transactions,  only: [:show, :index]
  #resources :pending_transactions,      only: [:show, :index]  


  get '/notfound',                      to:   'static_pages#notfound'
  
  get '/transactions/search/:search',   to:   'transactions#search'
  get '/accounts/search/:search',       to:   'accounts#search'
  get '/blocks/search/:search',         to:   'blocks#search'
  get '/aliases/search/:search',        to:   'aliases#search'

  get '/blocks/stats/:from_height/:to_height',  to:   'blocks#stats'

  get '/search',                        to:   'search#search'
  get '/search/:search',                to:   'search#search'
  
  get '/json/transactions',             to:   'transactions#latest'
  get '/json/total_coins',              to:   'blocks#total_coins'
end