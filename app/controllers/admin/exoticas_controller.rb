class Admin::ExoticasController < ApplicationController

  before_action :authenticate_usuario!

  before_action do
    tiene_permiso?('Administrador exoticas', true)
  end

  layout 'admin'

end