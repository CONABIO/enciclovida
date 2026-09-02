class Admin::ExoticasInvasorasController < Admin::AdminController
  
  before_action :carga_catalogos, only: [:new, :create, :edit, :update]
  before_action :set_exotica, only: [:edit, :update, :destroy]

  def especies_registradas
    ids = Array(params[:ids]).reject(&:blank?).map(&:to_i).uniq

    registradas = ExoticaInvasora
      .where(especie_id: ids)
      .pluck(:especie_id)

    render json: registradas
  end

  def index
    @por_pagina = 30
    @pagina = params[:pagina].present? ? params[:pagina].to_i : 1

    @totales = ExoticaInvasora.count

    inicio = (@pagina - 1) * @por_pagina

    @exoticas = ExoticaInvasora.includes(:especie, :catalogos, :documentos).order(created_at: :desc).limit(@por_pagina).offset(inicio)
    @paginas = (@totales % @por_pagina).zero? ? @totales / @por_pagina : (@totales / @por_pagina) + 1
    @catalogos = ExoticaCatalogo.activos.where.not(tipo: "tipo_documento").group_by(&:tipo)
  end

  def new
    @exotica = ExoticaInvasora.new
    @exotica.documentos.build
  end

  def create
    @exotica = ExoticaInvasora.new(exotica_params)
    if @exotica.save 
      guardar_catalogos
      redirect_to admin_exoticas_invasoras_path, notice: "La especie fue creada correctamente."
    else
      render :new
    end
  end
  
  def edit
  end

  def update
    if @exotica.update(exotica_params)
      guardar_catalogos
      redirect_to admin_exoticas_invasoras_path, notice: "La especie fue actualizada correctamente."
    else
      render :edit
    end
  end

  def destroy
    @exotica.destroy
    redirect_to admin_exoticas_invasoras_path, notice: "La especie fue eliminada correctamente."
  end

  private

  def set_exotica
    @exotica = ExoticaInvasora.find(params[:id])
  end

  def guardar_catalogos
    @catalogos.each_key do |tipo|
      ids = params.dig(:exotica_invasora, "#{tipo}_ids")
      @exotica.guardar_catalogos(tipo, ids)
    end
  end

  def carga_catalogos
    @catalogos = ExoticaCatalogo.activos.where.not(tipo: "tipo_documento").group_by(&:tipo)
    @tipos_documento = ExoticaCatalogo.tipos_documento
  end

  def exotica_params
    params.require(:exotica_invasora).permit(:especie_id, :creditos_fotos, :observaciones,
      documentos_attributes: [
        :id,
        :tipo_documento_id,
        :archivo,
        :_destroy
      ]
    )
  end
end

