Buscador::Application.routes.draw do

  resources :metadatos

  devise_for :usuarios
  resources :bitacoras

  resources :listas do
    collection do
      post :dame_listas
      post :aniade_taxones
    end
  end

  resources :roles

  resources :catalogos

  resources :categorias_taxonomica

  resources :usuarios do
    collection do
      post :guarda_filtro
      post :limpiar
      post :cambia_locale
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
      post :update_photos, :as => :update_photos_for
      get :busca_por_lote
      get :arbol
      get :resultados
      post :resultados_por_lote
      get :error
      get :datos_principales
      get :kmz
      get :kmz_naturalista
      get :filtros
    end
  end

  resources :especies_bibliografia

  resources :especies_estatus

  resources :tipos_regiones

  resources :regiones do
    collection do
      post :regiones
    end
  end

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

  match 'especies/:id/edit_photos' => 'especies#edit_photos', :as => :edit_taxon_photos, :via => :get
  match 'especies/:id/photos' => 'especies#photos', :as => :taxon_photos, :via => :get

  match 'flickr/photo_fields' => 'flickr#photo_fields', :via => :get
  match '/conabio/photo_fields' => 'conabio#photo_fields', :via => :get
  match '/eol/photo_fields' => 'eol#photo_fields', :via => :get
  match '/wikimedia_commons/photo_fields' => 'wikimedia_commons#photo_fields', :via => :get
  #match 'photos/local_photo_fields' => 'photos#local_photo_fields', :as => :local_photo_fields
  match '/photos/:id/repair' => 'photos#repair', :as => :photo_repair, :via => :put
  match 'flickr/photos.:format' => 'flickr#photos', :via => :get
  match '/especies/:id/describe' => 'especies#describe', :as => :descripcion, :via => :get

  resources :photos, :only => [:show, :update, :destroy] do
    member do
      put :rotate
    end
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'especies#index'

  # Example of regular route:
  post 'especies/new/:parent_id' => 'especies#new', :via => :post, :as => 'new'
  mount Soulmate::Server, :at => '/sm'

  # Webservice para la validacion de nuevos o actualizados records (pendiente)
  #wash_out :webservice

  # End-points para la validacion de nuevos o actualizados records (actual)
  post 'validaciones/update' => 'validaciones#update'
  post 'validaciones/insert' => 'validaciones#insert'
  post 'validaciones/delete' => 'validaciones#delete'

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
