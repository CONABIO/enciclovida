class Admin::AdminController < ApplicationController
  before_action :authenticate_usuario!
  before_action do
    tiene_permiso?('AdminCatalogos', true) # Minimo administrador catalogos
  end
end