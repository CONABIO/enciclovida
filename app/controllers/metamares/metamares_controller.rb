class Metamares::MetamaresController < ApplicationController

  layout 'metamares'

  # La visualizacion por medio de D3
  def graficas
  end

  def grafica1
    g = Metamares::GraficasM.new
    g.grafica1

    render json: g.datos
  end
end
