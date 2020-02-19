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

ActiveRecord::Schema.define(version: 20191015004756) do

  create_table "adicionales", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "especie_id", null: false
    t.string "nombre_comun_principal"
    t.string "foto_principal", limit: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "nombres_comunes", limit: 4294967295
    t.integer "idMillon"
    t.index ["especie_id"], name: "ClusteredIndex-20160801-144106"
    t.index ["nombre_comun_principal"], name: "NonClusteredIndex-20160801-144122", length: { nombre_comun_principal: 191 }
  end

  create_table "articles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "title"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "autortaxon", primary_key: "IdAutorTaxon", id: :integer, comment: "Identificador único del autor (asignación de un número consecutivo para cada registro adicionado).", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", comment: "Catalogo de autoridades que definen a los taxones." do |t|
    t.string "NombreAutoridad", limit: 100
    t.string "NombreCompleto", collation: "utf8_general_ci", comment: "Nombre completo de la autoridad que define el taxón."
    t.string "GrupoTaxonomico", collation: "utf8_general_ci", comment: "Grupo taxonómico que estudia la autoridad."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.integer "IdOriginal"
    t.string "Catalogo"
    t.string "NombreAutoridadOriginal", limit: 100
    t.index ["NombreAutoridad", "GrupoTaxonomico"], name: "idx_NombreAutor_GrupoTax", unique: true
    t.index ["NombreAutoridad"], name: "idx_NombreAutoridad"
  end

  create_table "biblio psf eliminar", id: false, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.integer "IdBibliografia"
    t.integer "IdNombre"
    t.integer "IdCatNombre"
    t.string "Observaciones"
  end

  create_table "bibliografia", primary_key: "IdBibliografia", id: :integer, comment: "Identificador único para cada elemento de la tabla Bibliografia.", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", comment: "Catálogo de publicaciones. Libro, Tesis, Revista, Artículo, " do |t|
    t.string "Observaciones", comment: "Observaciones acerca de la publicación."
    t.string "Autor", null: false, comment: "Autor(es) de la publicación."
    t.string "Anio", limit: 50, null: false, comment: "Indica el(los) año(s) o la fecha en que fue publicada la publicación."
    t.string "TituloPublicacion", null: false, comment: "Título de la publicación."
    t.string "TituloSubPublicacion", comment: "Titulo de la subpublicación."
    t.string "EditorialPaisPagina", comment: "Entidad que llevó a cabo la edición de la publicación, país o lugar de edición de la publicación y/o páginas de la publicación o subpublicación."
    t.string "NumeroVolumenAnio", comment: "Indica el número de la publicación, el número del volumen de la publicación y/ó páginas de la publicación ó subpublicación."
    t.string "EditoresCompiladores", comment: "Editores, compiladores y/o coordinadores de la publicación."
    t.string "ISBNISSN", limit: 50, comment: "Número ISBN (International Standard Book Number) y/o número ISSN (International Standard Serial Number) de la publicación."
    t.text "CitaCompleta", limit: 4294967295, collation: "latin1_swedish_ci", comment: "Cita bibliográfica completa."
    t.string "OrdenCitaCompleta", limit: 15, comment: "Orden de los datos que forman la cita bibliográfica completa."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.integer "IdOriginal"
    t.string "Catalogo"
    t.string "AutorOriginal"
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

  create_table "catalogoecologico", primary_key: "IdCatEcologico", id: :integer, comment: "Identificador único de la característica ecológica (asignación de un número consecutivo por cada registro adicionado).", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string "Descripcion", null: false, comment: "Nombre del catálogo/elemento."
    t.integer "Nivel1", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos. Agrupa los elementos del Nivel1."
    t.integer "Nivel2", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos. Agrupa los elementos del Nivel2."
    t.integer "Nivel3", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos. Agrupa los elementos del Nivel3."
    t.integer "Nivel4", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos. Agrupa los elementos del Nivel4."
    t.integer "Nivel5", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos. Agrupa los elementos del Nivel5."
    t.integer "Nivel6", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["Nivel1", "Nivel2", "Nivel3", "Nivel4", "Nivel5", "Nivel6"], name: "idx_Nivel1__Nivel6", unique: true
  end

  create_table "catalogoejemplar", primary_key: "IdCatEjemplar", id: :integer, comment: "Identificador único para cada catálogo/elemento (asignación de un número consecutivo para cada registro adicionado).", force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string "Descripcion", null: false, comment: "Nombre del catálogo/elemento."
    t.integer "Nivel1", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos. Agrupa los elementos del Nivel1."
    t.integer "Nivel2", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos. Agrupa los elementos del Nivel2."
    t.integer "Nivel3", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos. Agrupa los elementos del Nivel3."
    t.integer "Nivel4", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["Nivel1", "Nivel2", "Nivel3", "Nivel4"], name: "idx_Nivel1___Nivel4", unique: true
  end

  create_table "catalogonombre", primary_key: "IdCatNombre", id: :integer, comment: "Identificador único para cada catálogo/elemento (asignación de un número consecutivo para cada registro adicionado).", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string "Descripcion", null: false, comment: "Nombre del catálogo/elemento."
    t.integer "Nivel1", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos. Agrupa los elementos del Nivel1."
    t.integer "Nivel2", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos. Agrupa los elementos del Nivel2."
    t.integer "Nivel3", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos. Agrupa los elementos del Nivel3."
    t.integer "Nivel4", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos. Agrupa los elementos del Nivel4."
    t.integer "Nivel5", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.integer "IdOriginal"
    t.string "Catalogo"
    t.index ["Nivel1", "Nivel2", "Nivel3", "Nivel4", "Nivel5"], name: "idx_Nivel1___Nivel5", unique: true
  end

  create_table "catalogositio", primary_key: "IdCatSitio", id: :integer, comment: "Identificador único para cada catálogo/elemento (asignación de un número consecutivo para cada registro adicionado).", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string "Descripcion", null: false, comment: "Nombre del catálogo/elemento."
    t.integer "Nivel1", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos. Agrupa los elementos del Nivel1."
    t.integer "Nivel2", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos. Agrupa los elementos del Nivel2."
    t.integer "Nivel3", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos. Agrupa los elementos del Nivel3."
    t.integer "Nivel4", limit: 2, null: false, comment: "Identificador consecutivo del catálogo. Indica niveles jerárquicos entre los elementos."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["Nivel1", "Nivel2", "Nivel3", "Nivel4"], name: "idx_Nivel1___Nivel4", unique: true
  end

  create_table "categorias_contenido", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "nombre", null: false
    t.string "ancestry"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categoriataxonomica", primary_key: "IdCategoriaTaxonomica", id: :integer, comment: "Identificador único para cada elemento de la tabla Categoría Taxonómica (asignación de un número consecutivo para cada registro adicionado).", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", comment: "Son las categorias (Nivel o rango jerarquico) que se le asig" do |t|
    t.string "NombreCategoriaTaxonomica", limit: 15, null: false, comment: "Nombre de la categoría taxonómica."
    t.integer "IdNivel1", limit: 2, null: false, comment: "Identificador consecutivo de la categoría."
    t.integer "IdNivel2", limit: 2, null: false, comment: "Indica el reino al que pertenece la categoría (0 .- división y 1.- phyllum)."
    t.integer "IdNivel3", limit: 2, null: false, comment: "Identificador consecutivo de la categoría,  el 0 indica que se esta en una categoría taxonómica obligatoria."
    t.integer "IdNivel4", limit: 2, null: false, comment: "Identificador consecutivo de la categoría."
    t.string "RutaIcono", comment: "Se guarda la ruta en donde se encuentra el ícono asociado a la categoría."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["NombreCategoriaTaxonomica", "IdNivel1", "IdNivel2", "IdNivel3", "IdNivel4"], name: "idx_NombreCategoriaTaxonomica_IdNivel1___IdNivel4", unique: true
  end

  create_table "coleccion", primary_key: "IdColeccion", id: :integer, comment: "Identificador único de la tabla Colección. (asignación de un número consecutivo para cada registro adicionado)", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", comment: "Catalogo de las colecciones donde tienen ejemplares. Catálog" do |t|
    t.integer "IdInstitucion", null: false, comment: "Identificador de la institución que alberga a la colección."
    t.string "SiglasColeccion", limit: 100, null: false, comment: "Siglas de la colección de acuerdo con estándares internacionales."
    t.string "NombreColeccion", null: false, comment: "Nombre de la colección."
    t.string "Direccion", comment: "Dirección de la colección."
    t.string "Ciudad", limit: 100, comment: "Ciudad donde se localiza la colección."
    t.string "Estado", limit: 100, null: false, comment: "Estado donde se localiza la colección."
    t.string "Pais", limit: 100, null: false, comment: "Pais donde se localiza la colección."
    t.string "CodigoPostal", limit: 5, comment: "Código Postal donde se localiza la colección."
    t.string "AreaInvestigacion", comment: "Indica el area de investigación de la colección."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.string "ColumnaAuxiliar", limit: 100
    t.index ["IdInstitucion"], name: "idx_IdInstitucion"
    t.index ["SiglasColeccion", "IdInstitucion", "NombreColeccion"], name: "idx_SiglasColeccion_IdInst_NombreColeccion", unique: true
  end

  create_table "comentarios", primary_key: "idConsecutivo", id: :integer, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
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

  create_table "comments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "commenter"
    t.text "body"
    t.integer "article_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_comments_on_article_id"
  end

  create_table "coordenada", primary_key: "IdCoordenada", id: :integer, comment: "Identificador único de la tabla Coordenada(asignación de un número consecutivo por cada registro adicionado).", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "LatitudGrados", limit: 2, null: false, comment: "Grados de la coordenada para la latitud."
    t.integer "LatitudMinutos", limit: 2, null: false, comment: "Minutos de la coordenada para la latitud."
    t.float "LatitudSegundos", limit: 53, null: false, comment: "Segundos de la coordenada para la latitud."
    t.integer "LongitudGrados", limit: 2, null: false, comment: "Grados de la coordenada para la longitud."
    t.integer "LongitudMinutos", limit: 2, null: false, comment: "Minutos de la coordenada para la longitud."
    t.float "LongitudSegundos", limit: 53, null: false, comment: "Segundos de la coordenada para la longitud."
    t.string "XOriginal", limit: 70, null: false
    t.string "YOriginal", limit: 70, null: false
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["LatitudGrados", "LatitudMinutos", "LatitudSegundos", "LongitudGrados", "LongitudMinutos", "LongitudSegundos", "XOriginal", "YOriginal"], name: "idx_Lat_Lon_XOrig_YOrig", unique: true
  end

  create_table "copiaejemplaren", primary_key: ["IdEjemplar", "IdColeccion", "NumCatalogoCopia"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", comment: "Catalogo de copias de ejemplares." do |t|
    t.integer "IdEjemplar", null: false, comment: "Identificador del ejemplar que tiene duplicado."
    t.integer "IdColeccion", null: false, comment: "Identificador de la colección donde se encuentra el duplicado del ejemplar."
    t.string "NumCatalogoCopia", limit: 25, null: false, comment: "Número de catálogo del duplicado del ejemplar en la nueva colección."
    t.string "Observaciones", comment: "Observación referente al duplicado."
    t.integer "IdTipo", comment: "Identificador del tipo del ejemplar."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["IdColeccion"], name: "fk_IdColeccion"
    t.index ["IdEjemplar"], name: "fk_IdEjemplar"
    t.index ["IdTipo"], name: "fk_IdTipo"
  end

  create_table "datocampomapa", primary_key: "IdDatoCampoMapa", id: :integer, comment: "Identificador único para cada elemento de la tabla DatoCampoMapa. (Asignación de un número consecutivo para cada registro adicionado).", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "IdReferenciaMapa", null: false, comment: "Identificador del mapa donde se encuentra el dato."
    t.string "DatoCampoMapa", limit: 200, null: false, comment: "Valor en el renglon IdDatoMapa en la columna CampoDescMapa del mapa."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["IdReferenciaMapa", "DatoCampoMapa"], name: "idx_IdrefMapa_DatoCampoMapa", unique: true
    t.index ["IdReferenciaMapa"], name: "fk_IdReferenciaMapa"
  end

  create_table "datum", primary_key: "IdDatum", id: :integer, comment: "Identificador único del datum", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "IdSpheroid", null: false, comment: "Identificador único del esferoide"
    t.string "Name", limit: 100, null: false, comment: "Nombre del datum"
    t.boolean "Usuario", default: true, null: false, comment: "Indica si el registro fue creado por el usuario =Si o por el sistema=No"
    t.integer "SigSitio", limit: 2, default: 0, comment: "Indica que modulo del sistema usa el registro: 0=usado por el sig 1=usado por sitios"
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["IdSpheroid", "SigSitio", "Name"], name: "idx_IdSpheroid_SigSitio_Name", unique: true
    t.index ["IdSpheroid"], name: "fk_IdSphereoid"
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

  create_table "determinacion", primary_key: "IdDeterminacion", id: :integer, comment: "Identificador único para cada determinación (asignación de un número consecutivo para cada registro adicionado).", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", comment: "Grupo de personas que determino un ejemplar, se guarda el hi" do |t|
    t.integer "IdNombre", null: false, comment: "Identificador del nombre científico asignado al ejemplar."
    t.integer "IdGrupo", null: false, comment: "Identificador del grupo de personas que determinó al ejemplar."
    t.integer "IdEjemplar", null: false, comment: "Identificador del ejemplar determinado."
    t.integer "DiaDeterminacion", limit: 2, null: false, comment: "Dia de la determinacion."
    t.integer "MesDeterminacion", limit: 2, null: false, comment: "Mes de la determinación."
    t.integer "AnioDeterminacion", limit: 2, null: false, comment: "Año de la determinación."
    t.boolean "Valido", default: false, null: false, comment: "Indica la validez de la determinación (Sí = valida, No = No valida). Unicamente se permite una determinación valida por ejemplar, pudiendo tener ninguna o muchas determinaciones no validas."
    t.integer "CalificacionDelDeterminador", limit: 2, comment: "Se refiere a la confiabilidad del determinador en cuanto a su experiencia: 0 - Desconocido, 1 -Taxonomo/Parataxonomo, 3 - Taxónomo especialista en el grupo, 4 - Ejemplar tipo, 5 -  No taxónomo"
    t.string "CalificadorDeterminacion", limit: 20, comment: "Se refiere a comentarios específicos relativos a la nueva determinación, como serian aff., cf., cfr."
    t.string "Nombre", limit: 200, null: false, comment: "Nombre científico asignado al ejemplar al momento de la determinación."
    t.integer "IdTipo", comment: "Identificador del tipo del ejemplar."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["IdEjemplar"], name: "fk_Idejemplar"
    t.index ["IdGrupo", "IdEjemplar", "IdNombre", "MesDeterminacion", "AnioDeterminacion"], name: "idx_IdGrupo_IdEjem_IdNombr_MesDeter_AnioDeter", unique: true
    t.index ["IdGrupo"], name: "fk_IdGrupo"
    t.index ["IdNombre"], name: "fk_IdNombre"
    t.index ["IdTipo"], name: "fk_IdTipo"
  end

  create_table "ejemplar", primary_key: "IdEjemplar", id: :integer, comment: "Identificador único para cada ejemplar (asignación de un número consecutivo para cada registro adicionado).", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", comment: "Se guardan las caracteristicas de los ejemplares colectados." do |t|
    t.integer "IdNombre", null: false, comment: "Identificador del taxón al que esta determinado el ejemplar."
    t.integer "IdColeccion", comment: "Identificador de la colección a la cual pertenece el ejemplar."
    t.integer "IdNombreLocalidad", comment: "Identificador de la localidad donde se colecto, observo, etc. el ejemplar."
    t.integer "IdSitio", comment: "Coordenada geográfica en donde se obtuvo la información del ejemplar."
    t.integer "IdColector", comment: "Identificador del grupo que hizo la colecta u observación."
    t.string "NumeroDeCatalogo", limit: 55, comment: "Número de catálogo con el que se registra el ejemplar en la colección."
    t.integer "DiaColecta", limit: 2, null: false, comment: "Día inicial de la colecta u observación del ejemplar."
    t.integer "MesColecta", limit: 2, null: false, comment: "Mes inicial de la colecta u observación del ejemplar."
    t.integer "AnioColecta", limit: 2, null: false, comment: "Año inicial de la colecta u observación del ejemplar."
    t.integer "DiaFinalColecta", limit: 2, comment: "Día final de la colecta del ejemplar."
    t.integer "MesFinalColecta", limit: 2, comment: "Mes final de la colecta del ejemplar."
    t.integer "AnioFinalColecta", limit: 2, comment: "Año final de la colecta del ejemplar."
    t.string "NumeroDeColecta", limit: 30, comment: "Número de colecta del ejemplar."
    t.string "Fuente", limit: 30, null: false, comment: "Clave de proyecto apoyado por la CONABIO o nombre del proytecto."
    t.integer "Procedencia", limit: 2, null: false, comment: "Forma en que se obtuvo la información del ejemplar (1.- colectado,2.- reportado y 3.- observado)."
    t.string "Abundancia", limit: 25, comment: "Descripción de la cantidad de inviduos de la misma especie en el lugar de la colecta (abundante, escaso, etc)."
    t.datetime "HoraEvento", comment: "Hora de colecta u observación del ejemplar."
    t.integer "IndividuosCopias", null: false, comment: "Número de Individuos (si el nombre tiene phyllum) ó número de copias (si el nombre tiene división) del ejemplar."
    t.string "TipoMaterial", limit: 30, comment: "Información del tipo de material depositado en una colección científica biológica u observado."
    t.float "AltitudProfundidad", limit: 53
    t.integer "MarcoReferencia", limit: 2
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["IdColeccion"], name: "fk_IdColeccion"
    t.index ["IdColector"], name: "fk_IdColector"
    t.index ["IdNombre"], name: "fk_IdNombre"
    t.index ["IdNombreLocalidad"], name: "fk_IdNombreLocalidad"
    t.index ["IdSitio"], name: "fk_IdSitio"
  end

  create_table "especies_estadistica", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "especie_id"
    t.integer "estadistica_id"
    t.integer "conteo", default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["especie_id"], name: "idx_especies_estadistica_especie_id"
    t.index ["estadistica_id"], name: "idx_especies_estadistica_estadistica_id"
  end

  create_table "estadisticas", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "descripcion_estadistica"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "estudio", primary_key: "IdEstudio", id: :integer, comment: "Identificador único del estudio (asignación de un número consecutivo para cada registro adicionado).", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "IdNombre", null: false, comment: "Identificador del taxón al que pertenece el estudio."
    t.integer "IdTipoEstudio", comment: "Identificador del tipo de estudio realizado."
    t.integer "DiaInicial", limit: 2, default: 99, null: false, comment: "Día inicial en que se realiza el estudio."
    t.integer "MesInicial", limit: 2, default: 99, null: false, comment: "Mes inicial en que se realiza el estudio."
    t.integer "AnioInicial", limit: 2, default: 9999, null: false, comment: "Año inicial en que se realiza el estudio."
    t.integer "DiaFinal", limit: 2, comment: "Día final en que se realiza el estudio."
    t.integer "MesFinal", limit: 2, comment: "Mes final en que se realiza el estudio."
    t.integer "AnioFinal", limit: 2, comment: "Año final en que se realiza el estudio."
    t.string "Periodo", limit: 50, comment: "Indica el periodo en el que se realizo el estudio, por ejemplo otoño del 98."
    t.string "Periodicidad", limit: 50, comment: "Indica la frecuencia con la que se realiza el mismo estudio, por ejemplo semanalmente, trimestralmente, etc."
    t.string "AvalDeterminador", limit: 200, comment: "Nombre de la persona que certifica que el nombre del taxón sobre el que se realiza el estudio es el correcto."
    t.string "NombreEstudio", null: false, comment: "Nombre del estudio."
    t.string "NombreAreaDistribucion", comment: "Nombre del área de distribución del taxón estudiado."
    t.integer "IdTipoDistribucion", comment: "Identificador del tipo de distribución (Original, Actual, etc)."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["IdNombre"], name: "fk_IdNombre"
    t.index ["IdTipoDistribucion"], name: "fk_IdTipoDistribucion"
    t.index ["IdTipoEstudio", "IdNombre"], name: "idx_IdtipoEstudio_IdNombre"
    t.index ["IdTipoEstudio"], name: "fk_IdEstudio"
  end

  create_table "estudiotaxaasociada", primary_key: ["IdEstudio", "NombreAsociado", "IdCategoriaTaxonomica"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "IdEstudio", null: false, comment: "Identificador del estudio."
    t.string "NombreAsociado", null: false, comment: "Nombre científico del taxón asociado al estudio."
    t.integer "IdCategoriaTaxonomica", null: false, comment: "Identificador de la categoría taxonómica del taxón asociado."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["IdEstudio"], name: "fk_IdEstudio"
  end

  create_table "gcs", primary_key: "IdGCS", id: :integer, comment: "Identificador único del sistema coordenado geografico", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "IdDatum", null: false, comment: "Identificador único del datum"
    t.integer "IdPrimeMeridian", null: false, comment: "Identificador único del meridiano"
    t.integer "IdUnit", null: false, comment: "Identificador único de la unidad de medida"
    t.string "Name", limit: 100, null: false, comment: "Nombre del sistema coordenado geografico"
    t.boolean "Usuario", default: true, null: false, comment: "Indica si el registro fue creado por el usuario =Si o por el sistema=No"
    t.integer "SigSitio", limit: 2, default: 0, comment: "Indica que modulo del sistema usa el registro: 0=usado por el sig 1=usado por sitios"
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["IdDatum", "IdPrimeMeridian", "IdUnit", "Name", "SigSitio"], name: "idx_IdDatum_IdPrimeMeridian_IdUnit_Name_SigSitio", unique: true
    t.index ["IdDatum"], name: "fk_IdDatum"
    t.index ["IdPrimeMeridian"], name: "fk_IdPrimeMeridian"
    t.index ["IdUnit"], name: "fk_idUnit"
  end

  create_table "grupo", primary_key: "IdGrupo", id: :integer, comment: "Identificador único del grupo (asignación de un número consecutivo para cada registro adicionado).", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", comment: "Catalogo de grupos de trabajo." do |t|
    t.string "DescripcionGpo", limit: 150, null: false, comment: "Descripción o Nombre del grupo."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["DescripcionGpo"], name: "idx_DescripcionGpo", unique: true
  end

  create_table "grupopersona", primary_key: ["IdGrupo", "IdPersona"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", comment: "Tabla donde se guardan los elementos de cada grupo." do |t|
    t.integer "IdGrupo", null: false, comment: "Identificador del grupo."
    t.integer "IdPersona", null: false, comment: "Identificador de la persona que pertenece al grupo."
    t.integer "Orden", limit: 2, null: false, comment: "Orden de importancia que la persona tiene en el grupo."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["IdGrupo"], name: "fk_IdGrupo"
    t.index ["IdPersona"], name: "fk_IdPersona"
  end

  create_table "gruposcat", primary_key: "IdGrupoSCAT", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string "GrupoSCAT", null: false, collation: "utf8_general_ci"
    t.string "GrupoAbreviado", limit: 5, collation: "utf8_general_ci"
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "GrupoSNIB"
    t.datetime "FechaModificacion"
    t.index ["GrupoSCAT"], name: "idx_GrupoSCAT"
  end

  create_table "homonimosnoencat", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string "Taxon", default: "", null: false, collation: "utf8_general_ci"
    t.string "TaxonConSubGenero", default: "", null: false, collation: "utf8_general_ci"
    t.string "UltimaCategoriaTaxonomica", limit: 80, default: "", null: false, collation: "utf8_general_ci"
    t.text "Homonimos", limit: 16777215, null: false, collation: "utf8_general_ci"
    t.string "genero", limit: 80, default: "", null: false
    t.string "subgenero", limit: 80, default: "", null: false
    t.string "especie_epiteto", limit: 80, default: "", null: false
    t.string "NombreInfra", limit: 80, default: "", null: false
    t.index ["NombreInfra"], name: "infraespecie"
    t.index ["TaxonConSubGenero"], name: "idx_TaxonConSubgenero"
    t.index ["especie_epiteto"], name: "idx_especieepiteto"
    t.index ["genero"], name: "idx_genero"
    t.index ["subgenero"], name: "idx_subgenero"
  end

  create_table "institucion", primary_key: "IdInstitucion", id: :integer, comment: "Identificador único de la tabla Institución (asignación de un número consecutivo para cada registro adicionado)", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", comment: "Catalogo de Instituciones. Catálogo de CONABIO por Susana Oc" do |t|
    t.string "SiglasInstitucion", limit: 100, null: false, comment: "Siglas de la Institución."
    t.string "NombreInstitucion", null: false, comment: "Nombre de la Institución."
    t.string "AreaInvestigacion", comment: "Indica el area de investigación de la Institución."
    t.integer "TipoInstitucion", limit: 2, comment: "Clave que indica si la institución es: 0.- ND, 1.- Centro Académico, 2.- Soc. Científica, 3.- OG, 4.- ONG"
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["NombreInstitucion", "SiglasInstitucion"], name: "idx_NombreInst_SiglasInst", unique: true
  end

  create_table "interaccion", primary_key: "IdInteraccion", id: :integer, comment: "Identificador único de la Interaccion (asignación de un número consecutivo para cada registro adicionado)", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string "InteraccionNivel1", limit: 50, null: false, comment: "Nivel1 de la interacción."
    t.string "InteraccionNivel2", limit: 50, comment: "Nivel2 de la interacción."
    t.string "RutaIcono", comment: "Ruta física donde se guarda el ícono que representa a la interacción."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["InteraccionNivel1", "InteraccionNivel2"], name: "idx_InteraccionNivel1_Nivel2", unique: true
  end

  create_table "invasoras_nocat", id: false, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.string "IDINVAS"
    t.string "GrupoSNIB"
    t.string "categoriataxonomicavalido"
    t.string "Taxon_Valido_SCAT"
    t.string "Autoridad_taxon_valido_SCAT"
    t.string "ReinoCatvalido"
    t.string "divisionphylumcatvalido"
    t.string "clasecatvalido"
    t.string "ordencatvalido"
    t.string "familiacatvalido"
    t.string "generocatvalido"
    t.string "subgenerocatvalido"
    t.string "especiecatvalido"
    t.string "categoriainfraespeciecatvalido"
    t.string "infraespeciecatvalido"
    t.string "homonimos_SCAT"
    t.string "TipoDistribucion"
    t.index ["IDINVAS"], name: "idx_IDINVAS"
  end

  create_table "investigador", primary_key: "IdInvestigador", id: :integer, comment: "Clave única para identificar a un investigador (asignación de un número consecutivo para cada registro adicionado).", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string "ApellidoPaterno", limit: 25, default: "Nulo", null: false, comment: "Apellido paterno del investigador."
    t.string "ApellidoMaterno", limit: 25, default: "Nulo", null: false, comment: "Apellido materno del investigador."
    t.string "Nombre", limit: 25, default: "Nulo", null: false, comment: "Nombre del investigador."
    t.string "AreaInvestigacion", limit: 100, default: "Nulo", null: false, comment: "Area de Investigacion del investigador."
    t.string "Institucion", limit: 100, default: "Nulo", null: false, comment: "Institucion donde labora el investigador."
    t.string "Abreviado", limit: 180, default: "Nulo", null: false, comment: "Nombre corto o abreviado del investigador."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.index ["ApellidoPaterno", "ApellidoMaterno", "Nombre", "Abreviado", "AreaInvestigacion", "Institucion"], name: "idx_ApPaterno_ApMaterno_Nombre_Abreviado_AreaInv_Institucion", unique: true
  end

  create_table "iucn_noencat", id: false, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8", comment: "Categoria IUCN 2017." do |t|
    t.integer "Id", default: 0, null: false
    t.string "GrupoSCAT"
    t.string "CategoriaTaxonomica_IUCN"
    t.string "Taxon_IUCN"
    t.string "estatus_IUCN"
    t.string "Familia_IUCN"
    t.string "Homonimosgenero"
    t.string "FamiliaCATCentralizado"
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

  create_table "mime", primary_key: "IdMime", id: :integer, comment: "Identificador del MIME (asignación de un número consecutivo para cada registro adicionado).", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string "MIME", limit: 100, null: false, comment: "Especifica el tipo de datos (texto, imágenes o audio) que contienen los archivos. P. ej. ACCESS, EXCEL. JPG, etc."
    t.string "Extension", limit: 4, comment: "Extensión del objeto (pdf, mdb, html, rtf, etc)."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.integer "IdOriginal"
    t.string "Catalogo"
  end

  create_table "nombre", primary_key: "IdNombre", id: :integer, comment: "Identificador único del taxón  (asignación de un número consecutivo para cada registro adicionado).", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", comment: "Nombre Cientifico de las especies o infraespecies." do |t|
    t.integer "IdCategoriaTaxonomica", null: false, comment: "Identificador de la categoria taxónomica que le corresponde al taxón."
    t.integer "IdNombreAscendente", null: false, comment: "Clave del nombre  asignado al taxón que corresponde con una categoría taxónomica superior (inmediata). Puede o no coincidir con el 'ascedente obligatorio' (por ejemplo, el nombre del taxón ascedente para una especie  puede ser un género o un subgénero)."
    t.integer "IdAscendObligatorio", null: false, comment: "Clave del nombre  de la categoría superior, considerado obligatorio (es decir, de las categorías: reino, phylum o división, clase, orden, familia, género o especie)."
    t.string "Nombre", limit: 100, null: false, comment: "Nombre del taxón."
    t.integer "Estatus", limit: 2, null: false, comment: "Indica si el  taxón es aceptado/valido ó si es un sinonimo, 1.- Sinonimo, 2.-aceptado/valido, -9.- No Aplica, 6.- No Disponible."
    t.string "Fuente", limit: 30, null: false, comment: "Clave de proyecto apoyado por la CONABIO o nombre del proytecto."
    t.string "NombreAutoridad", default: "nulo", null: false, comment: "Nombre del (los) autor(es) que define al taxón. Incluye el año de creación del mismo."
    t.string "NumeroFilogenetico", limit: 50, comment: "Número asignado por el autor de la clasificación para establecer relaciones de parentesco entre taxones."
    t.string "CitaNomenclatural", comment: "Cita nomenclatural."
    t.string "SistClasCatDicc", null: false, comment: "Sistema de clasificación (cronquist 1981, brummit, etc) en el que se considera y define al taxón; ó catálogo ó diccionario en el que se considera al taxón."
    t.string "Anotacion", comment: "Es una observación al taxón en latín y abreviada, por ejemplo: sin. tax., sin. nom., nom. cons., nom. dub., etc."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.integer "IdOriginal"
    t.string "Catalogo"
    t.string "IdCAT_GS003"
    t.string "Ascendentes", collation: "utf8_general_ci"
    t.string "NombreCompleto", default: ""
    t.string "AscendentesObligatorios"
    t.string "SistClasCatDiccOriginal"
    t.text "ModificadoPor"
    t.string "NombreAutoridadOriginal"
    t.integer "EstadoRegistro", limit: 1, default: 1, null: false, unsigned: true
    t.string "FuenteOriginal", limit: 45, default: ""
    t.index ["Ascendentes"], name: "idx_Ascendentes"
    t.index ["AscendentesObligatorios"], name: "idx_Ascendentesobligatorios"
    t.index ["IdAscendObligatorio"], name: "fk_IdAsendObligatorio"
    t.index ["IdCategoriaTaxonomica"], name: "fk_IdCategoriaTaxonomica"
    t.index ["IdNombreAscendente"], name: "fk_IdNombreAscendente"
    t.index ["Nombre", "IdCategoriaTaxonomica", "IdNombreAscendente", "IdAscendObligatorio", "SistClasCatDicc", "NombreAutoridad"], name: "idx_Nom_IdCatTax_IdNomAsc_IdAscendOblig_SistClas_NomAutoridad", unique: true
    t.index ["NombreCompleto"], name: "idx_NombreCompleto"
  end

  create_table "nomcomun", primary_key: "IdNomComun", id: :integer, comment: "Identificador único del nombre común (asignación de un número consecutivo para cada registro adicionado).", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", comment: "Tabla donde se guarda el catalogo de los nombres comunes de " do |t|
    t.string "NomComun", limit: 50, null: false, collation: "utf8_bin", comment: "Nombre común que recibe el taxón."
    t.string "Observaciones", collation: "utf8_bin", comment: "Observaciones referentes al nombre común."
    t.string "Lengua", limit: 100, null: false, comment: "Indica la lengua o idioma del nombre común."
    t.timestamp "FechaCaptura", default: -> { "CURRENT_TIMESTAMP" }, null: false, comment: "Fecha de captura del registro."
    t.datetime "FechaModificacion", comment: "Fecha de modificación del registro."
    t.integer "IdOriginal"
    t.string "Catalogo", collation: "utf8_bin"
    t.index ["NomComun", "Lengua"], name: "idx_NomComun_Lengua", unique: true
  end

  create_table "proveedores", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "especie_id", null: false
    t.integer "naturalista_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "geoserver_info"
    t.string "tropico_id"
  end

  create_table "relacioncentralizacion", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
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

  create_table "usuarios", id: :integer, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
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

  add_foreign_key "coleccion", "institucion", column: "IdInstitucion", primary_key: "IdInstitucion", name: "Coleccion_FK00", on_delete: :cascade
  add_foreign_key "comments", "articles"
  add_foreign_key "copiaejemplaren", "coleccion", column: "IdColeccion", primary_key: "IdColeccion", name: "CopiaEjemplarEn_FK00"
  add_foreign_key "copiaejemplaren", "ejemplar", column: "IdEjemplar", primary_key: "IdEjemplar", name: "CopiaEjemplarEn_FK01", on_delete: :cascade
  add_foreign_key "copiaejemplaren", "tipo", column: "IdTipo", primary_key: "IdTipo", name: "CopiaEjemplarEn_FK02"
  add_foreign_key "datocampomapa", "referenciamapa", column: "IdReferenciaMapa", primary_key: "IdReferenciaMapa", name: "DatoCampoMapa_FK00"
  add_foreign_key "datum", "spheroid", column: "IdSpheroid", primary_key: "IdSpheroid", name: "Datum_FK00"
  add_foreign_key "determinacion", "ejemplar", column: "IdEjemplar", primary_key: "IdEjemplar", name: "Determinacion_FK00", on_delete: :cascade
  add_foreign_key "determinacion", "grupo", column: "IdGrupo", primary_key: "IdGrupo", name: "Determinacion_FK01"
  add_foreign_key "determinacion", "nombre", column: "IdNombre", primary_key: "IdNombre", name: "Determinacion_FK02"
  add_foreign_key "determinacion", "tipo", column: "IdTipo", primary_key: "IdTipo", name: "Determinacion_FK03"
  add_foreign_key "ejemplar", "coleccion", column: "IdColeccion", primary_key: "IdColeccion", name: "Ejemplar_FK00"
  add_foreign_key "ejemplar", "grupo", column: "IdColector", primary_key: "IdGrupo", name: "Ejemplar_FK02"
  add_foreign_key "ejemplar", "nombre", column: "IdNombre", primary_key: "IdNombre", name: "Ejemplar_FK01"
  add_foreign_key "ejemplar", "nombrelocalidad", column: "IdNombreLocalidad", primary_key: "IdNombreLocalidad", name: "Ejemplar_FK04"
  add_foreign_key "ejemplar", "sitio", column: "IdSitio", primary_key: "IdSitio", name: "Ejemplar_FK03"
  add_foreign_key "estudio", "nombre", column: "IdNombre", primary_key: "IdNombre", name: "Estudio_FK01"
  add_foreign_key "estudio", "tipodistribucion", column: "IdTipoDistribucion", primary_key: "IdTipoDistribucion", name: "Estudio_FK00"
  add_foreign_key "estudio", "tipoestudio", column: "IdTipoEstudio", primary_key: "IdTipoEstudio", name: "Estudio_FK02"
  add_foreign_key "estudiotaxaasociada", "estudio", column: "IdEstudio", primary_key: "IdEstudio", name: "EstudioTaxaAsociada_FK00", on_delete: :cascade
  add_foreign_key "gcs", "datum", column: "IdDatum", primary_key: "IdDatum", name: "GCS_FK00"
  add_foreign_key "gcs", "primemeridian", column: "IdPrimeMeridian", primary_key: "IdPrimeMeridian", name: "GCS_FK01"
  add_foreign_key "gcs", "unit", column: "IdUnit", primary_key: "IdUnit", name: "GCS_FK02"
  add_foreign_key "grupopersona", "grupo", column: "IdGrupo", primary_key: "IdGrupo", name: "GrupoPersona_FK01", on_delete: :cascade
  add_foreign_key "grupopersona", "persona", column: "IdPersona", primary_key: "IdPersona", name: "GrupoPersona_FK00"
  add_foreign_key "nombre", "categoriataxonomica", column: "IdCategoriaTaxonomica", primary_key: "IdCategoriaTaxonomica", name: "CategoriaTaxonimica"
  add_foreign_key "nombre", "nombre", column: "IdAscendObligatorio", primary_key: "IdNombre", name: "Nombreascendenteobligatorio"
  add_foreign_key "nombre", "nombre", column: "IdNombreAscendente", primary_key: "IdNombre", name: "Nombreascendente", on_delete: :cascade
end
