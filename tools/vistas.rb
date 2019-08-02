require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Crea las vistas necesarias para la consulta desde Rails y crea las tablas
que son una copia de las vistas para una rapida consulta

*** Este script puede usarse tanto para crear las vistas como para borrarlas.


Usage:

  rails r tools/vistas.rb -d         #por default crea las vistas Y volcado
  rails r tools/vistas.rb -d drop    #para borrar las vistas Y volcado

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

queriesVistas =
    {
        'bibliografias' => '',
        'catalogos' => '',
        'categorias_taxonomicas' => '',
        'especies' => '',
        'especies_bibliografias' => '',
        'especies_catalogos' => '',
        'especies_estatuses' => '',
        'especies_estatuses_bibliografias' => '',
        'especies_regiones' => '',
        'estatuses' => '',
        'nombres_comunes' => '',
        'nombres_regiones' => '',
        'nombres_regiones_bibliografias' => '',
        'regiones' => '',
        'tipos_distribuciones' => '',
        'tipos_regiones' => '',
    }


def camTab
  camposTablas = {
      'bibliografias' => ["#{@id}+IdBibliografia as id",
                          "Observaciones as observaciones",
                          "Autor as autor",
                          "Anio as anio",
                          "TituloPublicacion as titulo_publicacion",
                          "TituloSubPublicacion as titulo_sub_publicacion",
                          "EditorialPaisPagina as editorial_pais_pagina",
                          "NumeroVolumenAnio as numero_volumen_anio",
                          "EditoresCompiladores as editores_compiladores",
                          "ISBNISSN as isbnissn",
                          "CitaCompleta as cita_completa",
                          "OrdenCitaCompleta as orden_cita_completa",
                          "FechaCaptura as created_at",
                          "FechaModificacion  as updated_at"
      ],
      'catalogos' => ["#{@id}+IdCatNombre as id",
                      "Descripcion as descripcion",
                      "Nivel1 as nivel1",
                      "Nivel2 as nivel2",
                      "Nivel3 as nivel3",
                      "Nivel4 as nivel4",
                      "Nivel5 as nivel5",
                      "FechaCaptura as created_at",
                      "FechaModificacion as updated_at"
      ],
      'categorias_taxonomicas' => ["#{@id}+IdCategoriaTaxonomica as id",
                                   "NombreCategoriaTaxonomica as nombre_categoria_taxonomica",
                                   "IdNivel1 as nivel1",
                                   "IdNivel2 as nivel2",
                                   "IdNivel3 as nivel3",
                                   "IdNivel4 as nivel4",
                                   "RutaIcono as ruta_icono",
                                   "FechaCaptura as created_at",
                                   "FechaModificacion as updated_at"
      ],
      'especies' => ["#{@id}+IdNombre as id",
                     "Nombre as nombre",
                     "Estatus as estatus",
                     "Fuente as fuente",
                     "NombreAutoridad as nombre_autoridad",
                     "NumeroFilogenetico as numero_filogenetico",
                     "CitaNomenclatural as cita_nomenclatural",
                     "SistClasCatDicc as sis_clas_cat_dicc",
                     "Anotacion as anotacion",
                     "FechaCaptura as created_at",
                     "FechaModificacion as updated_at",
                     "#{@id}+IdNombreAscendente as id_nombre_ascendente",
                     "#{@id}+IdAscendObligatorio as id_ascend_obligatorio",
                     "#{@id}+IdCategoriaTaxonomica as categoria_taxonomica_id",
                     "dbo.fnSplitString(ancestry_ascendente_directo, '/', #{@id}) AS ancestry_ascendente_directo",
                     "dbo.fnSplitString(ancestry_ascendente_directo, '/', #{@id}) AS ancestry_ascendente_obligatorio",
                     "IdCAT as catalogo_id",
                     "nombre_cientifico"
      ],
      'especies_bibliografias' => ["#{@id}+IdNombre as especie_id",
                                   "#{@id}+IdBibliografia as bibliografia_id",
                                   "Observaciones as observaciones",
                                   "FechaCaptura as created_at",
                                   "FechaModificacion as updated_at"
      ],
      'especies_catalogos' => ["#{@id}+IdNombre as especie_id",
                               "#{@id}+IdCatNombre as catalogo_id",
                               "Observaciones as observaciones",
                               "FechaCaptura as created_at",
                               "FechaModificacion as updated_at"
      ],
      'especies_estatuses' => ["#{@id}+IdNombre as especie_id1",
                               "#{@id}+IdNombreRel as especie_id2",
                               "IdTipoRelacion as estatus_id",
                               "Observaciones as observaciones",
                               "FechaCaptura as created_at",
                               "FechaModificacion as updated_at"
      ],
      'especies_estatuses_bibliografias' => ["#{@id}+IdNombre as especie_id1",
                                             "#{@id}+IdNombreRel as especie_id2",
                                             "IdTipoRelacion as estatus_id",
                                             "#{@id}+IdBibliografia as bibliografia_id",
                                             "Observaciones as observaciones",
                                             "FechaCaptura as created_at",
                                             "FechaModificacion as updated_at"
      ],
      'especies_regiones' => ["#{@id}+IdNombre as especie_id",
                              "#{@id}+IdRegion as region_id",
                              "#{@id}+IdTipoDistribucion as tipo_distribucion_id",
                              "Observaciones as observaciones",
                              "FechaCaptura as created_at",
                              "FechaModificacion as updated_at"
      ],
      'estatuses' => ["#{@id}+IdTipoRelacion as id",
                      "Descripcion as descripcion",
                      "Nivel1 as nivel1",
                      "Nivel2 as nivel2",
                      "Nivel3 as nivel3",
                      "Nivel4 as nivel4",
                      "Nivel5 as nivel5",
                      "RutaIcono as ruta_icono",
                      "FechaCaptura as created_at",
                      "FechaModificacion as updated_at"
      ],
      'nombres_comunes' => ["#{@id}+IdNomcomun as id",
                            "NomComun as nombre_comun",
                            "Observaciones as observaciones",
                            "Lengua as lengua",
                            "FechaCaptura as created_at",
                            "FechaModificacion as updated_at"
      ],
      'nombres_regiones' => ["#{@id}+IdNomComun as nombre_comun_id",
                             "#{@id}+IdNombre as especie_id",
                             "#{@id}+IdRegion as region_id",
                             "Observaciones as observaciones",
                             "FechaCaptura as created_at",
                             "FechaModificacion as updated_at"
      ],
      'nombres_regiones_bibliografias' => ["#{@id}+IdNomcomun as nombre_comun_id",
                                           "#{@id}+IdNombre as especie_id",
                                           "#{@id}+IdRegion as region_id",
                                           "#{@id}+IdBibliografia as bibliografia_id",
                                           "Observaciones as observaciones",
                                           "FechaCaptura as created_at",
                                           "FechaModificacion as updated_at"
      ],
      'regiones' => ["#{@id}+IdRegion as id",
                     "NombreRegion as nombre_region",
                     "#{@id}+IdTipoRegion as tipo_region_id",
                     "ClaveRegion as clave_region",
                     "IdRegionAsc as id_region_asc",
                     "dbo.fnSplitString(ancestry, '/', #{@id}) AS ancestry",
                     "FechaCaptura as created_at",
                     "FechaModificacion as updated_at"
      ],
      'tipos_distribuciones' => ["#{@id}+IdTipoDistribucion as id",
                                 "Descripcion as descripcion",
                                 "FechaCaptura as created_at",
                                 "FechaModificacion as updated_at"
      ],
      'tipos_regiones' => ["#{@id}+IdTipoRegion as id",
                           "Descripcion as descripcion",
                           "Nivel1 as nivel1",
                           "Nivel2 as nivel2",
                           "Nivel3 as nivel3",
                           "Nivel4 as nivel4",
                           "Nivel5 as nivel5",
                           "FechaCaptura as created_at",
                           "FechaModificacion as updated_at"
      ],
  }
