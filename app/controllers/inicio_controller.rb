class InicioController < ApplicationController
  def index
	  @no_render_busqueda_basica = true
	  @buscadores = Busqueda::BUSCADORES
  end

  def acerca
  end

  def error
  end
end
