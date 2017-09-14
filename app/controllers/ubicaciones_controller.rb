class UbicacionesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :set_locale
  #before_action :set_ubicacion, only: []
  #before_action :authenticate_usuario!, :except => :create

  # Registros con un radio alreadedor de tu ubicación
  def ubicacion
  end

  # /explora-por-region
  def region
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