end

def pone_index_pk
  index_pk = []

  index_pk << 'ALTER TABLE especies ALTER COLUMN id INT NOT NULL'
  index_pk << 'ALTER TABLE especies ADD CONSTRAINT pk_id_especies PRIMARY KEY CLUSTERED(id)'
  index_pk << 'CREATE NONCLUSTERED INDEX index_ancestry_ascendente_directo_especies ON especies(ancestry_ascendente_directo)'
  index_pk << 'CREATE NONCLUSTERED INDEX index_nombre_cientifico_especies ON especies(nombre_cientifico)'
  index_pk << 'CREATE NONCLUSTERED INDEX index_categoria_taxonomica_id_especies ON especies(categoria_taxonomica_id)'

  index_pk << 'ALTER TABLE categorias_taxonomicas ALTER COLUMN id INT NOT NULL'
  index_pk << 'ALTER TABLE categorias_taxonomicas ADD CONSTRAINT pk_id_categorias_taxonomicas PRIMARY KEY CLUSTERED(id)'
  index_pk << 'CREATE NONCLUSTERED INDEX index_nombre_categoria_taxonomica_categorias_taxonomicas ON categorias_taxonomicas(nombre_categoria_taxonomica)'

  index_pk << 'ALTER TABLE catalogos ALTER COLUMN id INT NOT NULL'
  index_pk << 'ALTER TABLE catalogos ADD CONSTRAINT pk_id_catalogos PRIMARY KEY CLUSTERED(id)'
  index_pk << 'CREATE NONCLUSTERED INDEX index_descripcion_catalogos ON catalogos(descripcion)'

  index_pk << 'ALTER TABLE tipos_distribuciones ALTER COLUMN id INT NOT NULL'
  index_pk << 'ALTER TABLE tipos_distribuciones ADD CONSTRAINT pk_id_tipos_distribuciones PRIMARY KEY CLUSTERED(id)'
  index_pk << 'CREATE NONCLUSTERED INDEX index_descripcion_tipos_distribuciones ON tipos_distribuciones(descripcion)'

  index_pk << 'ALTER TABLE regiones ALTER COLUMN id INT NOT NULL'
  index_pk << 'ALTER TABLE regiones ADD CONSTRAINT pk_id_regiones PRIMARY KEY CLUSTERED(id)'
  index_pk << 'CREATE NONCLUSTERED INDEX index_nombre_region_tipos_regiones ON regiones(nombre_region)'
  index_pk << 'CREATE NONCLUSTERED INDEX index_tipo_region_id_tipos_regiones ON regiones(tipo_region_id)'
  index_pk << 'CREATE NONCLUSTERED INDEX index_ancestry_tipos_regiones ON regiones(ancestry)'

  index_pk << 'ALTER TABLE tipos_regiones ALTER COLUMN id INT NOT NULL'
  index_pk << 'ALTER TABLE tipos_regiones ADD CONSTRAINT pk_id_tipos_regiones PRIMARY KEY CLUSTERED(id)'
  index_pk << 'CREATE NONCLUSTERED INDEX index_descripcion_tipos_regiones ON tipos_regiones(descripcion)'

  index_pk << 'ALTER TABLE bibliografias ALTER COLUMN id INT NOT NULL'
  index_pk << 'ALTER TABLE bibliografias ADD CONSTRAINT pk_id_bibliografias PRIMARY KEY CLUSTERED(id)'

  index_pk << 'ALTER TABLE nombres_comunes ALTER COLUMN id INT NOT NULL'
  index_pk << 'ALTER TABLE nombres_comunes ADD CONSTRAINT pk_id_nombres_comunes PRIMARY KEY CLUSTERED(id)'
  index_pk << 'CREATE NONCLUSTERED INDEX index_nombre_comun_nombres_comunes ON nombres_comunes(nombre_comun)'

  index_pk << 'ALTER TABLE estatuses ALTER COLUMN id INT NOT NULL'
  index_pk << 'ALTER TABLE estatuses ADD CONSTRAINT pk_id_estatuses PRIMARY KEY CLUSTERED(id)'
  index_pk << 'CREATE NONCLUSTERED INDEX index_descripcion_estatuses ON estatuses(descripcion)'

  index_pk << 'ALTER TABLE especies_regiones ALTER COLUMN especie_id INT NOT NULL'
  index_pk << 'ALTER TABLE especies_regiones ALTER COLUMN region_id INT NOT NULL'
  index_pk << 'ALTER TABLE especies_regiones ADD CONSTRAINT pk_especie_id_region_id_especies_regiones PRIMARY KEY CLUSTERED(especie_id, region_id)'
  index_pk << 'CREATE NONCLUSTERED INDEX index_tipo_distribucion_id_especies_regiones ON especies_regiones(tipo_distribucion_id)'

  index_pk << 'ALTER TABLE nombres_regiones ALTER COLUMN especie_id INT NOT NULL'
  index_pk << 'ALTER TABLE nombres_regiones ALTER COLUMN nombre_comun_id INT NOT NULL'
  index_pk << 'ALTER TABLE nombres_regiones ALTER COLUMN region_id INT NOT NULL'
  index_pk << 'ALTER TABLE nombres_regiones ADD CONSTRAINT pk_especie_id_nombre_comun_id_region_id_nombres_regiones PRIMARY KEY CLUSTERED(especie_id, nombre_comun_id, region_id)'

  index_pk << 'ALTER TABLE nombres_regiones_bibliografias ALTER COLUMN especie_id INT NOT NULL'
  index_pk << 'ALTER TABLE nombres_regiones_bibliografias ALTER COLUMN nombre_comun_id INT NOT NULL'
  index_pk << 'ALTER TABLE nombres_regiones_bibliografias ALTER COLUMN region_id INT NOT NULL'
  index_pk << 'ALTER TABLE nombres_regiones_bibliografias ALTER COLUMN bibliografia_id INT NOT NULL'
  index_pk << 'ALTER TABLE nombres_regiones_bibliografias ADD CONSTRAINT pk_especie_id_nombre_comun_id_region_id_bibliografia_id_nombres_regiones_bibliografias PRIMARY KEY CLUSTERED(especie_id, nombre_comun_id, region_id, bibliografia_id)'

  index_pk << 'ALTER TABLE especies_bibliografias ALTER COLUMN especie_id INT NOT NULL'
  index_pk << 'ALTER TABLE especies_bibliografias ALTER COLUMN bibliografia_id INT NOT NULL'
  index_pk << 'ALTER TABLE especies_bibliografias ADD CONSTRAINT pk_especie_id_bibliografia_id_especies_bibliografias PRIMARY KEY CLUSTERED(especie_id, bibliografia_id)'

  index_pk << 'ALTER TABLE especies_catalogos ALTER COLUMN especie_id INT NOT NULL'
  index_pk << 'ALTER TABLE especies_catalogos ALTER COLUMN catalogo_id INT NOT NULL'
  index_pk << 'ALTER TABLE especies_catalogos ADD CONSTRAINT pk_especie_id_catalogo_id_especies_catalogos PRIMARY KEY CLUSTERED(especie_id, catalogo_id)'

  index_pk << 'ALTER TABLE especies_estatuses ALTER COLUMN especie_id1 INT NOT NULL'
  index_pk << 'ALTER TABLE especies_estatuses ALTER COLUMN especie_id2 INT NOT NULL'
  index_pk << 'ALTER TABLE especies_estatuses ALTER COLUMN estatus_id INT NOT NULL'
  index_pk << 'ALTER TABLE especies_estatuses ADD CONSTRAINT pk_especie_id1_especie_id2_estatus_id_especies_estatuses PRIMARY KEY CLUSTERED(especie_id1, especie_id2, estatus_id)'

  index_pk
