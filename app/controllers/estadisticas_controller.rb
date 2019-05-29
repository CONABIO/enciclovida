class EstadisticasController < ApplicationController

  # layout false
  before_action :get_statistics, only: [:show]


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
      next if [8, 9, 10, 12].index(estadistica.id)
      @estadisticas[estadistica.descripcion_estadistica] = EspecieEstadistica.all.where("estadistica_id = #{estadistica.id}").size
    end

    @estadisticas
    # Extraer el noombre de la estadistica
    # Estadistica.find(1).descripcion_estadistica
  end

end