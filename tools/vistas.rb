#! /usr/local/bin/ruby
require 'rubygems'
require 'trollop'
require 'tiny_tds'

OPTS = Trollop::options do
  banner <<-EOS
Crea las vistas necesarias para la consulta desde Rails.

*** Este script puede usarse tanto para crear las vistas como para borrarlas.


Usage:

  rails r tools/vistas.rb -d     #por default crea las vistas
  rails r tools/vistas.rb -d drop    #para borrar las vistas

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end


client = TinyTds::Client.new(:username => 'VIRTUALW8\beto', :password => '123', :host => '172.16.3.224', :port => '5050')
#client = TinyTds::Client.new(:username => 'dgcc', :password => 'dgcc2014', :host => '200.12.166.180', :database => 'dgcc')#, :port => '5050')

puts client.dead?    # => false
puts client.closed?  # => false
puts client.active?  # => true

queryNombreBD = "select	substring(name,1,2) as ID, name as bd from sys.databases where name like '[0-9]%' order by name"

equivalencia = {
    'bibliografias' => 'Bibliografia',
    'catalogos' => 'CatalogoNombre',
    'categorias_taxonomicas' => 'CategoriaTaxonomica',
    'especies' => 'Nombre',
    'especies_bibliografias' => 'RelNombreBiblio',
    'especies_catalogos' => 'RelNombreCatalogo',
    'especies_estatuses' => 'Nombre_Relacion',
    'especies_estatuses_bibliografias' => 'RelacionBibliografia',
    'especies_regiones' => 'RelNombreRegion',
    'estatuses' => 'Tipo_Relacion',
    'nombres_comunes' => 'Nomcomun',
    'nombres_regiones' => 'RelNomNomComunRegion',
    'nombres_regiones_bibliografias' => 'RelNomNomcomunRegionBiblio',
    'regiones' => 'Region',
    'tipos_distribuciones' => 'TipoDistribucion',
    'tipos_regiones' => 'TipoRegion',
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
                     "ancestry_ascendente_directo",
                     "ancestry_ascendente_obligatorio",
                     "nombre_cientifico",
                     "'' as delta",
                     "nombre_comun_principal",
                     "foto_principal",
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
                            "NomComun as nomre_comun",
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

queriesVistas = {
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

@id = ''
res = client.execute(queryNombreBD)
puts ARGV.any? { |e| e.downcase.include?('drop') } ? 'Ejecutando con argumento: DROP' : 'Ejecutando con argumento: CREATE (default)' if OPTS[:debug]

res.each do |bd|
  @id = bd['ID'].to_i*1000000
  camTab.each {|tabla, campos|
    if ARGV.any? { |e| e.downcase.include?('drop') }
      queriesVistas[tabla] = bd['ID']=='01' ? "DROP VIEW #{tabla}" : " \n" + queriesVistas[tabla]+"\n"
    else
      queriesVistas[tabla] = bd['ID']=='01' ? "CREATE VIEW #{tabla}\nAS\n" : queriesVistas[tabla]+" union \n"
      queriesVistas[tabla]+= 'SELECT ' + campos.join(', ') +" FROM [#{bd['bd']}].dbo.#{equivalencia[tabla]}"
    end
  }
end

res.cancel

queriesVistas.each do |key,value|
  puts "Query: #{value}" if OPTS[:debug]
  res = client.execute(value)
  res.cancel
end
client.close