end


start_time = Time.now

@id = ''
Rails.logger.debug ARGV.any? { |e| e.downcase.include?('drop') } ? 'Ejecutando con argumento: DROP' : 'Ejecutando con argumento: CREATE (default)' if OPTS[:debug]

# Arma las vistas
CONFIG.bases.each do |base|
  numero_base = base.split('-').first.to_i  # obtiene el numero de base de acuerdo al nombre de la misma
  @id = numero_base*1000000  # obtiene el numero a aumentarse de la base con millones

  camTab.each {|tabla, campos|
    if ARGV.any? { |e| e.downcase.include?('drop') }
      queriesVistas[tabla] = CONFIG.bases.index(base) == 0 ? "DROP VIEW #{tabla}_0" : " \n" + queriesVistas[tabla]+"\n"
    else
      queriesVistas[tabla] = CONFIG.bases.index(base) == 0 ? "CREATE VIEW #{tabla}_0\nAS\n" : queriesVistas[tabla]+" UNION \n"
      queriesVistas[tabla]+= 'SELECT ' + campos.join(', ') +" FROM [#{base}].dbo.#{Bases::EQUIVALENCIA[tabla]}"
    end
  }
end

# Genera las vistas y el volcado
queriesVistas.each do |key,value|
  Rails.logger.debug "Query: #{value}" if OPTS[:debug]
  Bases.ejecuta value

  query = ''
  if ARGV.any? { |e| e.downcase.include?('drop') }
    query+= "DROP TABLE #{key}"
  else
    query+= "SELECT * INTO #{key} FROM #{key}_0"
  end

  Bases.ejecuta query   #para las tablas del volcado
  Rails.logger.debug "Query: #{query}" if OPTS[:debug]
end

# Para agregar los nonclustered index, quitar los NULL de las pk y agregar pk
pone_index_pk.each do |query|
  Rails.logger.debug "Query: #{query}" if OPTS[:debug]
  Bases.ejecuta query
end

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]