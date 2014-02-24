Buscador::Application.routes.draw do

  resources :bitacoras

  resources :listas

  resources :roles

  resources :catalogos

  resources :categorias_taxonomica

  resources :usuarios do
    collection do
      get :inicia_sesion
      post :intento_sesion
      put :cierra_sesion
    end
  end

  resources :estatuses

  resources :especies_catalogo do
    collection do
      get :autocomplete_catalogo_descripcion
    end
  end

  resources :especies do
    collection do
      put :aniade_taxones
      get :dame_listas
      get :buscaDescendientes
      get :muestraTaxonomia
      get :autocomplete_especie_nombre
      get :resultados
      get :error
    end
  end

  resources :especies_bibliografia

  resources :especies_estatus

  resources :tipos_regiones

  resources :regiones

  resources :especies_regiones do
    collection do
      get :autocomplete_region_nombre
    end
  end

  resources :tipos_distribuciones

  resources :especies_estatus_bibliografia

  resources :nombres_comunes do
    collection do
      get :buscar
      get :autocomplete_nombre_comun_comun
    end
  end

  resources :nombres_regiones

  resources :nombre_regiones_bibliografias

  resources :bibliografias do
    collection do
      get :autocomplete_bibliografia_autor
    end
  end

  get '/conabio/photo_fields' => 'conabio#photo_fields'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'especies#index'

  # Example of regular route:
  post 'especies/new/:parent_id' => 'especies#new', :via => :post, :as => "new"

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
