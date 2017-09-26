class UbicacionesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :set_locale
  #before_action :set_ubicacion, only: []
  #before_action :authenticate_usuario!, :except => :create

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

