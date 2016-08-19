Buscador::Application.routes.draw do

  get "busquedas/basica"
  get "busquedas/avanzada"
  get "busquedas/resultados"
  get "busquedas/nombres_comunes"

  get "inicio/comentarios"
  get "inicio/index"
  get "inicio/acerca"
  get "inicio/error"

  get 'avanzada', to: "busquedas#avanzada", as: :avanzada
  get 'resultados', to: "busquedas#resultados", as: :resultados
  get 'checklist', to: "busquedas#checklist", as: :checklist
  get 'cat_tax_asociadas', to: "busquedas#cat_tax_asociadas", as: :cat_tax_asociadas

  get 'comentarios/administracion' => 'comentarios#admin', as: :admin
  post 'comentarios/:id/update_admin' => 'comentarios#update_admin'
  get 'especies/:especie_id/comentarios/:id/show_respuesta' => 'comentarios#show_respuesta'

  get 'comentarios/generales' => 'comentarios#extrae_comentarios_generales'
  get 'comentarios/correoId' => 'comentarios#show_correo'

  resources :adicionales do
    collection do
      post :actualiza_nom_comun
    end
  end

  resources :metadatos

  devise_for :usuarios
  resources :bitacoras

  resources :listas do
    collection do
      post :dame_listas
      post :aniade_taxones_seleccionados
    end
  end

  resources :roles

  resources :catalogos

  resources :categorias_taxonomica

  resources :usuarios do
    collection do
      post :cambia_locale
    end
  end

  resources :estatuses

  resources :especies_catalogo do
    collection do
      get :autocomplete_catalogo_descripcion
    end
  end

  resources :especies, as: :especie do
    resources :comentarios  # Anida este resource para que la URL y el controlador sean mas coherentes

    collection do
      post :update_photos, :as => :update_photos_for
      get ':id/arbol' => 'especies#arbol'
      get :error
      get :datos_principales
      get :kmz
      get :kmz_naturalista
      get :cache_services
      get ':id/naturalista' => 'especies#naturalista'
      get ':id/arbol_nodo' => 'especies#arbol_nodo'
      get ':id/hojas_arbol_nodo' => 'especies#hojas_arbol_nodo'
      get ':id/hojas_arbol_identado' => 'especies#hojas_arbol_identado'
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
  get 'explora_por_clasificacion' => 'especies#arbol_inicial'

  match 'adicionales/:especie_id/edita_nom_comun' => 'adicionales#edita_nom_comun', :as => :edita_nombre_comun_principal, :via => :get

  match 'flickr/photo_fields' => 'flickr#photo_fields', :via => :get
  match '/conabio/photo_fields' => 'conabio#photo_fields', :via => :get
  match '/eol/photo_fields' => 'eol#photo_fields', :via => :get
  match '/wikimedia_commons/photo_fields' => 'wikimedia_commons#photo_fields', :via => :get
  #match 'photos/local_photo_fields' => 'photos#local_photo_fields', :as => :local_photo_fields
  match '/photos/:id/repair' => 'photos#repair', :as => :photo_repair, :via => :put
  match 'flickr/photos.:format' => 'flickr#photos', :via => :get
  match '/especies/:id/describe' => 'especies#describe', :as => :descripcion, :via => :get
  get '/especies/:id/descripcion_catalogos' => 'especies#descripcion_catalogos'
  get '/especies/:id/comentarios_taxon' => 'especies#comentarios_taxon'

  resources :photos, :only => [:show, :update, :destroy] do
    member do
      put :rotate
    end
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'inicio#index'

  # Example of regular route:
  post 'especies/new/:parent_id' => 'especies#new', :via => :post, :as => 'new'
  mount Soulmate::Server, :at => '/sm'

  # Webservice para la validacion de nuevos o actualizados records (pendiente)
  #wash_out :webservice

  # End-points para la validacion de nuevos o actualizados records (actual)
  post 'validaciones/update' => 'validaciones#update'
  post 'validaciones/insert' => 'validaciones#insert'
  post 'validaciones/delete' => 'validaciones#delete'

  # Para las validaciones de taxones la simple y la avanzada
  get 'validaciones/taxon' => 'validaciones#taxon'
  get 'validaciones/taxon_simple' => 'validaciones#taxon_simple'
  get 'validaciones/taxon_excel' => 'validaciones#taxon_excel'
  post 'validaciones/resultados_taxon_simple' => 'validaciones#resultados_taxon_simple'
  post 'validaciones/resultados_taxon_excel' => 'validaciones#resultados_taxon_excel'

end
