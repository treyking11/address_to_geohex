Rails.application.routes.draw do
  root to: 'geocoder#index'
  get 'geocoder' => 'geocoder#index'
  post 'geocoder' => 'geocoder#create'
  post 'reverse_geocoder' => 'reverse_geocoder#create'


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
