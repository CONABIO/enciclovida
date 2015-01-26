#! /usr/local/bin/ruby
require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Crea las vistas necesarias para la consulta desde Rails y crea las tablas
que son una copia de las vistas para una rapida consulta

*** Este script puede usarse tanto para crear las vistas como para borrarlas.


Usage:

  rails r tools/vistas.rb -d         #por default crea las vistas
  rails r tools/vistas.rb -d drop    #para borrar las vistas

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
        #'especies_estatuses_bibliografias' => '',
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
                     "dbo.fnSplitString2(ancestry_ascendente_directo, '/', #{@id}) AS ancestry_ascendente_directo",
                     "dbo.fnSplitString2(ancestry_ascendente_directo, '/', #{@id}) AS ancestry_ascendente_obligatorio",
                     "nombre_cientifico",
                     "'' as delta",
                     "nombre_comun_principal",
                     "foto_principal",
                     "IdCAT as catalogo_id"
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
                               "#{@id}+IdTipoRelacion as estatus_id",
                               "Observaciones as observaciones",
                               "FechaCaptura as created_at",
                               "FechaModificacion as updated_at"
      ],
      #'especies_estatuses_bibliografias' => ["#{@id}+IdNombre as especie_id1",
      #                                       "IdNombreRel as estatus_id2",
      #                                       "#{@id}+IdTipoRelacion",
      #                                       "#{@id}+IdBibliografia",
      #                                       "Observaciones as observaciones",
      #                                       "FechaCaptura as created_at",
      #                                       "FechaModificacion as updated_at"
      #],
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
                     "dbo.fnSplitString2(ancestry, '/', #{@id}) AS ancestry",
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

start_time = Time.now

@id = ''
puts ARGV.any? { |e| e.downcase.include?('drop') } ? 'Ejecutando con argumento: DROP' : 'Ejecutando con argumento: CREATE (default)' if OPTS[:debug]

CONFIG.bases.each do |base|
  @id = (CONFIG.bases.index(base)+1)*1000000         #obtiene el numero a aumentarse por base

  camTab.each {|tabla, campos|
    if ARGV.any? { |e| e.downcase.include?('drop') }
      queriesVistas[tabla] = CONFIG.bases.index(base) == 0 ? "DROP VIEW #{tabla}_0" : " \n" + queriesVistas[tabla]+"\n"
    else
      queriesVistas[tabla] = CONFIG.bases.index(base) == 0 ? "CREATE VIEW #{tabla}_0\nAS\n" : queriesVistas[tabla]+" union \n"
      queriesVistas[tabla]+= 'SELECT ' + campos.join(', ') +" FROM [#{base}].dbo.#{Bases::EQUIVALENCIA[tabla]}"
    end
  }
end

queriesVistas.each do |key,value|
  puts "Query: #{value}" if OPTS[:debug]
  Bases.ejecuta value

  query = ''
  if ARGV.any? { |e| e.downcase.include?('drop') }
    query+= "DROP TABLE #{key}"
  else
    query+= "SELECT * INTO #{key} FROM #{key}_0"
  end

  Bases.ejecuta query   #para las tablas del volcado
  puts "Query: #{query}" if OPTS[:debug]
end

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]