class UbicacionesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :set_locale

  # Registros con un radio alreadedor de tu ubicación
  def ubicacion
  end

  # /explora-por-region
  def por_region
    @estados = Estado.all.order(entidad: :asc).collect{ |e| [t("estados.#{e.entidad.estandariza}", default: e.entidad), e.entid] }
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

  # Devuelve los municipios por el estado seleccionado
  def municipios_por_estado
    resp = {}
    resp[:estatus] = false

    if params[:region_id].present?
      resp[:estatus] = true
      municipios = Municipio.campos_min.where(cve_ent: Estado::CORRESPONDENCIA[params[:region_id].to_i])
      resp[:resultados] = municipios.map{|m| {region_id: m.region_id, parent_id: m.parent_id, nombre_region: m.nombre_region}}
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

