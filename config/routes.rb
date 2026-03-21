Rails.application.routes.draw do
  get "categorias-e-tags", to: "categories_and_tags#index", as: :categories_and_tags

  resources :accounts
  resources :categories
  resources :transactions
  resources :tags

  get "dashboard", to: "dashboard#index", as: :dashboard

  get "backup", to: "backup#show", as: :backup
  get "backup/download", to: "backup#download", as: :download_backup
  post "backup/restore", to: "backup#restore", as: :restore_backup

  root "dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
