class EstadisticasController < ApplicationController

  # layout false
  before_action :get_statistics, :filtros_iniciales, only: [:show]

  def show

  end

  def busqueda


  end

  def filtros_estadisticas()
    @resultados = {}
    puts "Paràmetros #{params}"
    @resultados = get_statistics
    render json: @resultados
  end

  def get_statistics
    @estadisticas = {}
    #Extraer el nombre e id de todas las estadisticas existentes para buscar el total de todas las especies
    Estadistica.all.each do |estadistica|
      # Saltar estadísticas 8, 9 10 y 12 porque ya no se usan
      next if [8, 9, 10, 12].index(estadistica.id)
      @estadisticas[estadistica.descripcion_estadistica] = EspecieEstadistica.all.where("estadistica_id = #{estadistica.id}").size
    end

    @estadisticas
  end

  private

  # REVISADO: Los filtros de la busqueda avanzada y de los resultados
  def filtros_iniciales
    @reinos = Especie.select_grupos_iconicos.where(nombre_cientifico: Busqueda::GRUPOS_REINOS)
    @animales = Especie.select_grupos_iconicos.where(nombre_cientifico: Busqueda::GRUPOS_ANIMALES)
    @plantas = Especie.select_grupos_iconicos.where(nombre_cientifico: Busqueda::GRUPOS_PLANTAS)

    @nom_cites_iucn_todos = Catalogo.nom_cites_iucn_todos

  end


end


=begin

MULTIMEDIA:
  FOTOS
    CONABIO
    NATURALISTA
    TROPICOS
    MACCAULAY
  VIDEOS
    MACCAULAY
  AUDIO
    MACCAULAY

Visitas
1 Visitas a la especie o grupo

Nombres Comunes



Separaciòn de estadisticas:

1 Visitas a la especie o grupo

2 Número de especies
3 Número de especies e inferiores
22 Número de especies validas
23 Número de especies e inferiores validas

4 Nombres comunes de NaturaLista
5 Nombres comunes de CONABIO

6 Fotos en NaturaLista
7 Fotos en el Banco de Imágenes de CONABIO
24 Fotos en Tropicos
25 Fotos en Maccaulay
26 Videos en Maccaulay
27 Audio en Maccaulay


11 Fichas revisadas de CONABIO
13 Fichas de EOL-español
14 Fichas de EOL-ingles
15 Fichas de Wikipedia-español
16 Fichas de Wikipedia-ingles

17 Ejemplares en el SNIB
18 Ejemplares en el SNIB (aVerAves)

19 Observaciones en NaturaLista (grado de investigación)
20 Observaciones en NaturaLista (grado casual)

21 Mapas de distribución


=end
