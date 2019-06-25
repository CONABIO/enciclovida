class EstadisticasController < ApplicationController

  layout 'estadisticas'
  before_action :get_statistics, :filtros_iniciales, only: [:show]

  def show

  end

  def busqueda
  end

  def filtros_estadisticas()
    @resultados = {}
    puts "Paràmetros: #{params}"
    @resultados = get_statistics
    render json: build_json_to_statics(@resultados)
  end

  def build_json_to_statics(datos)

    # Si contiene '-', crear un hijo
    # Árbol de estadísticas
    estadisticas = []

    multimedia = agrega_hijo(estadisticas, "Multimedia")
    fichas = agrega_hijo(estadisticas, "Fichas")
    nombres_c = agrega_hijo(estadisticas, "Nombres_comunes")
    obser = agrega_hijo(estadisticas, "Observaciones")
    ejemp = agrega_hijo(estadisticas, "Ejemplares")
    mapas = agrega_hijo(estadisticas, "Mapas")
    n_espe = agrega_hijo(estadisticas, "Número_especies")
    visit = agrega_hijo(estadisticas, "Visitas")
    otros = agrega_hijo(estadisticas, "Otros")

    datos.each do |dato|
      estd = dato[1][:nombre_estadistica]
      if estd.include?('Fotos') || estd.include?('Audio') || estd.include?('Videos')
        if estd.include?('Fotos')
          foto = agrega_hijo(multimedia[:children], "Fotos")
          agrega_valor(foto, dato[1])
        elsif estd.include?('Audio')
          audio = agrega_hijo(multimedia[:children], "Audios")
          agrega_valor(audio, dato[1])
        elsif estd.include?('Videos')
          video = agrega_hijo(multimedia[:children], "Videos")
          agrega_valor(video, dato[1])
        end
      elsif estd.include?('Fichas')
        agrega_valor(fichas, dato[1])
      elsif estd.include?('Nombres comunes')
        agrega_valor(nombres_c, dato[1])
      elsif estd.include?('Observaciones')
        agrega_valor(obser, dato[1])
      elsif estd.include?('Ejemplares')
        agrega_valor(ejemp, dato[1])
      elsif estd.include?('Mapas')
        agrega_valor(mapas, dato[1])
      elsif estd.include?('Número')
        agrega_valor(n_espe, dato[1])
      elsif estd.include?('Visitas')
        agrega_valor(visit, dato[1])
      else
        agrega_valor(otros, dato[1])
      end
    end

    root_est = {'name': "Estadísticas CONABIO", 'children': estadisticas}
    root_est.to_json
  end

  # Obtiene las estadisticas en general
  def get_statistics
    @estadisticas = {}
    #Extraer el nombre e id de todas las estadisticas existentes para buscar el total de todas las especies
    Estadistica.all.each do |estadistica|
      # Saltar estadísticas 8, 9 10 y 12 porque ya no se usan
      next if [8, 9, 10, 12, 1, 2, 3, 22, 23].index(estadistica.id)
      @estadisticas[estadistica.id] = {
          'nombre_estadistica': estadistica.descripcion_estadistica,
          'conteo': EspecieEstadistica.all.where("estadistica_id = #{estadistica.id}").size
      }
    end
    @estadisticas
  end

  private
  # Los filtros de la busqueda avanzada y de los resultados
  def filtros_iniciales
    @reinos = Especie.select_grupos_iconicos.where(nombre_cientifico: Busqueda::GRUPOS_REINOS)
    @animales = Especie.select_grupos_iconicos.where(nombre_cientifico: Busqueda::GRUPOS_ANIMALES)
    @plantas = Especie.select_grupos_iconicos.where(nombre_cientifico: Busqueda::GRUPOS_PLANTAS)
    @nom_cites_iucn_todos = Catalogo.nom_cites_iucn_todos
  end

  # Método para construir un json aceptable para el generador de gráficas
  def agrega_hijo(padre, name)
    # Si ya existe, solo devolverlo
    if pdre = padre.find {|x| x[:name] == name}
      hijo = pdre
    else
      # Si no existe el nuevo hijo, agregarlo
      hijo = {'name': name, 'children': []}
      padre.append(hijo)
    end
    hijo
  end

  # Método para construir un json aceptable para el generador de gráficas
  def agrega_valor(padre, dato)
    # Si el nombre del dato, contiene un '-', dividirlo
    if dato[:nombre_estadistica].include?('-')
      nombres = dato[:nombre_estadistica].split("-", 2)
      valor = agrega_hijo(padre[:children], nombres[0])
      valor[:children].append("name": nombres[1], "size": dato[:conteo])
    else
      padre[:children].append("name": dato[:nombre_estadistica], "size": dato[:conteo])
    end
    padre
  end

end