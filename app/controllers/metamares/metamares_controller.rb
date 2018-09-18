class Metamares::MetamaresController < ApplicationController

  before_action :authenticate_usuario!
  before_action  do
    tiene_permiso?('AdminMetamares')  # Minimo administrador
  end

  layout 'metamares'

  private

  def usuario_params
    params.require(:usuario).permit(:nombre, :apellido, :email, :institucion, :password, :password_confirmation,
                                    usuario_roles_attributes: [:id, :usuario_id, :rol_id, :done, :_destroy])
  end

  def set_usuario
    begin
      @usuario = Usuario.find(params[:id])
    rescue
      render :_error and return
    end
  end

end
