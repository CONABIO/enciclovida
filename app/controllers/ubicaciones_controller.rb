class UbicacionesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :set_locale

  # Registros con un radio alreadedor de tu ubicación
  def ubicacion
  end

  # /explora-por-region
  def por_region
  end

  # Regresa el conteo por grupo del servicio de Abraham, no lo hago directo porque lo guardo en cache ya que
  # algunas peticiones tardan 20 segundos
  def conteo_por_grupo

    if params[:tipo_region].present?
      if params[:tipo_region] == 'estado' && params[:region_id].present?
        key = "conteo_grupo_#{params[:region_id]}"
        url = "#{CONFIG.ssig_api}/taxonEdo/conteo/total/#{params[:region_id].rjust(2, '0')}?apiKey=enciclovida"
      elsif params[:tipo_region] == 'municipio' && params[:region_id].present? && params[:parent_id].present?
        key = "conteo_grupo_#{params[:parent_id]}_#{params[:region_id]}"
        url = "#{CONFIG.ssig_api}/taxonMuni/listado/total/#{params[:parent_id]}/#{params[:region_id]}?apiKey=enciclovida"
      else
        resp = {estatus: false, msg: "El parámetro 'tipo_region' no es el correcto."}
      end

      if key.present?
        resp = Rails.cache.fetch(key, expires_in: eval(CONFIG.cache.busquedas_region.conteo_grupo)) do
          respuesta_conteo_por_grupo(url)
        end
      end

    else
      resp = {estatus: false, msg: "El parámetro 'tipo_region' esta vacío."}
    end

    render json: resp
  end

  def especies_por_grupo
    if params[:grupo_id].present? && params[:region_id].present?
      if params[:parent_id].present?
        key = "especies_grupo_#{params[:grupo_id].estandariza}_#{params[:parent_id]}_#{params[:region_id]}"
        url = "#{CONFIG.ssig_api}/taxonMuni/listado/#{params[:parent_id]}/#{params[:region_id].rjust(2, '0')}/edomun/#{params[:grupo_id].estandariza}?apiKey=enciclovida"
      else
        key = "especies_grupo_#{params[:grupo_id].estandariza}_#{params[:region_id]}"
        url = "#{CONFIG.ssig_api}/taxonEdo/conteo/#{params[:region_id].rjust(2, '0')}/edomun/#{params[:grupo_id].estandariza}?apiKey=enciclovida"
      end

      resp = Rails.cache.fetch(key, expires_in: eval(CONFIG.cache.busquedas_region.especies_grupo)) do
        respuesta_especies_por_grupo(url)
      end

    else
      resp = {estatus: false, msg: "Por favor verifica tus parámetros, 'grupo_id' y 'region_id' son obligatorios"}
    end

    # Una vez obtenida la respuesta del servicio o del cache iteramos en la base
    if resp[:estatus]
      especies_hash = {}
      resultados = []

      resp[:resultados].each do |r|
        especies_hash[r['especievalidabusqueda']] = r['nregistros'].to_i
      end

      taxones = Especie.select('especies.id, nombre_cientifico, especies.catalogo_id, nombre_comun_principal, foto_principal').adicional_join.where(nombre_cientifico: especies_hash.keys)
      taxones = Busqueda.filtros_default(taxones, params).distinct

      taxones.each do |taxon|
        resultados << {id: taxon.id, nombre_cientifico: taxon.nombre_cientifico, catalogo_id: taxon.catalogo_id, nombre_comun: taxon.nombre_comun_principal, foto: taxon.foto_principal, nregistros: especies_hash[taxon.nombre_cientifico]}
      end

      resp = {estatus: true, resultados: resultados}
    end

    render json: resp
  end

  # Devuelve los municipios por el estado seleccionado
  def municipios_por_estado
    resp = {}
    resp[:estatus] = false

    if params[:region_id].present?
      resp[:estatus] = true
      parent_id = Estado::CORRESPONDENCIA[params[:region_id].to_i]
      municipios = Municipio.campos_min.where(cve_ent: parent_id)
      resp[:resultados] = municipios.map{|m| {region_id: m.region_id, nombre_region: m.nombre_region}}
      resp[:parent_id] = parent_id
    else
      resp[:msg] = 'El argumento region_id está vacio'
    end

    render json: resp
  end

  def busquedas_avanzada
    busqueda = Especie
    busqueda = Busqueda.filtros_default(busqueda, params)
    puts busqueda.to_sql
  end

  # Descarga el listado de especies por region
  def descarga_taxa
    lista = Lista.new
    columnas = Lista::COLUMNAS_DEFAULT + Lista::COLUMNAS_RIESGO_COMERCIO + Lista::COLUMNAS_CATEGORIAS_PRINCIPALES
    lista.columnas = columnas.join(',')
    lista.formato = 'xlsx'
    lista.cadena_especies = params[:especies].join(',')
    lista.usuario_id = 0  # Quiere decir que es una descarga, la guardo en lista para tener un control y poder correr delayed_job

    if params[:especies].length > 0
      # Para saber si el correo es correcto y poder enviar la descarga
      if  Usuario::CORREO_REGEX.match(params[:correo]) ? true : false
        # el nombre de la lista es cuando la solicito y el correo
        lista.nombre_lista = Time.now.strftime("%Y-%m-%d_%H-%M-%S-%L") + "_taxa_EncicloVida|#{params[:correo]}"

        if Rails.env.production?
          lista.delay(:priority => 2, queue: 'descargar_taxa').to_excel({ubicaciones: true, correo: params[:correo]}) if lista.save
        else  # Para develpment o test
          lista.to_excel({ubicaciones: true, correo: params[:correo]}) if lista.save
        end

        render json: {estatus: true}

      else  # Por si no puso un correo valido
        render json: {estatus: false, msg: 'El correo no es válido.'}
      end

    else  # No entro a ningun condicional, es un error
      render json: {estatus: false, msg: 'No hubo especies para descarga'}
    end  # end especies > 0
  end


  private

  def respuesta_especies_por_grupo(url)
    begin
      rest = RestClient.get(url)
      especies = JSON.parse(rest)

      {estatus: true, resultados: especies}

    rescue => e
      {estatus: false, msg: e.message}
    end
  end

  def respuesta_conteo_por_grupo(url)
    begin
      rest = RestClient.get(url)
      conteo = JSON.parse(rest)

      if conteo.kind_of?(Hash) && conteo['error'].present?
        {estatus: false, msg: conteo['error']}
      else
        conteo = icono_grupo(conteo)
        {estatus: true, resultados: conteo}
      end
    rescue => e
      {estatus: false, msg: e.message}
    end
  end

  # Asigna el grupo iconico de enciclovida de acuerdo nombres y grupos del SNIB
  def icono_grupo(grupos)
    grupos.each do |g|

      case g['grupo']
        when 'Anfibios'
          g.merge!({'icono' => 'amphibia-ev-icon'})
        when 'Aves'
          g.merge!({'icono' => 'aves-ev-icon'})
        when 'Bacterias'
          g.merge!({'icono' => 'prokaryotae-ev-icon'})
        when 'Hongos'
          g.merge!({'icono' => 'fungi-ev-icon'})
        when 'Invertebrados'
          g.merge!({'icono' => 'annelida-ev-icon'})
        when 'Mamíferos'
          g.merge!({'icono' => 'mammalia-ev-icon'})
        when 'Peces'
          g.merge!({'icono' => 'actinopterygii-ev-icon'})
        when 'Plantas'
          g.merge!({'icono' => 'plantae-ev-icon'})
        when 'Protoctistas'
          g.merge!({'icono' => 'protoctista-ev-icon'})
        when 'Reptiles'
          g.merge!({'icono' => 'reptilia-ev-icon'})
      end
    end

    grupos
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_ubicacion
    @ubicacion = Metadato.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ubicacion_params
    params.require(:ubicacion).permit(:path, :object_name, :artist, :copyright)
  end
end

