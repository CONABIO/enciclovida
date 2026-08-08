# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20260805193206) do

  create_table "EliminarMapaDistribucion", id: false, force: :cascade, options: "ENGINE=Aria DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci PAGE_CHECKSUM=1" do |t|
    t.integer "IdNombre", default: 0, null: false, comment: "Identificador único del taxón  (asignación de un número consecutivo para cada registro adicionado)."
    t.string "NombreCompleto", default: "", collation: "utf8_bin"
    t.string "TaxonCompleto", default: "", collation: "utf8_bin"
    t.string "IdCAT", limit: 50
  end

  create_table "MapasDistribucion", id: false, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.string "taxonoriginal"
    t.string "Titulo"
    t.string "sp"
    t.float "prioridad", limit: 53
    t.string "Reino"
    t.string "Divisionphylum"
    t.string "Clase"
    t.string "Orden"
    t.string "Familia"
    t.string "genero"
    t.string "especie"
    t.string "sub_sp"
    t.string "sub_infra"
    t.string "idCAT"
    t.string "CategoriaTaxonomica_idCAT"
    t.string "layers"
    t.string "styler"
    t.string "bbox"
    t.string "clave"
    t.string "GrupoSCAT"
    t.string "EnclicloVida_Final"
    t.string "anio"
    t.string "autor"
    t.string "url_nuevo"
    t.string "url_viejo"
    t.string "url_descargaZip"
    t.index ["clave"], name: "clave"
    t.index ["idCAT"], name: "idCAT"
  end

  create_table "_usuariosTodo", id: false, force: :cascade, options: "ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=1" do |t|
    t.integer "usuario_id"
    t.index ["usuario_id"], name: "Index_1"
  end

  create_table "adicionales", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "especie_id", null: false
    t.string "nombre_comun_principal", collation: "utf8_general_ci"
    t.string "foto_principal", limit: 1000, collation: "utf8_general_ci"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "nombres_comunes", limit: 4294967295, collation: "utf8mb4_unicode_ci"
    t.integer "idMillon"
    t.index ["especie_id"], name: "ClusteredIndex-20160801-144106"
    t.index ["nombre_comun_principal"], name: "NonClusteredIndex-20160801-144122", length: { nombre_comun_principal: 191 }
  end

  create_table "bibliografias", id: :integer, default: nil, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.text "observaciones", limit: 4294967295
    t.string "autor", null: false
    t.string "anio", limit: 50, null: false
    t.string "titulo_publicacion", null: false
    t.string "titulo_sub_publicacion"
    t.string "editorial_pais_pagina"
    t.string "numero_volumen_anio"
    t.string "editores_compiladores"
    t.string "isbnissn", limit: 50
    t.text "cita_completa", limit: 4294967295
    t.string "orden_cita_completa", limit: 15
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bitacoras", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "descripcion", limit: 4294967295
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "usuario_id", null: false
  end

  create_table "categorias_contenido", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "nombre", null: false
    t.string "ancestry"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comentarios", primary_key: "idConsecutivo", id: :integer, force: :cascade, options: "ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=1" do |t|
    t.text "comentario", limit: 4294967295, null: false
    t.string "correo"
    t.string "nombre"
    t.integer "especie_id", null: false
    t.integer "usuario_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at"
    t.integer "estatus", default: 2, null: false
    t.string "ancestry"
    t.datetime "fecha_estatus"
    t.integer "usuario_id2"
    t.integer "categorias_contenido_id", default: 31, null: false
    t.string "institucion"
    t.string "idBak"
    t.string "id", limit: 10, default: ""
  end

  create_table "comentarios_generales", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "comentario_id", limit: 10, null: false
    t.text "subject", limit: 4294967295, null: false
    t.text "commentArray", limit: 4294967295, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comentarios_proveedores", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "comentario_id", limit: 10, null: false
    t.string "proveedor_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comentariosbkp", id: false, force: :cascade, options: "ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=1" do |t|
    t.text "comentario", limit: 4294967295, null: false
    t.string "correo"
    t.string "nombre"
    t.integer "especie_id", null: false
    t.integer "usuario_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at"
    t.integer "estatus", default: 2, null: false
    t.string "ancestry"
    t.datetime "fecha_estatus"
    t.integer "usuario_id2"
    t.integer "categorias_contenido_id", default: 31, null: false
    t.string "institucion"
    t.string "idBak"
    t.integer "idConsecutivo", default: 0, null: false
    t.string "id", limit: 10, default: ""
  end

  create_table "delayed_jobs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", limit: 4294967295, null: false
    t.text "last_error", limit: 4294967295
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
    t.index ["queue"], name: "idx_delayed_jobs_queue"
  end

  create_table "especies_estadistica", id: false, force: :cascade, options: "ENGINE=Aria DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci PAGE_CHECKSUM=1" do |t|
    t.integer "id", default: 0, null: false
    t.integer "especie_id"
    t.integer "estadistica_id"
    t.integer "conteo", default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["especie_id", "estadistica_id"], name: "uk_especie_estadistica", unique: true
  end

  create_table "especies_estadisticaBKP", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "especie_id"
    t.integer "estadistica_id"
    t.integer "conteo", default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["especie_id"], name: "idx_especies_estadistica_especie_id"
    t.index ["estadistica_id"], name: "idx_especies_estadistica_estadistica_id"
  end

  create_table "especies_estadistica_respaldo", id: false, force: :cascade, options: "ENGINE=Aria DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci PAGE_CHECKSUM=1" do |t|
    t.integer "id", default: 0, null: false
    t.integer "especie_id"
    t.integer "estadistica_id"
    t.integer "conteo", default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "estadisticas", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "descripcion_estadistica"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exoticas_catalogos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "tipo", null: false
    t.string "clave", null: false
    t.string "nombre", null: false
    t.text "descripcion"
    t.boolean "activo", default: true
    t.integer "orden", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tipo", "clave"], name: "index_exoticas_catalogos_on_tipo_and_clave", unique: true
    t.index ["tipo"], name: "index_exoticas_catalogos_on_tipo"
  end

  create_table "exoticas_documentos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "exotica_invasora_id", null: false
    t.integer "tipo_documento_id", null: false
    t.string "titulo", null: false
    t.string "ruta", null: false
    t.string "nombre_original"
    t.text "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exotica_invasora_id"], name: "index_exoticas_documentos_on_exotica_invasora_id"
    t.index ["tipo_documento_id"], name: "index_exoticas_documentos_on_tipo_documento_id"
  end

  create_table "exoticas_invasoras", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "especie_id", null: false
    t.integer "grupo_id"
    t.integer "ambiente_id"
    t.integer "origen_id"
    t.integer "presencia_id"
    t.integer "estatus_id"
    t.string "creditos_fotos"
    t.text "observaciones"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ambiente_id"], name: "index_exoticas_invasoras_on_ambiente_id"
    t.index ["especie_id"], name: "index_exoticas_invasoras_on_especie_id", unique: true
    t.index ["estatus_id"], name: "index_exoticas_invasoras_on_estatus_id"
    t.index ["grupo_id"], name: "index_exoticas_invasoras_on_grupo_id"
    t.index ["origen_id"], name: "index_exoticas_invasoras_on_origen_id"
    t.index ["presencia_id"], name: "index_exoticas_invasoras_on_presencia_id"
  end

  create_table "exoticas_invasoras_catalogos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "exotica_invasora_id", null: false
    t.integer "catalogo_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["catalogo_id"], name: "index_exoticas_invasoras_catalogos_on_catalogo_id"
    t.index ["exotica_invasora_id", "catalogo_id"], name: "idx_exoticas_catalogos", unique: true
  end

  create_table "listas", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "nombre_lista", null: false
    t.text "columnas", limit: 4294967295
    t.string "formato"
    t.integer "esta_activa", limit: 2, default: 0, null: false
    t.text "cadena_especies", limit: 4294967295
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "usuario_id", null: false
  end

  create_table "proveedores", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "especie_id", null: false
    t.integer "naturalista_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "geoserver_info"
    t.string "tropico_id"
    t.string "IdCAT", limit: 50
  end

  create_table "relacionCentralizacion", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "id", limit: 50
    t.string "idCAT", limit: 50
    t.string "idMillon", limit: 50
    t.string "idCentralizado", limit: 50
  end

  create_table "roles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "nombre_rol", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ancestry"
    t.string "observaciones"
  end

  create_table "roles_categorias_contenido", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "categorias_contenido_id"
    t.integer "rol_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "session_id", null: false
    t.text "data", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "snib", id: false, force: :cascade, options: "ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=1" do |t|
    t.string "idejemplar", limit: 32, default: "", null: false, comment: "Clave generada por la CONABIO que identifica de manera única al ejemplar. Se asigna en el momento en que el ejemplar se integra al SNIB."
    t.string "region", limit: 150, default: "", null: false, comment: "Especifica el país, estado y municipio o su división política equivalente, registrado por el colector, observador o por la CONABIO (para aquellos ejemplares que ha georreferido)."
    t.string "localidad", limit: 2048, default: "", null: false, comment: "Referencia geográfica que describe la ubicación del lugar de recolecta u observación."
    t.float "longitud", limit: 53, comment: "Longitud de la coordenada geográfica del sitio de recolecta u observación del ejemplar."
    t.float "latitud", limit: 53, comment: "Latitud de la coordenada geográfica del sitio de recolecta u observación del ejemplar."
    t.string "datum", limit: 50, default: "", null: false, comment: "Sistema de referencia geodésico a partir del cual se obtuvo la coordenada geográfica del sitio de recolecta u observación del ejemplar."
    t.string "geovalidacion", limit: 200, default: "", null: false, comment: "Resultado de la validación geográfica realizada por la CONABIO, esta se realiza hasta en cuatro niveles país/estado/municipio/localidad."
    t.string "paismapa", limit: 50, default: "", null: false, comment: "Nombre del país donde se ubica la coordenada geográfica registrada para el ejemplar, respecto a los mapas de división política de México incluyendo la zona económica exclusiva y los mapas de división política de otros países para la zona continental, utilizados para la validación geográfica realizada por la CONABIO."
    t.integer "idestadomapa", limit: 3, comment: "Clave del municipio donde se ubica la coordenada geográfica registrada para el ejemplar, respecto al mapa de división política de México y de otros países utilizados para la validación geográfica realizada por la CONABIO.", unsigned: true
    t.string "claveestadomapa", limit: 10, default: "", null: false, comment: "Clave del estado respecto al mapa de división política de México utilizado para la validación geográfica realizada por la CONABIO."
    t.string "estadomapa", limit: 50, default: "", null: false, comment: "Nombre del estado o división política equivalente donde se ubica la coordenada geográfica registrada para el ejemplar, respecto al mapa de división política de México y de otros países utilizados para la validación geográfica realizada por la CONABIO."
    t.integer "mt24idestadomapa", limit: 3, comment: "Identificador único del nombre del estado donde se ubica la coordenada geográfica registrada para el ejemplar frente al cual se extiende la franja de 12 millas náuticas del mar territorial y 12 millas náuticas de la zona contigua de México.", unsigned: true
    t.string "mt24claveestadomapa", limit: 10, default: "", null: false, comment: "Clave del estado donde se ubica la coordenada geográfica registrada para el ejemplar, frente al cual se extiende la franja de 12 millas náuticas del mar territorial y 12 millas náuticas de la zona contigua de México."
    t.string "mt24nombreestadomapa", limit: 50, default: "", null: false, comment: "Nombre del estado donde se ubica la coordenada geográfica registrada para el ejemplar, frente al cual se extiende la franja de 12 millas náuticas del mar territorial y 12 millas náuticas de la zona contigua de México."
    t.integer "idmunicipiomapa", comment: "Identificador único del nombre del municipio en donde se ubica la coordenada geográfica registrada para el ejemplar, respecto al mapa de división política municipal de México utilizado para la validación geográfica realizada por la CONABIO.", unsigned: true
    t.string "clavemunicipiomapa", limit: 10, default: "", null: false, comment: "Clave del municipio respecto al mapa de división política municipal de México utilizado para la validación geográfica realizada por la CONABIO."
    t.string "municipiomapa", limit: 80, default: "", null: false, comment: "Nombre del municipio, en donde se ubica la coordenada geográfica registrada para el ejemplar, respecto al mapa de división política municipal de México utilizado para la validación geográfica realizada por la CONABIO."
    t.integer "mt24idmunicipiomapa", comment: "Identificador único del nombre del estado donde se ubica la coordenada geográfica registrada para el ejemplar frente al cual se extiende la franja de 12 millas náuticas del mar territorial y 12 millas náuticas de la zona contigua de México.", unsigned: true
    t.string "mt24clavemunicipiomapa", limit: 10, default: "", null: false, comment: "Clave del municipio donde se ubica la coordenada geográfica registrada para el ejemplar, frente al cual se extiende la franja de 12 millas náuticas del mar territorial y 12 millas náuticas de la zona contigua de México."
    t.string "mt24nombremunicipiomapa", limit: 80, default: "", null: false, comment: "Nombre del municipio donde se ubica la coordenada geográfica registrada para el ejemplar frente al cual se extiende la franja de 12 millas náuticas del mar territorial y 12 millas náuticas de la zona contigua de México."
    t.integer "incertidumbreXY", comment: "Valor de incertidumbre calculado para las coordenadas obtenidas usando el método punto-radio."
    t.integer "altitudmapa", limit: 2, comment: "Altitud donde se ubica la coordenada geográfica obtenida del modelo de elevación ASTER GDEM2."
    t.string "usvserieI", limit: 100, default: "", null: false, comment: "Especifica el tipo de vegetación y uso del suelo donde se ubica la coordenada geográfica de acuerdo con el mapa de la serie I del INE-INEGI."
    t.string "usvserieII", limit: 100, default: "", null: false, comment: "Especifica el tipo de vegetación y uso del suelo donde se ubica la coordenada geográfica de acuerdo con el mapa de la serie II del INEGI."
    t.string "usvserieIII", limit: 100, default: "", null: false, comment: "Especifica el tipo de vegetación y uso del suelo donde se ubica la coordenada geográfica de acuerdo con el mapa de la serie III del INEGI."
    t.string "usvserieIV", limit: 100, default: "", null: false, comment: "Especifica el tipo de vegetación y uso del suelo donde se ubica la coordenada geográfica de acuerdo con el mapa de la serie IV del INEGI."
    t.string "usvserieV", limit: 100, default: "", null: false, comment: "Especifica el tipo de vegetación y uso del suelo donde se ubica la coordenada geográfica de acuerdo con el mapa serie V del INEGI."
    t.string "usvserieVI", limit: 100, default: "", null: false, comment: "Especifica el tipo de vegetación y uso del suelo donde se ubica la coordenada geográfica de acuerdo con el mapa serie VI del INEGI 2016."
    t.string "usvserieVII", limit: 100, default: "", null: false, comment: "Especifica el tipo de vegetación y uso del suelo donde se ubica la coordenada geográfica de acuerdo con el mapa serie VII del INEGI."
    t.string "usvINEGI", limit: 100, default: "", null: false, comment: "Nombre del tipo de vegetación según el sistema de Rzedowski o descriptor de la actividad humana."
    t.string "vegetacionserenanalcms", limit: 50, default: "", null: false, comment: "Vegetación para paises de snib sin fronteras"
    t.integer "idanpfederal1", limit: 3, comment: "Identificador de la Área Natural Protegida (ANP) asociada al ejemplar.", unsigned: true
    t.integer "idanpfederal2", limit: 3, comment: "Identificador de la segunda Área Natural Protegida (ANP) asociada al ejemplar.", unsigned: true
    t.string "anp", limit: 250, default: "", null: false, comment: "Especifica la jurisdicción y nombre del área natural protegida (ANP) donde se ubica la coordenada geográfica registrada para el ejemplar respecto a mapas de México de ANP."
    t.string "grupobio", limit: 50, default: "", null: false, comment: "Nombre utilizado para agrupar taxones con características biológicas generales similares asignado por la CONABIO."
    t.string "subgrupobio", limit: 250, default: "", null: false, comment: "Nombre utilizado para agrupar taxones con características biológicas similares asignado por la CONABIO; pueden incluir nombres genéricos o el nombre común de la especie."
    t.string "formadecrecimiento", limit: 100, default: "", null: false, comment: "Forma o aspecto que presenta una planta en su etapa madura: hierba, árbol, arbusto, y bejuco entre otros."
    t.string "idnombrecatvalido", limit: 50, default: "", null: false, comment: "Identificador del nombre válido en el catálogo de CONABIO."
    t.string "idnombrecat", limit: 50, default: "", null: false, comment: "Identificador del nombre del ejemplar en el catálogo de CONABIO. Dependiendo de la categoría taxonómica en la cual fue determinado el ejemplar, puede corresponder al identificador de: Clase, Orden, Familia, Género o Especie."
    t.string "endemismo", limit: 13, default: "", null: false, comment: "Indica si el taxón tiene una distribución en México considerada como endémica, cuasiendémica o semiendémica, es decir, es originaria de un área geográfica limitada y solo está presente de manera natural en dicha área."
    t.string "ambiente", limit: 100, default: "", null: false, comment: "Medio donde el ejemplar fue recolectado u observado."
    t.string "validacionambiente", limit: 100, default: "", null: false, comment: "Indica si el resultado de la validación geográfica del ejemplar coincide con el ambiente registrado."
    t.string "reino", limit: 50, default: "", null: false, comment: "Nombre científico del reino en el que se ubica el ejemplar. La CONABIO realizó limpieza de este campo mediante la corrección de errores de escritura y de datos que no corresponden con el campo."
    t.string "phylumdivision", limit: 50, default: "", null: false, comment: "Nombre científico del phylum o división en el que se ubica el ejemplar. La CONABIO realizó limpieza de este campo mediante la corrección de errores de escritura y de datos que no corresponden con el campo."
    t.string "clase", limit: 50, default: "", null: false, comment: "Nombre científico de la clase en la que se ubica el ejemplar. La CONABIO realizó limpieza de este campo mediante la corrección de errores de escritura y de datos que no corresponden con el campo."
    t.string "orden", limit: 50, default: "", null: false, comment: "Nombre científico del orden en el que se ubica el ejemplar. La CONABIO realizó limpieza del orden original en este campo, mediante la corrección de errores de escritura y la estandarización a sistemas de clasificación reconocidos por la comunidad científica."
    t.string "familia", limit: 50, default: "", null: false, comment: "Nombre científico de la familia en la que se ubica el ejemplar. La CONABIO realizó limpieza de la familia original en este campo, mediante la corrección de errores de escritura y la estandarización a sistemas de clasificación reconocidos por la comunidad científica."
    t.string "genero", limit: 50, default: "", null: false, comment: "Nombre científico del género en el que se ubica el ejemplar. La CONABIO realizó limpieza de este campo mediante la corrección de errores de escritura y de datos que no corresponden con el campo así como la estandarización a sistemas de clasificación reconocidos por la comunidad científica."
    t.string "especie", limit: 100, default: "", null: false, comment: "Nombre de la especie (binomio, trinomio, etc.) en la cual se determinó el ejemplar. La CONABIO realizó limpieza de este campo mediante la corrección de escritura y de datos que no corresponden con el campo."
    t.string "calificadordeterminacion", limit: 100, default: "", null: false, comment: "Anotación acerca de la incertidumbre en la identificación taxonómica del ejemplar."
    t.string "categoriainfraespecie", limit: 50, default: "", null: false, comment: "Nombre de la categoría taxonómica correspondiente a alguna infraespecífica."
    t.string "categoriainfraespecie2", limit: 50, default: "", null: false, comment: "Nombre de la categoría taxonómica correspondiente a alguna subinfraespecífica."
    t.text "autor", limit: 4294967295, null: false, comment: "Autor(es) y año de publicación de la descripción del género, especie (binomio, trinomio, etc.), dependiendo a que nivel se encuentre determinado el ejemplar."
    t.string "estatustax", limit: 20, default: "", null: false, comment: "Estatus taxonómico del género o especie (binomio, trinomio, etc.) dependiendo a que nivel se encuentre determinado el ejemplar y de acuerdo con los catálogos de autoridades taxonómicas de la CONABIO o de otras referencias especializadas."
    t.string "reftax", default: "", null: false, comment: "Autor(es) y año de publicación del catálogo de autoridad, listado, diccionario, sistema de clasificación (en el caso de familia) o de otras referencias especializadas usadas por la CONABIO para validar el taxón (familia, género, especie)."
    t.string "taxonvalidado", limit: 2, default: "", null: false, comment: "Indica si el nombre al que se determinó el ejemplar se pudo validar con los catálogos de autoridades taxonómicas de la CONABIO o en otras referencias especializadas."
    t.string "reinovalido", limit: 50, default: "", null: false, comment: "Nombre científico del Reino en el que se ubica el nombre válido del taxón correspondiente al ejemplar y que está reconocido en los catálogos de autoridades taxonómicas de la CONABIO o en otras referencias especializadas."
    t.string "phylumdivisionvalido", limit: 50, default: "", null: false, comment: "Nombre científico de la división o el phylum en el que se ubica el nombre válido del taxón correspondiente al ejemplar y que está reconocido en los catálogos de autoridades taxonómicas de la CONABIO o en otras referencias especializadas."
    t.string "clasevalida", limit: 50, default: "", null: false, comment: "Nombre científico de la clase en la que se ubica el nombre válido del taxón correspondiente al ejemplar y que está reconocido en los catálogos de autoridades taxonómicas de la CONABIO o en otras referencias especializadas."
    t.string "ordenvalido", limit: 50, default: "", null: false, comment: "Nombre científico del orden en el que se ubica el nombre válido del taxón correspondiente al ejemplar y que está reconocido en los catálogos de autoridades taxonómicas de la CONABIO o en otras referencias especializadas."
    t.string "familiavalida", limit: 50, default: "", null: false, comment: "Nombre científico de la familia en la que se ubica el nombre válido del taxón correspondiente al ejemplar y que está reconocido en los catálogos de autoridades taxonómicas de la CONABIO o en otras referencias especializadas."
    t.string "generovalido", limit: 50, default: "", null: false, comment: "Nombre científico del género en el que se ubica el nombre válido del taxón correspondiente al ejemplar y que está reconocido en los catálogos de autoridades taxonómicas de la CONABIO o en otras referencias especializadas."
    t.string "especievalida", limit: 100, default: "", null: false, comment: "Nombre válido de la especie (binomio, trinomio, etc.) reconocida en los catálogos de autoridades taxonómicas de la CONABIO o en otras referencias especializadas."
    t.string "categoriainfraespecievalida", limit: 50, default: "", null: false, comment: "Nombre de la categoría taxonómica correspondiente a la infraespecífica del nombre válido."
    t.string "categoriainfraespecie2valida", limit: 50, default: "", null: false, comment: "Nombre de la categoría taxonómica correspondiente a la subinfraespecífica del nombre válido."
    t.string "especievalidabusqueda", limit: 100, default: "", null: false, comment: "Binomio generovalido - epiteto especifico valido utilizado para busquedas"
    t.text "autorvalido", limit: 16777215, null: false, comment: "Nombre del autor o autores y año de la descripción del género, especie (binomio, trinomio, etc.) válida en catálogos de autoridades taxonómicas de la CONABIO o en otras referencias especializadas."
    t.string "reftaxvalido", default: "", null: false, comment: "Autor(es) y año de publicación del catálogo de autoridad, listado o diccionario o de otras referencias especializadas usadas por la CONABIO que respaldan el nombre válido del taxón (familia, género, especie)."
    t.string "categoriavalidocatscat", limit: 30, default: "", null: false
    t.string "nombrevalidocatscat", limit: 100, default: "", null: false
    t.string "taxonextinto", limit: 2, default: "", null: false, comment: "Indica si corresponde a un taxón (especie o grupo taxonómico superior como familia, orden, etc) cuya desaparición se ha confirmado."
    t.string "ejemplarfosil", limit: 2, default: "", null: false, comment: "Indica si el ejemplar es fósil."
    t.text "nombrecomun", null: false, comment: "Nombre común reconocido para el taxón en los catálogos de autoridades taxonómicas de la CONABIO."
    t.string "categoriaresidenciaaves", limit: 100, default: "", null: false, comment: "Indica el tipo de residencia de las aves respecto al sitio y a la temporada del año en la que fue colectado, observado o reportado el ejemplar."
    t.string "prioritaria", limit: 100, default: "", null: false, comment: "Especies utilizadas para representar a otras especies o aspectos significativos del ambiente para conseguir un objetivo determinado de conservación."
    t.string "nivelprioridad", limit: 5, default: "", null: false, comment: "Nivel de prioridad asignado a la especie para su protección y conservación."
    t.string "exoticainvasora", limit: 20, default: "", null: false, comment: "Indica si una especie está catalogada como exótica, exótica invasora o criptogénica para México."
    t.string "nom059", limit: 512, default: "", null: false, comment: "Indica la categoría de riesgo conforme a la NOM-059-SEMARNAT de la especie o la categoría infraespecífica."
    t.string "cites", limit: 512, default: "", null: false, comment: "Indica el grado de protección contra el comercio ilegal conforme a la Convención sobre el Comercio Internacional de Especies Amenazadas de Fauna y Flora Silvestres."
    t.string "iucn", limit: 1024, default: "", null: false, comment: "Indica el estado de conservación de la especie conforme a la lista roja de la Unión Internacional para la Conservación de la Naturaleza (IUCN)."
    t.string "coleccion", limit: 150, default: "", null: false, comment: "Siglas y nombre de la colección que resguarda al ejemplar."
    t.string "institucion", default: "", null: false, comment: "Siglas y nombre de la institución que custodia la colección científica, o que avala el registro de un ejemplar."
    t.string "paiscoleccion", limit: 50, default: "", null: false, comment: "País donde se localiza la colección o la institución que resguarda el registro observado o reportado."
    t.string "numcatalogo", limit: 100, default: "", null: false, comment: "Identificador único del ejemplar en la colección biológica, se le asigna cuando se incorpora a esta."
    t.string "numcolecta", limit: 100, default: "", null: false, comment: "Identificador asignado por el recolector u observador para cada evento de recolecta u observación."
    t.string "procedenciaejemplar", limit: 20, default: "", null: false, comment: "Indica si el ejemplar proviene de un evento de recolecta, observación o de un reporte."
    t.string "determinador", limit: 512, default: "", null: false, comment: "Nombre o abreviado de la persona que realizó la determinación del ejemplar."
    t.string "fechadeterminacion", limit: 10, default: "", null: false, comment: "Es la fecha en la que se realizó la determinación del ejemplar."
    t.integer "diadeterminacion", limit: 1, comment: "Día en que se realizó la determinación del ejemplar."
    t.integer "mesdeterminacion", limit: 1, comment: "Mes en que se realizó la determinación del ejemplar."
    t.integer "aniodeterminacion", limit: 2, comment: "Año en que se realizó la determinación del ejemplar."
    t.string "colector", limit: 512, default: "", null: false, comment: "Nombre o abreviado de la persona o grupo que participó en la recolecta u observación del ejemplar."
    t.string "fechacolecta", limit: 10, default: "", null: false, comment: "Es la fecha del evento de recolecta u observación del ejemplar."
    t.integer "diacolecta", limit: 1, comment: "Día del evento de recolecta u observación del ejemplar."
    t.integer "mescolecta", limit: 1, comment: "Mes del evento de recolecta u observación del ejemplar."
    t.integer "aniocolecta", limit: 2, comment: "Año del evento de recolecta u observación del ejemplar."
    t.string "tipo", limit: 60, default: "", null: false, comment: "Tipo nomenclatural del ejemplar."
    t.string "obsusoinfo", limit: 512, default: "", null: false, comment: "Inconsistencias detectadas en los datos o información complementaria para el uso de los datos."
    t.string "probablelocnodecampo", limit: 2, default: "", null: false, comment: "Campo marcado para ejemplares recolectados en probables hábitats no naturales."
    t.string "zonamapa", limit: 150, default: "", null: false, comment: "Nombre de la zona geográfica y/o tipo de rasgo geográfico donde se ubica la coordenada geográfica."
    t.integer "paiscodvalidacion", limit: 1, comment: "Código correspondiente al estatus de validación geográfica a nivel de país."
    t.integer "edocodvalidacion", limit: 1, comment: "Código correspondiente al estatus de la validación geográfica a nivel de estado."
    t.integer "mpiocodvalidacion", limit: 1, comment: "Código correspondiente al estatus de la validación geográfica a nivel de municipio."
    t.integer "localidadcodvalidacion", limit: 1, comment: "Código correspondiente al estatus de la validación geográfica a nivel de localidad."
    t.string "cuarentena", default: "", null: false, comment: "Comentario resultante de una revisión realizada por la CONABIO que indica si el registro cuenta con alguna inconsistencia de información."
    t.string "proyecto", limit: 50, default: "", null: false, comment: "Referencia que identifica al proyecto."
    t.string "clavebasedatos", limit: 150, default: "", null: false, comment: "Referencia que identifica la versión final de la base de datos que se integra al SNIB."
    t.string "identificacionarchivo", limit: 60, default: "", null: false, comment: "Identifica las diferentes bases de datos finales de un mismo proyecto."
    t.string "fuenteoriginal", limit: 50, default: "", null: false, comment: "Indica la fuente original de información del ejemplar incorporado a una nueva base de datos en el SNIB."
    t.string "urlejemplar", default: "", null: false, comment: "Dirección de internet que permite consultar la información del ejemplar proporcionada en las bases de datos originales y la estandarizada por la CONABIO de tipo curatorial, taxonómica y geográfica."
    t.string "urlorigen", default: "", null: false, comment: "Dirección de internet desde la cual originalmente se descargó la información del ejemplar en las páginas de GBIF o Naturalista."
    t.string "licenciauso", default: "", null: false, comment: "Licencia de uso de la información del ejemplar."
    t.string "tiporestriccion", limit: 150, default: "", null: false, comment: "Descripción de la restricción de uso de la información."
    t.string "comentarioscat", limit: 1024, default: "", null: false, comment: "Indica detalle de la validación del nombre en el catalogo de nombres de la CONABIO."
    t.string "comentarioscatvalido", limit: 1024, default: "", null: false, comment: "Indica detalle de la validación del nombre válido en el catalogo de nombres de la CONABIO."
    t.string "homonimosgenero", limit: 512, default: "", null: false, comment: "Indica los homónimos a nivel género del nombre válidado con los catálogos de autoridades taxonómicas de la CONABIO."
    t.string "homonimosespecie", default: "", null: false, comment: "Indica los homónimos a nivel especie del nombre válidado con los catálogos de autoridades taxonómicas de la CONABIO."
    t.string "homonimosinfraespecie", default: "", null: false, comment: "Indica los homónimos a nivel infraespecie del nombre válidado con los catálogos de autoridades taxonómicas de la CONABIO."
    t.string "homonimosgenerocatvalido", default: "", null: false, comment: "Indica los homónimos a nivel género del taxón válido en el que se ubica el ejemplar."
    t.string "homonimosespeciecatvalido", default: "", null: false, comment: "Indica los homónimos a nivel especie del taxón válido en el que se ubica el ejemplar."
    t.string "homonimosinfraespeciecatvalido", default: "", null: false, comment: "Indica los homónimos a nivel infraespecie del taxón válido en el que se ubica el ejemplar."
    t.string "distribucionnom2010", limit: 11, default: "", null: false, comment: "Distribución del taxón reportada por la NOM-059-SEMARNAT."
    t.string "idmias", limit: 32, default: "", null: false, comment: "Llave para agrupar los campos latitud, longitud, nombrepaismapa, nombreestadomapa y nombremunicipiomapa."
    t.string "regionmarinamapa", limit: 100, default: "", null: false, comment: "Área geográfica donde se ubica la coordenada geográfica."
    t.string "nombrerasgogeograficomapa", limit: 100, default: "", null: false, comment: "Nombre del rasgo geográfico donde se ubica la coordenada geográfica."
    t.string "tiporasgogeograficomapa", limit: 50, default: "", null: false, comment: "Tipo de rasgo geográfico donde se ubica la coordenada geográfica."
    t.string "mt24mapa", limit: 100, default: "", null: false, comment: "Nombre del estado costero asignado como referencia de ubicación del mar territorial y zona contigua 24 mi náuticas."
    t.string "noaplicavegetacionmapa", limit: 50, default: "", null: false, comment: "Información que no corresponde a descripciones de vegetación donde se ubica la coordenada geográfica."
    t.integer "distmpio", comment: "Indica la distancia que existe entre la ubicación de la coordenada y el municipio asociado al ejemplar."
    t.integer "codificacion", limit: 2, comment: "Código que indica el resultado de la validación a nivel país, estado, municipio y localidad."
    t.string "procesovalidacion", limit: 70, default: "", null: false, comment: "Clave referente al proceso y resultado de la validación geográfica a nivel de país, estado, municipio y localidad."
    t.string "estadoregistro", default: "", null: false, comment: "Indica si el ejemplar tiene el estatus de eliminado o en proceso de integración."
    t.string "fuente", limit: 50, default: "", null: false, comment: "Indica la fuente original de información del ejemplar incorporado a una nueva base de datos (campo proyecto) en el SNIB."
    t.text "formadecitar", null: false, comment: "Forma de citar los datos al hacer uso de estos o parte de los mismos."
    t.string "urlproyecto", default: "", null: false, comment: "Dirección de internet en la cual se puede consultar la información del proyecto."
    t.string "categoriataxonomica", limit: 50, default: "", null: false, comment: "Ultima categoría a la que llega el registro"
    t.boolean "geoportal", comment: "Indica si la información del ejemplar esta publicada en el geoportal."
    t.date "ultimafechaactualizacion", comment: "Fecha de última actualización de los datos."
    t.string "version", limit: 7, default: "", null: false, comment: "Versión que corresponde a las decisiones de los procesos de revisión aplicados a los datos en la CONABIO, así como, la información de referencia (mapas, catálogos, etc.) que se utiliza para realizar dicha revisión al integrar al SNIB. Cada vez que se cambien estás decisiones afectando la revisión de los datos, se cambiará la versión y se publicará el documento que describe los nuevos procesos y referencias correspondientes a la versión citada en este campo."
    t.string "paisoriginal", limit: 50, default: "", null: false, comment: "Nombre del país en el que el ejemplar fue recolectado u observado."
    t.string "estadooriginal", limit: 55, default: "", null: false, comment: "Nombre del estado o división política equivalente en la que el ejemplar fue recolectado u observado."
    t.string "municipiooriginal", limit: 80, default: "", null: false, comment: "Nombre del municipio en el que el ejemplar fue recolectado u observado."
    t.string "llavecontrolcambios", limit: 32, default: "", null: false
    t.integer "the_geom"
  end

  create_table "usuarios", id: :integer, force: :cascade, options: "ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=1" do |t|
    t.string "nombre", null: false
    t.string "apellido", null: false
    t.string "institucion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "locale", default: "es", null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "observaciones"
  end

  create_table "usuarios_especie", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "usuario_id"
    t.integer "especie_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "usuarios_roles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "usuario_id"
    t.integer "rol_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
