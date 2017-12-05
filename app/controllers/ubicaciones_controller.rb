class UbicacionesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :set_locale

  # Registros con un radio alreadedor de tu ubicación
  def ubicacion
  end

  # /explora-por-region
  def por_region
  end

  def especies_por_catalogo_id
    if params[:catalogo_id].present?
      resultados = []

      Especie.where(catalogo_id: params[:catalogo_id]).each do |taxon|
        next unless p = taxon.proveedor
        geodatos = p.geodatos
        next unless geodatos.any?

        resultados << {nombre_cientifico: taxon.nombre_cientifico, snib_mapa_json: geodatos[:snib_mapa_json]}

        if a = taxon.adicional
          resultados.last.merge!(nombre_comun: a.nombre_comun_principal, foto: a.foto_principal)
        end

      end  # each taxon

      render json: {estatus: true, resultados: resultados}

    else
      render json: {estatus: false, msg: 'No hubo especies que '}
    end  # End catalogo_id present
  end

  def especies_por_nombre_cientifico
    especies_hash = {}

    params[:especies].each do |e|
      cad = e.split('-')
      especies_hash[cad.first] = cad.last.to_i  
    end

    taxones = Especie.select('especies.id, nombre_cientifico, catalogo_id, nombre_comun_principal, foto_principal').adicional_join.where(nombre_cientifico: especies_hash.keys)     
    resultados = []
    taxones.each do |taxon|
      resultados << {id: taxon.id, nombre_cientifico: taxon.nombre_cientifico, catalogo_id: taxon.catalogo_id, nombre_comun: taxon.nombre_comun_principal, foto: taxon.foto_principal, nregistros: especies_hash[taxon.nombre_cientifico]}
    end
 
    render json: {estatus: true, resultados: resultados}
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


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ubicacion
    @ubicacion = Metadato.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ubicacion_params
    params.require(:ubicacion).permit(:path, :object_name, :artist, :copyright)
  end
end

