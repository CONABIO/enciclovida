class ValidacionesController < ApplicationController

  before_filter :authenticate_usuario!

  def create
    render :text => 'Creo'
  end

  def update
    render :text => 'Actualizo'
  end


  private

  params.require(:validaciones).permit(
      :id, :nuevo
  )
end