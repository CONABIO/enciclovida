# coding: utf-8
Buscador::Application.routes.draw do

  #match '*path' => redirect('/mantenimiento.html'), via: [:get, :post]

=begin
  namespace :admin do
    resources :catalogos do
      collection do
        get :dame_nivel
      end
    end
    resources :especies_catalogos
    resources :regiones do
      collection do
        get :autocompleta
      end
    end
    resources :bibliografias do
      collection do
        get :autocompleta
      end
    end
  end
=end

  # metamares, alias infoceanos
  if Rails.env.development?
    namespace :metamares do
      root 'metamares#index'
      resources :admin
      resources :proyectos
      resources :directorio
      get 'graficas' => 'metamares#graficas'
      get 'grafica1' => 'metamares#grafica1'
      get 'grafica2' => 'metamares#grafica2'
      get 'dame-institucion' => 'metamares#dame_institucion'
      get 'dame-keyword' => 'metamares#dame_keyword'
    end
  else
    constraints host: 'infoceanos.conabio.gob.mx' do
      root 'metamares/metamares#index'
      namespace :metamares do
        root 'metamares#index'
        resources :admin
        resources :proyectos
        resources :directorio
        get 'graficas' => 'metamares#graficas'
        get 'grafica1' => 'metamares#grafica1'
        get 'grafica2' => 'metamares#grafica2'
        get 'dame-institucion' => 'metamares#dame_institucion'
        get 'dame-keyword' => 'metamares#dame_keyword'
      end
    end
  end

  namespace :pmc do
    resources :peces, :as => :pez do
      collection do
        get :dameNombre
        get :busqueda
      end
    end

    resources :propiedades do
      collection do
        get 'dame-tipo-propiedades/:q' => 'propiedades#dame_tipo_propiedades'
      end
    end
  end

  namespace :api do
    resources :descripciones do
      collection do

      end
    end
  end

  # Admin y front end de fichas
  namespace :fichas do
    #resources :taxa
    resources :front do
      collection do
        # I. Clasificación y descripción de la especie
        get ':id/clasifDescEspecie' => 'fichas#clasificacion_y_descripcion_de_especie'

        # II. Distribución de la especie
        get ':id/distribucionEspeciespecie' => 'fichas#distribucione_de_la_especie'

        # III.Tipo de ambiente en donde se desarrolla la especie
        get ':id/ambienteDesarrolloEspecie' => 'fichas#ambiente_de_desarrollo_de_especie'

        # IV. Biología de la especie
        get ':id/biologiaEspecie' => 'fichas#biologia_de_la_especie'

        # V. Ecología y demografía de la especie
        get ':id/ecologiaYDemografiaEspecie' => 'fichas#ecologia_y_demografia_de_especie'

        # VI. Genética de la especie
        get ':id/geneticaEspecie' => 'fichas#genetica_de_especie'

        # VII. Importancia de la especie
        get ':id/importanciaEspecie' => 'fichas#importancia_de_especie'

        # VIII. Estado de conservación de la especie
        get ':id/estadoConservacionEspecie' => 'fichas#estado_de_conservacion_de_especie'

        # IX. Especies prioritarias para la conservación
        get ':id/especiesPrioritariasParaConservacion' => 'fichas#especies_prioritarias_para_conservacion'

        # X. Necesidades de información
        get ':id/necesidadesDeInformacion' => 'fichas#necesidades_de_informacion'
      end
    end
  end

  #get 'estadisticas' => 'estadisticas#show'
  #get 'filtros_estadisticas' => 'estadisticas#filtros_estadisticas'
  #get '' => ''

  get 'peces' => 'pmc/peces#index'
  get 'peces/busqueda' => 'pmc/peces#index'

  resources :regiones_mapas do
    collection do
      get 'dame-tipo-region' => :dame_tipo_region
      get 'dame-ancestry' => :dame_ancestry
    end
  end

  # Pagina de exoticas, mal quitar en eun futuro
  get 'exoticas-invasoras' => 'paginas#exoticas_invasoras'
  get 'exoticas-invasoras-paginado' => 'paginas#exoticas_invasoras_paginado'

  # Busqueda por region
  get 'explora-por-ubicacion' => 'ubicaciones#ubicacion'
  get 'explora-por-region' => 'ubicaciones#por_region'
  get 'explora-por-region/especies-por-grupo' => 'ubicaciones#especies_por_grupo'
  get 'municipios-por-estado' => 'ubicaciones#municipios_por_estado'
  get 'explora-por-region/descarga-taxa' => 'ubicaciones#descarga_taxa'
  get 'explora-por-region/descarga-taxa' => 'ubicaciones#descarga_taxa'
  get 'explora-por-region/conteo-por-grupo' => 'ubicaciones#conteo_por_grupo'


  get "inicio/comentarios"
  get "inicio/index"
  get "inicio/acerca"
  get "inicio/error"

  # rutas de bsuquedas
  get 'avanzada', to: "busquedas#avanzada", as: :avanzada
  get 'resultados', to: "busquedas#resultados", as: :resultados
  get 'checklist', to: "busquedas#checklist", as: :checklist
  get 'cat_tax_asociadas', to: "busquedas#cat_tax_asociadas", as: :cat_tax_asociadas
  get "busquedas/basica"
  get "busquedas/avanzada"
  get "busquedas/resultados"
  get "busquedas/nombres_comunes"

  # Rutas de comentarios
  get 'comentarios/administracion' => 'comentarios#admin', as: :admin
  post 'comentarios/:id/update_admin' => 'comentarios#update_admin'
  get 'especies/:especie_id/comentarios/:id/respuesta_externa' => 'comentarios#respuesta_externa'
  get 'comentarios/generales' => 'comentarios#extrae_comentarios_generales'
  get 'comentarios/correoId' => 'comentarios#show_correo'

  resources :adicionales do
    collection do
      post :actualiza_nom_comun
    end
  end

  # Usuarios
  devise_for :usuarios
  devise_for :metausuarios, :controllers => {:confirmations => "metamares/metausuarios/confirmations", :passwords => "metamares/metausuarios/passwords", :registrations => "metamares/metausuarios/registrations", :unlocks => "metamares/metausuarios/unlocks", :sessions => "metamares/metausuarios/sessions"}
  get 'usuarios/conabio'

  resources :listas do
    collection do
      post :dame_listas
      post :aniade_taxones_seleccionados
    end
  end

  resources :usuarios do
    collection do
      post :cambia_locale
    end
  end

  # La vista mas importante, especies
  resources :especies, :except => :show, as: :especie do
    resources :comentarios  # Anida este resource para que la URL y el controlador sean mas coherentes

    collection do
      get '/:id', action: 'show', constraints: { id: /\d{1,8}[\-A-Za-z]*/ }
      get :error
      get ':id/observaciones-naturalista' => 'especies#observaciones_naturalista'
      get ':id/observacion-naturalista/:observacion_id' => 'especies#observacion_naturalista'
      get ':id/ejemplares-snib' => 'especies#ejemplares_snib'
      get ':id/ejemplar-snib/:ejemplar_id' => 'especies#ejemplar_snib'
      get ':id/fotos-referencia' => 'especies#fotos_referencia'
      post ':id/fotos-referencia' => 'especies#fotos_referencia'
      get ':id/media' => 'especies#media'
      get ':id/bdi-photos' => 'especies#bdi_photos'
      get ':id/bdi-videos' => 'especies#bdi_videos'
      get ':id/media-cornell' => 'especies#media_cornell'
      get ':id/media-tropicos' => 'especies#media_tropicos'
      get ':id/fotos-naturalista' => 'especies#fotos_naturalista'
      get ':id/nombres-comunes-naturalista' => 'especies#nombres_comunes_naturalista'
      get ':id/nombres-comunes-todos' => 'especies#nombres_comunes_todos'
      post ':id/guarda-id-naturalista' => 'especies#cambia_id_naturalista'
      get ':id/dame-nombre-con-formato' => 'especies#dame_nombre_con_formato'
      get ':id/resumen-wikipedia' => 'especies#resumen_wikipedia'
      get ':id/descripcion' => 'especies#descripcion'
    end
  end

  # TODO: quitar estos scaffold, no se ocupan
  resources :especies_bibliografia
  resources :especies_estatus
  resources :tipos_regiones
  resources :regiones
  resources :especies_regiones
  resources :tipos_distribuciones
  resources :especies_estatus_bibliografia
  resources :nombres_comunes
  resources :nombres_regiones
  resources :nombre_regiones_bibliografias
  resources :estatuses
  resources :especies_catalogo
  resources :roles
  resources :catalogos
  resources :categorias_taxonomica
  resources :bitacoras
  resources :roles_categorias_contenido
  resources :usuarios_especie
  resources :usuarios_roles

  # explora por clasificacion
  get 'explora-por-clasificacion' => 'busquedas#por_clasificacion'
  get 'explora-por-clasificacion/hojas' => 'busquedas#por_clasificacion_hojas'


  match 'adicionales/:especie_id/edita_nom_comun' => 'adicionales#edita_nom_comun', :as => :edita_nombre_comun_principal, :via => :get

  get '/especies/:id/descripcion_catalogos' => 'especies#descripcion_catalogos'
  get '/especies/:id/comentario' => 'especies#comentarios'
  get '/especies/:id/noticias' => 'especies#noticias'

  # I. Clasificación y descripción de la especie
  get 'media_tropicos/:id' => 'tropicos#tropico_especie'

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
  get 'validaciones' => 'validaciones#index'
  #get 'validaciones/simple' => 'validaciones#simple', as: 'validacion_simple'
  #get 'validaciones/avanzada' => 'validaciones#avanzada', as: 'validacion_avanzada'
  post 'validaciones/simple' => 'validaciones#simple', as: 'validacion_simple'
  post 'validaciones/avanzada' => 'validaciones#avanzada', as: 'validacion_avanzada'

  get 'bdi_nombre_cientifico' => 'webservice#bdi_nombre_cientifico'

  get 'geojson-a-topojson' => 'webservice#geojson_a_topojson'
  post 'geojson-a-topojson' => 'webservice#geojson_a_topojson'

  mount Delayed::Web::Engine, at: '/jobs'
end
