# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160615172900) do

  create_table "adicionales", force: true do |t|
    t.integer  "especie_id",             null: false
    t.string   "nombre_comun_principal"
    t.text     "justificacion_nombre"
    t.string   "foto_principal"
    t.text     "justificacion_foto"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "icono_id"
    t.text     "fotos_principales"
  end

  create_table "bibliografias", force: true do |t|
    t.text     "observaciones"
    t.string   "autor",                             null: false
    t.string   "anio",                   limit: 50, null: false
    t.string   "titulo_publicacion",                null: false
    t.string   "titulo_sub_publicacion"
    t.string   "editorial_pais_pagina"
    t.string   "numero_volumen_anio"
    t.string   "editores_compiladores"
    t.string   "isbnissn",               limit: 50
    t.text     "cita_completa"
    t.string   "orden_cita_completa",    limit: 15
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "bitacoras", force: true do |t|
    t.text     "descripcion"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "usuario_id",  null: false
  end

  create_table "catalogos", force: true do |t|
    t.string   "descripcion",           null: false
    t.integer  "nivel1",      limit: 2, null: false
    t.integer  "nivel2",      limit: 2, null: false
    t.integer  "nivel3",      limit: 2, null: false
    t.integer  "nivel4",      limit: 2, null: false
    t.integer  "nivel5",      limit: 2, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "catalogos", ["descripcion"], name: "index_descripcion_catalogos"

  create_table "categorias_comentario", force: true do |t|
    t.string   "nombre",     null: false
    t.string   "ancestry"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categorias_conteo", force: true do |t|
    t.integer  "especie_id",           null: false
    t.integer  "conteo",               null: false
    t.string   "categoria",  limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categorias_taxonomicas", force: true do |t|
    t.string   "nombre_categoria_taxonomica", limit: 15, null: false
    t.integer  "nivel1",                      limit: 1,  null: false
    t.integer  "nivel2",                      limit: 1,  null: false
    t.integer  "nivel3",                      limit: 1,  null: false
    t.integer  "nivel4",                      limit: 1,  null: false
    t.string   "ruta_icono"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "categorias_taxonomicas", ["nombre_categoria_taxonomica"], name: "index_nombre_categoria_taxonomica_categorias_taxonomicas"

  create_table "comentarios", force: true do |t|
    t.text     "comentario",                             null: false
    t.string   "correo"
    t.string   "nombre"
    t.integer  "especie_id",                             null: false
    t.integer  "usuario_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "estatus",                 default: 0,    null: false
    t.string   "ancestry"
    t.datetime "fecha_estatus"
    t.integer  "usuario_id2"
    t.string   "categoria_comentario_id", default: "26", null: false
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "especies", force: true do |t|
    t.string   "nombre",                          limit: 100, null: false
    t.integer  "estatus",                         limit: 2,   null: false
    t.string   "fuente",                          limit: 30,  null: false
    t.string   "nombre_autoridad",                            null: false
    t.string   "numero_filogenetico",             limit: 50
    t.string   "cita_nomenclatural"
    t.string   "sis_clas_cat_dicc",                           null: false
    t.string   "anotacion"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "id_nombre_ascendente"
    t.integer  "id_ascend_obligatorio"
    t.integer  "categoria_taxonomica_id"
    t.string   "ancestry_ascendente_directo"
    t.string   "ancestry_ascendente_obligatorio"
    t.string   "catalogo_id",                     limit: 20
    t.string   "nombre_cientifico"
  end

  add_index "especies", ["ancestry_ascendente_directo"], name: "index_ancestry_ascendente_directo_especies"
  add_index "especies", ["categoria_taxonomica_id"], name: "index_categoria_taxonomica_id_especies"
  add_index "especies", ["nombre_cientifico"], name: "index_nombre_cientifico_especies"

  create_table "especies_bibliografias", primary_key: "especie_id", force: true do |t|
    t.integer  "bibliografia_id", null: false
    t.string   "observaciones"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "especies_catalogos", primary_key: "especie_id", force: true do |t|
    t.integer  "catalogo_id",   null: false
    t.text     "observaciones"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "especies_estatuses", primary_key: "especie_id1", force: true do |t|
    t.integer  "especie_id2",   null: false
    t.integer  "estatus_id",    null: false
    t.string   "observaciones"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "especies_estatuses_bibliografias", id: false, force: true do |t|
    t.integer  "especie_id1"
    t.integer  "especie_id2"
    t.integer  "estatus_id",      null: false
    t.integer  "bibliografia_id"
    t.string   "observaciones"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "especies_regiones", primary_key: "especie_id", force: true do |t|
    t.integer  "region_id",            null: false
    t.integer  "tipo_distribucion_id"
    t.text     "observaciones"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "especies_regiones", ["tipo_distribucion_id"], name: "index_tipo_distribucion_id_especies_regiones"

  create_table "estatuses", force: true do |t|
    t.string   "descripcion", limit: 55, null: false
    t.integer  "nivel1",      limit: 2,  null: false
    t.integer  "nivel2",      limit: 2,  null: false
    t.integer  "nivel3",      limit: 2,  null: false
    t.integer  "nivel4",      limit: 2,  null: false
    t.integer  "nivel5",      limit: 2,  null: false
    t.string   "ruta_icono"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "estatuses", ["descripcion"], name: "index_descripcion_estatuses"

  create_table "filtros", force: true do |t|
    t.text     "html"
    t.string   "sesion",     limit: 32,                null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "usuario_id"
    t.string   "locale",                default: "es", null: false
  end

  add_index "filtros", ["sesion"], name: "index_filtros_on_sesion"

  create_table "iconos", force: true do |t|
    t.string   "taxon_icono",   null: false
    t.string   "icono",         null: false
    t.string   "nombre_icono",  null: false
    t.string   "color_icono",   null: false
    t.text     "observaciones"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listas", force: true do |t|
    t.string   "nombre_lista",                          null: false
    t.text     "columnas"
    t.string   "formato"
    t.integer  "esta_activa",     limit: 2, default: 0, null: false
    t.text     "cadena_especies"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "usuario_id",                            null: false
  end

  create_table "metadato_especies", force: true do |t|
    t.integer  "especie_id",  null: false
    t.integer  "metadato_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "metadatos", force: true do |t|
    t.string   "object_name"
    t.string   "artist"
    t.string   "copyright"
    t.string   "country_name"
    t.string   "province_state"
    t.string   "transmission_reference"
    t.string   "category"
    t.string   "supp_category"
    t.string   "keywords"
    t.text     "custom_field12"
    t.string   "custom_field6"
    t.string   "custom_field7"
    t.string   "custom_field13"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "path"
    t.string   "bdi_id",                 limit: 50
  end

  create_table "nombres_comunes", force: true do |t|
    t.string   "nombre_comun",  limit: 50,  null: false
    t.string   "observaciones"
    t.string   "lengua",        limit: 100
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "nombres_comunes", ["nombre_comun"], name: "index_nombre_comun_nombres_comunes"

  create_table "nombres_regiones", primary_key: "nombre_comun_id", force: true do |t|
    t.integer  "especie_id",    null: false
    t.integer  "region_id",     null: false
    t.text     "observaciones"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "nombres_regiones_bibliografias", primary_key: "nombre_comun_id", force: true do |t|
    t.integer  "especie_id",      null: false
    t.integer  "region_id",       null: false
    t.integer  "bibliografia_id", null: false
    t.string   "observaciones"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "photos", force: true do |t|
    t.integer  "usuario_id"
    t.string   "native_photo_id"
    t.string   "square_url"
    t.string   "thumb_url"
    t.string   "small_url"
    t.string   "medium_url"
    t.string   "large_url"
    t.string   "original_url",      limit: 512
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "native_page_url"
    t.string   "native_username"
    t.string   "native_realname"
    t.integer  "license"
    t.string   "type"
    t.string   "file_content_type"
    t.string   "file_file_name"
    t.integer  "file_file_size"
    t.boolean  "file_processing"
    t.boolean  "mobile",                        default: false
    t.datetime "file_updated_at"
    t.text     "metadata"
  end

  add_index "photos", ["native_photo_id"], name: "index_flickr_photos_on_flickr_native_photo_id"
  add_index "photos", ["usuario_id"], name: "index_photos_on_user_id"

  create_table "proveedores", force: true do |t|
    t.integer  "especie_id",       null: false
    t.integer  "naturalista_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "naturalista_info"
    t.integer  "snib_id"
    t.string   "snib_reino"
    t.text     "naturalista_obs"
    t.string   "geoserver_info"
  end

  create_table "regiones", force: true do |t|
    t.string   "nombre_region",  limit: 100, null: false
    t.integer  "tipo_region_id"
    t.string   "clave_region",   limit: 35
    t.integer  "id_region_asc",              null: false
    t.string   "ancestry"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "regiones", ["ancestry"], name: "index_ancestry_tipos_regiones"
  add_index "regiones", ["nombre_region"], name: "index_nombre_region_tipos_regiones"
  add_index "regiones", ["tipo_region_id"], name: "index_tipo_region_id_tipos_regiones"

  create_table "roles", force: true do |t|
    t.string   "nombre_rol",                                 null: false
    t.text     "atributos_base"
    t.text     "tablas_adicionales"
    t.string   "permisos"
    t.text     "taxonomia_especifica"
    t.text     "usuarios_especificos"
    t.integer  "es_admin",             limit: 2, default: 0, null: false
    t.integer  "es_super_usuario",     limit: 2, default: 0, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "prioridad",                      default: 0, null: false
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "taxon_photos", force: true do |t|
    t.integer  "especie_id", null: false
    t.integer  "photo_id",   null: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taxon_photos", ["especie_id"], name: "index_taxon_photos_on_taxon_id"
  add_index "taxon_photos", ["photo_id"], name: "index_taxon_photos_on_photo_id"

  create_table "tipos_distribuciones", force: true do |t|
    t.string   "descripcion", limit: 100, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "tipos_distribuciones", ["descripcion"], name: "index_descripcion_tipos_distribuciones"

  create_table "tipos_regiones", force: true do |t|
    t.string   "descripcion",           null: false
    t.integer  "nivel1",      limit: 2, null: false
    t.integer  "nivel2",      limit: 2, null: false
    t.integer  "nivel3",      limit: 2, null: false
    t.integer  "nivel4",      limit: 2, null: false
    t.integer  "nivel5",      limit: 2, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "tipos_regiones", ["descripcion"], name: "index_descripcion_tipos_regiones"

  create_table "usuarios", force: true do |t|
    t.string   "usuario",                               null: false
    t.string   "nombre",                                null: false
    t.string   "apellido",                              null: false
    t.string   "institucion",                           null: false
    t.string   "grado_academico",                       null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "rol_id",                 default: 1,    null: false
    t.string   "locale",                 default: "es", null: false
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,    null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  create_table "validaciones", force: true do |t|
    t.integer  "usuario_id",                           null: false
    t.string   "nombre_archivo",                       null: false
    t.integer  "enviado",        limit: 2, default: 0, null: false
    t.datetime "fecha_envio"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
