# Este controlador tiene la finalidad de hacer contenido por paginas, ej la lista de invasoras
class PaginasController < ApplicationController
  skip_before_filter :set_locale

  def exoticas_invasoras
    @exoticas = Especie.find(1000001)
  end
end