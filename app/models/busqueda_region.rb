class BusquedaRegion < Busqueda
  attr_accessor :params, :nombres_cientificos

  def cache_especies_por_grupo
    if params[:grupo_id].present? && params[:region_id].present?
      if params[:parent_id].present?
        key = "especies_grupo_municipio_#{params[:grupo_id].estandariza}_#{params[:parent_id]}_#{params[:region_id]}"
        url = "#{CONFIG.ssig_api}/taxonMuni/listado/#{params[:parent_id]}/#{params[:region_id].rjust(2, '0')}/edomun/#{params[:grupo_id].estandariza}?apiKey=enciclovida"
      else
        key = "especies_grupo_estado_#{params[:grupo_id].estandariza}_#{params[:region_id]}"
        url = "#{CONFIG.ssig_api}/taxonEdo/conteo/#{params[:region_id].rjust(2, '0')}/edomun/#{params[:grupo_id].estandariza}?apiKey=enciclovida"
      end

      resp = Rails.cache.fetch(key, expires_in: eval(CONFIG.cache.busquedas_region.especies_grupo)) do
        respuesta_especies_por_grupo(url)
      end

    else
      resp = {estatus: false, msg: "Por favor verifica tus parámetros, 'grupo_id' y 'region_id' son obligatorios"}
    end

    resp
  end

  # Es la busqueda con los filtros, regio y grupo de la busqueda por region
  def cache_especies_por_grupo_con_filtros
    # La llave con los diferentes filtros
    edo_cons = params[:edo_cons].present? ? params[:edo_cons].join('-') : ''
    dist = params[:dist].present? ? params[:dist].join('-') : ''
    prior = params[:prior].present? ? params[:prior].join('-') : ''
    key = "#{key}_#{edo_cons}_#{dist}_#{prior}".estandariza

    taxones = Rails.cache.fetch(key, expires_in: eval(CONFIG.cache.busquedas_region.especies_grupo)) do
      consulta = Especie.select('especies.id, nombre_cientifico, especies.catalogo_id, nombre_comun_principal, foto_principal').adicional_join.where(nombre_cientifico: nombres_cientificos)
      res = filtros_default(consulta).distinct
      res.map{|taxon| {id: taxon.id, nombre_cientifico: taxon.nombre_cientifico, catalogo_id: taxon.catalogo_id, nombre_comun: taxon.nombre_comun_principal, foto: taxon.foto_principal}}
    end

    taxones
  end


  private

  def filtros_default(consulta)
    Busqueda.filtros_default(consulta, params)
  end

  def respuesta_especies_por_grupo(url)
    begin
      rest = RestClient.get(url)
      especies = JSON.parse(rest)

      {estatus: true, resultados: especies}

    rescue => e
      {estatus: false, msg: e.message}
    end
  end

end