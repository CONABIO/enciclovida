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
    @estadisticas[:visitas] = EspecieEstadistica.all.where('estadistica_id = 1').size
    @estadisticas[:num_especies] = EspecieEstadistica.all.where('estadistica_id = 2').size
    @estadisticas[:num_especies_inf] = EspecieEstadistica.all.where('estadistica_id = 3').size
    @estadisticas[:nom_comun_naturalista] = EspecieEstadistica.all.where('estadistica_id = 4').size
    @estadisticas[:nom_comun_conabio] = EspecieEstadistica.all.where('estadistica_id = 5').size
    @estadisticas[:fotos_naturalista] = EspecieEstadistica.all.where('estadistica_id = 6').size
    @estadisticas[:fotos_bdi] = EspecieEstadistica.all.where('estadistica_id = 7').size
    @estadisticas[:fichas_conabio] = EspecieEstadistica.all.where('estadistica_id = 11').size
    @estadisticas[:fichas_eol_es] = EspecieEstadistica.all.where('estadistica_id = 13').size
    @estadisticas[:fichas_eol_en] = EspecieEstadistica.all.where('estadistica_id = 14').size
    @estadisticas[:fichas_wikipedia_es] = EspecieEstadistica.all.where('estadistica_id = 15').size
    @estadisticas[:fichas_wikipedia_en] = EspecieEstadistica.all.where('estadistica_id = 16').size
    @estadisticas[:ej_snib] = EspecieEstadistica.all.where('estadistica_id = 17').size
    @estadisticas[:ej_snib_averaves] = EspecieEstadistica.all.where('estadistica_id = 18').size
    @estadisticas[:obser_naturalista_cienti] = EspecieEstadistica.all.where('estadistica_id = 19').size
    @estadisticas[:obser_naturalista_casual] = EspecieEstadistica.all.where('estadistica_id = 20').size
    @estadisticas[:mapas_distribucion] = EspecieEstadistica.all.where('estadistica_id = 21').size
    @estadisticas[:especies_validas] = EspecieEstadistica.all.where('estadistica_id = 22').size
    @estadisticas[:especies_e_infer_validas] = EspecieEstadistica.all.where('estadistica_id = 23').size
    @estadisticas[:fotos_tropicos] = EspecieEstadistica.all.where('estadistica_id = 24').size
    @estadisticas[:fotos_maccaulay] = EspecieEstadistica.all.where('estadistica_id = 25').size
    @estadisticas[:videos_maccaulay] = EspecieEstadistica.all.where('estadistica_id = 26').size
    @estadisticas[:audios_maccaulay] = EspecieEstadistica.all.where('estadistica_id = 27').size
    @estadisticas

    # Extraer el noombre de la estadistica
    # Estadistica.find(1).descripcion_estadistica

  end

end