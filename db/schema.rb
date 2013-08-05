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

ActiveRecord::Schema.define(version: 20130731020042) do

  create_table "bibliografias", force: true do |t|
    t.string   "autor",                                          null: false
    t.string   "titulo_publicacion",                             null: false
    t.decimal  "anio",                   precision: 4, scale: 0
    t.string   "titulo_sub_publicacion"
    t.string   "editorial_pais_pagina"
    t.integer  "numero_volumen_anio"
    t.string   "editores_compiladores"
    t.string   "isbnissn"
    t.text     "cita_completa",                                  null: false
    t.integer  "orden_cita_completa"
    t.text     "observaciones"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "catalogos", force: true do |t|
    t.string   "descripcion",                       null: false
    t.integer  "nivel1",      limit: 2,             null: false
    t.integer  "nivel2",      limit: 2, default: 0, null: false
    t.integer  "nivel3",      limit: 2, default: 0, null: false
    t.integer  "nivel4",      limit: 2, default: 0, null: false
    t.integer  "nivel5",      limit: 2, default: 0, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "categorias_taxonomicas", force: true do |t|
    t.string   "nombre_categoria_taxonomica",                       null: false
    t.integer  "nivel1",                      limit: 2,             null: false
    t.integer  "nivel2",                      limit: 2, default: 0, null: false
    t.integer  "nivel3",                      limit: 2, default: 0, null: false
    t.integer  "nivel4",                      limit: 2, default: 0, null: false
    t.string   "ruta_icono"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  create_table "especies", force: true do |t|
    t.string   "nombre",                                                  null: false
    t.integer  "estatus",                        limit: 2,                null: false
    t.string   "fuente",                                                  null: false
    t.string   "nombre_autoridad",                         default: "ND", null: false
    t.string   "numero_filogenetico"
    t.text     "cita_nomenclatural"
    t.string   "sis_clas_cat_dicc",                        default: "ND", null: false
    t.string   "anotacion"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "id_nombre_ascendente",                                    null: false
    t.integer  "id_ascend_obligatorio",                                   null: false
    t.integer  "categoria_taxonomica_id",                                 null: false
    t.string   "ancestry_acendente_directo"
    t.string   "ancestry_acendente_obligatorio"
  end

  add_index "especies", ["ancestry_acendente_directo"], name: "index_especies_on_ancestry_acendente_directo", using: :btree
  add_index "especies", ["ancestry_acendente_obligatorio"], name: "index_especies_on_ancestry_acendente_obligatorio", using: :btree

  create_table "especies_bibliografias", primary_key: "especie_id", force: true do |t|
    t.integer  "bibliografia_id", null: false
    t.text     "observaciones"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "especies_catalogos", primary_key: "especie_id", force: true do |t|
    t.integer  "catalogo_id",   null: false
    t.text     "observaciones"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "especies_estatuses", primary_key: "especie_id", force: true do |t|
    t.integer  "estatus_id",    null: false
    t.text     "observaciones"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "especies_estatuses_bibliografias", primary_key: "especie_id", force: true do |t|
    t.integer  "estatus_id",      null: false
    t.integer  "bibliografia_id", null: false
    t.text     "observaciones"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "especies_regiones", primary_key: "especie_id", force: true do |t|
    t.integer  "region_id",            null: false
    t.text     "observaciones"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "tipo_distribucion_id"
  end

  create_table "estatuses", force: true do |t|
    t.string   "descripcion",                       null: false
    t.integer  "nivel1",      limit: 2,             null: false
    t.integer  "nivel2",      limit: 2, default: 0, null: false
    t.integer  "nivel3",      limit: 2, default: 0, null: false
    t.integer  "nivel4",      limit: 2, default: 0, null: false
    t.integer  "nivel5",      limit: 2, default: 0, null: false
    t.string   "ruta_icono"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "listas", force: true do |t|
    t.string   "nombre_lista",                          null: false
    t.text     "columnas",                              null: false
    t.string   "formato",                               null: false
    t.integer  "esta_activa",     limit: 2, default: 0, null: false
    t.text     "cadena_especies"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "usuario_id",                            null: false
  end

  create_table "nombres_comunes", force: true do |t|
    t.string   "nombre_comun",  null: false
    t.string   "lengua",        null: false
    t.text     "observaciones"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "nombres_regiones", primary_key: "especie_id", force: true do |t|
    t.integer  "region_id",       null: false
    t.integer  "nombre_comun_id", null: false
    t.text     "observaciones"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "nombres_regiones_bibliografias", primary_key: "especie_id", force: true do |t|
    t.integer  "region_id",       null: false
    t.integer  "nombre_comun_id", null: false
    t.integer  "bibliografia_id", null: false
    t.text     "observaciones"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "regiones", force: true do |t|
    t.string   "nombre_region",  null: false
    t.string   "clave_region",   null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "tipo_region_id", null: false
    t.integer  "id_region_asc",  null: false
    t.string   "ancestry"
  end

  add_index "regiones", ["ancestry"], name: "index_regiones_on_ancestry", using: :btree

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
  end

  create_table "tipos_distribuciones", force: true do |t|
    t.string   "descripcion", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "tipos_regiones", force: true do |t|
    t.string   "descripcion",                       null: false
    t.integer  "nivel1",      limit: 2,             null: false
    t.integer  "nivel2",      limit: 2, default: 0, null: false
    t.integer  "nivel3",      limit: 2, default: 0, null: false
    t.integer  "nivel4",      limit: 2,             null: false
    t.integer  "nivel5",      limit: 2, default: 0, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "usuarios", force: true do |t|
    t.string   "usuario",         null: false
    t.string   "correo",          null: false
    t.string   "nombre",          null: false
    t.string   "apellido",        null: false
    t.string   "institucion",     null: false
    t.string   "grado_academico", null: false
    t.string   "contrasenia",     null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "rol_id",          null: false
  end

end
