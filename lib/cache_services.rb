module CacheServices
  # REVISADO: Actualiza todos los servicios concernientes a un taxon, se empaqueto para que no estuviera en Especie
  def servicios
    suma_visita_servicio
    #cuantas_especies_inferiores_servicio(estadistica_id: 2)  # Servicio para poner el numero totales de especies del taxon
    #cuantas_especies_inferiores_servicio(estadistica_id: 3)  # Servicio para poner el numero totales de especies o inferiores del taxon
    #cuantas_especies_inferiores_servicio({estadistica_id: 22, validas: true})  # Servicio para poner el numero totales de especies o inferiores validas del taxon
    #cuantas_especies_inferiores_servicio({estadistica_id: 23, validas: true})  # Servicio para poner el numero totales de especies o inferiores validas del taxon
    #guarda_observaciones_naturalista_servicio
    #guarda_ejemplares_snib_servicio
    guarda_nombres_comunes_todos_servicio
    guarda_redis_servicio
    #guarda_pez_servicios
  end

  # REVISADO: Guarda los datos más importantes en el redis
  def guarda_redis_servicio
    if Rails.env.production?
      delay(queue: 'redis').guarda_redis
    else
      guarda_redis
    end
  end

  # REVISADO: Guarda la información asociada al pez
  def guarda_pez_servicios
    if Rails.env.production?
      pez.delay(queue: 'peces').save if pez
    else
      pez.save if pez
    end
  end

  # REVISADO: # Guarda los nombres comunes en adicionales
  def guarda_nombres_comunes_todos_servicio
    if Rails.env.production?
      guarda_nombres_comunes_todos.delay(queue: 'nombres_comunes')
    else
      guarda_nombres_comunes_todos
    end
  end

  # REVISADO: Suma una visita a la estadisticas
  def suma_visita_servicio
    if Rails.env.production?
      delay(queue: 'estadisticas').suma_visita
    else
      suma_visita
    end
  end

  # REVISADO: Cuenta en numero de especies o el numero de especies mas las inferiores de una taxon, depende del argumento
  def cuantas_especies_inferiores_servicio(opc = {})
    if !existe_cache?("estadisticas_cuantas_especies_inferiores_#{opc[:estadistica_id]}")
      if Rails.env.production?
        delay(queue: 'estadisticas').cuantas_especies_inferiores(opc)
      else
        cuantas_especies_inferiores(opc)
      end

      escribe_cache("estadisticas_cuantas_especies_inferiores_#{opc[:estadistica_id]}", CONFIG.cache.cuantas_especies_inferiores) if Rails.env.production?
    end
  end

  # REVISADO: Guarda las observaciones desde la pagina de naturalista
  def guarda_observaciones_naturalista_servicio
    if !existe_cache?('observaciones_naturalista')
      if p = proveedor
        if Rails.env.production?
          p.delay(queue: 'observaciones_naturalista').guarda_observaciones_naturalista
        else
          p.guarda_observaciones_naturalista
        end
      end

      escribe_cache('observaciones_naturalista', CONFIG.cache.observaciones_naturalista) if Rails.env.production?
    end
  end

  # REVISADO: Guarda los ejemplares del SNIB
  def guarda_ejemplares_snib_servicio
    if !existe_cache?('ejemplares_snib')
      if p = proveedor
        if Rails.env.production?
          p.delay(queue: 'ejemplares_snib').guarda_ejemplares_snib
        else
          p.guarda_ejemplares_snib
        end
      end

      escribe_cache('ejemplares_snib', CONFIG.cache.ejemplares_snib) if Rails.env.production?
    end
  end

  # REVISADO: Escribe un cache
  def escribe_cache(recurso, tiempo = 1.day)
    Rails.cache.write("#{recurso}_#{id}", :expires_in => tiempo)
  end

  # REVISADO: Verifica que el cache exista
  def existe_cache?(recurso)
    Rails.cache.exist?("#{recurso}_#{id}")
  end

  # REVISADO: Borra un cache
  def borra_cache(recurso)
    Rails.cache.delete("#{recurso}_#{id}")
  end


  private

  # REVISADO: Es un metodo que no depende del la tabla proveedor, puesto que consulta naturalista sin el ID
  def ficha_naturalista_por_nombre
    return {estatus: false, msg: 'No hay resultados'} if existe_cache?('ficha_naturalista')
    escribe_cache('ficha_naturalista', CONFIG.cache.ficha_naturalista) if Rails.env.production?

    begin
      respuesta = RestClient.get "#{CONFIG.naturalista_url}/taxa/search.json?q=#{URI.escape(nombre_cientifico.limpia_ws)}"
      resultados = JSON.parse(respuesta)
    rescue => e
      return {estatus: false, msg: e}
    end

    # Nos aseguramos que coincide el nombre
    return {estatus: false, msg: 'No hay resultados'} if resultados.count == 0

    resultados.each do |t|
      next unless t['ancestry'].present?
      if t['name'].downcase == nombre_cientifico.limpia_ws.downcase
        reino_naturalista = t['ancestry'].split('/')[1].to_i
        next unless reino_naturalista.present?
        reino_enciclovida = root_id

        # Me aseguro que el reino coincida
        if (reino_naturalista == reino_enciclovida) || (reino_naturalista == 47126 && reino_enciclovida == 2) || (reino_naturalista == 47170 && reino_enciclovida == 4) || (reino_naturalista == 47686 && reino_enciclovida == 5)

          if p = proveedor
            p.naturalista_id = t['id']
            p.save
          else
            self.proveedor = Proveedor.create({naturalista_id: t['id'], especie_id: id})
          end

          return {estatus: true, ficha: t}
        end

      end  # End nombre cientifico
    end  # End resultados

    return {estatus: false, msg: 'No hubo coincidencias con los resultados del servicio'}
  end

  # REVISADO: Guarda fotos y nombres comunes de dbi, catalogos y naturalista
  def guarda_fotos_nombres_servicios
    ficha_naturalista_por_nombre if !proveedor  # Para encontrar el naturalista_id si no existe el proveedor
    guarda_nombres_comunes_todos
    guarda_fotos_todas
  end

  # REVISADO: Guarda en adicionales las fotos
  def guarda_fotos_todas
    dame_fotos_todas

    if x_foto_principal.present?
      a = adicional ? adicional : Adicional.new(especie_id: id)
      a.foto_principal = x_foto_principal
      a.save if a.changed?
    end
  end

  # REVISADO: Guarda los nombres comunes en adicionales
  def guarda_nombres_comunes_todos
    dame_nombres_comunes_todos

    if x_nombre_comun_principal.present?
      a = adicional ? adicional : Adicional.new(especie_id: id)
      a.nombres_comunes = x_nombres_comunes
      a.nombre_comun_principal = x_nombre_comun_principal
      a.save if a.changed?
    end
  end

  # REVISADO: Asigna el redis correspondiente
  def asigna_redis(opc={})
    datos = {}
    datos[:data] = {}

    guarda_fotos_nombres_servicios if opc[:consumir_servicios]
    visitas = especie_estadisticas.visitas

    # Asigna si viene la peticion de nombre comun
    if nc = opc[:nombre_comun]
      datos[:id] = nc.id
      datos[:term] = I18n.transliterate(nc.nombre_comun.limpia)
      datos[:data][:nombre_comun] = nc.nombre_comun
      datos[:data][:id] = id
      datos[:data][:lengua] = nc.lengua

      # Para el score dependiendo la lengua
      lengua = nc.lengua.estandariza
      index = Adicional:: LENGUAS_ACEPTADAS.reverse.index(lengua) || 0
      datos[:score] = index*visitas

    else  # Asigna si viene la peticion de nombre_cientifico
      datos[:id] = id
      datos[:term] = I18n.transliterate(nombre_cientifico.limpia)
      datos[:data][:nombre_comun] = x_nombre_comun_principal
      datos[:data][:id] = id
      datos[:data][:lengua] = x_lengua
      datos[:score] = Adicional::LENGUAS_ACEPTADAS.length*visitas
    end

    if opc[:foto_principal].present?
      datos[:data][:foto] = opc[:foto_principal]
    else
      datos[:data][:foto] = x_square_url  # Foto square_url
    end

    datos[:data][:nombre_cientifico] = nombre_cientifico.limpia
    datos[:data][:estatus] = Especie::ESTATUS_VALOR[estatus]
    datos[:data][:autoridad] = nombre_autoridad.try(:limpia)

    # Caracteristicas de riesgo y conservacion, ambiente y distribucion
    cons_amb_dist = {}
    caracteristicas = nom_cites_iucn_ambiente_prioritaria(iucn_ws: true) << tipo_distribucion

    caracteristicas.reduce({}, :merge).each do |nombre, valores|
      next unless valores.any?

      valores.each do |valor|
        cons_amb_dist[valor.estandariza] = valor
      end
    end

    datos[:data][:cons_amb_dist] = cons_amb_dist

    # Para saber cuantas fotos tiene
    datos[:data][:fotos] = x_fotos_totales

    # Para saber si tiene algun mapa
    if p = proveedor
      datos[:data][:geodatos] = p.geodatos[:cuales]
    end

    datos.stringify_keys
  end

  # REVISADO: Gurada los nombres comunes y cientifico en redis
  def guarda_redis(opc={})
    # Pone en nil las variables para guardar los servicios y no consultarlos de nuevo
    self.x_foto_principal = nil
    self.x_nombre_comun_principal = nil
    self.x_lengua = nil
    self.x_fotos_totales = 0  # Para poner cero si no tiene fotos
    self.x_nombres_comunes = nil
    self.x_nombres_comunes_todos = nil

    if opc[:loader].present? # Guarda en el loader que especifico
      loader = Soulmate::Loader.new(opc[:loader])
    else # Guarda en la cataegoria taxonomica correspondiente
      categoria = I18n.transliterate(categoria_taxonomica.nombre_categoria_taxonomica).gsub(' ','_')
      loader = Soulmate::Loader.new(categoria)
    end

    # Borra los actuales
    borra_redis(loader)

    # Guarda el redis con el nombre cientifico
    loader.add(asigna_redis(opc.merge({consumir_servicios: true})))

    # Guarda el redis con todos los nombres comunes
    num_nombres = 0

    x_nombres_comunes_todos.each do |nombres|
      lengua = nombres.keys.first

      nombres.values.flatten.each_with_index do |nombre|
        num_nombres+= 1
        nombre_obj = NombreComun.new({id: "#{id}000000#{num_nombres}".to_i, nombre_comun: nombre, lengua: lengua})
        loader.add(asigna_redis(opc.merge({nombre_comun: nombre_obj})))
      end
    end
  end

  # REVISADO: borra todos los nombres comunes y el cnetifico del redis, para posteriormente volver a generarlo
  def borra_redis(loader)
    # Borra el del nombre cientifico
    nombre_cient_data = {id: id}.stringify_keys
    loader.remove(nombre_cient_data)

    # Borra los nombre comunes
    50.times do |i|
      nombre_com_data = {id: "#{id}000000#{i+1}"}.stringify_keys
      loader.remove(nombre_com_data)
    end
  end

  # REVISADO: Regresa el numero de especies
  def cuantas_especies(opc = {})
    scope = descendants.solo_especies
    scope = scope.where(estatus: 2) if opc[:validas]
    scope.count
  end

  # REVISADO: Regresa el numero de especies e inferiores
  def cuantas_especies_e_inferiores(opc = {})
    scope = descendants.especies_e_inferiores
    scope = scope.where(estatus: 2) if opc[:validas]
    scope.count
  end

  # REVISADO: Pone el conteo de las especies o inferiores de un taxon en la tabla estadisticas
  def cuantas_especies_inferiores(opc = {})
    return unless opc[:estadistica_id].present?
    puts "\n\nGuardo estadisticas_cuantas_especies_inferiores_#{opc[:estadistica_id]} - #{id} ..."
    escribe_cache("estadisticas_cuantas_especies_inferiores_#{opc[:estadistica_id]}", eval(CONFIG.cache.estadisticas.cuantas_especies_inferiores)) if Rails.env.production?

    conteo = case opc[:estadistica_id]
             when 2, 22
               cuantas_especies(opc)
             when 3, 23
               cuantas_especies_e_inferiores(opc)
             else
               false
             end

    return unless conteo

    if estadistica = especie_estadisticas.where(estadistica_id: opc[:estadistica_id]).first
      estadistica.conteo = conteo
      estadistica.save if estadistica.changed?
      return
    end

    # Quiere decir que no existia la estadistica
    estadistica = especie_estadisticas.new
    estadistica.estadistica_id = opc[:estadistica_id]
    estadistica.conteo = conteo
    estadistica.save
  end

  # REVISADO: Suma la visita de una ficha en la tabla estadisticas
  def suma_visita
    puts "\n\nGuardo conteo de visitas #{id} ..."

    if estadistica = especie_estadisticas.where(estadistica_id: 1).first
      estadistica.conteo+= 1
      estadistica.save
      return
    end

    # Quiere decir que no existia la estadistica
    estadistica = especie_estadisticas.new
    estadistica.estadistica_id = 1
    estadistica.conteo = 1
    estadistica.save
  end
end