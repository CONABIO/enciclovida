class Admin::ExoticasInvasorasController < Admin::AdminController
  
  before_action :carga_catalogos, only: [:new, :create, :edit, :update]
  before_action :set_exotica, only: [:edit, :update, :destroy]

  def index
    @exoticas = ExoticaInvasora.includes(:especie, :grupo, :ambiente, :origen, :presencia, :estatus, :catalogos ).order(created_at: :desc)
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
    @exotica.guardar_catalogos( "ruta", params.dig(:exotica_invasora, :ruta_ids))
    @exotica.guardar_catalogos( "instrumento", params.dig(:exotica_invasora, :instrumento_ids))
  end

  def carga_catalogos
    @grupos        = ExoticaCatalogo.grupos
    @ambientes     = ExoticaCatalogo.ambientes
    @origenes      = ExoticaCatalogo.origenes
    @presencias    = ExoticaCatalogo.presencias
    @estatuses     = ExoticaCatalogo.estatuses
    @rutas         = ExoticaCatalogo.rutas
    @instrumentos  = ExoticaCatalogo.instrumentos
    @tipos_documento = ExoticaCatalogo.tipos_documento
  end

  def exotica_params
    params.require(:exotica_invasora).permit(
      :especie_id,
      :grupo_id,
      :ambiente_id,
      :origen_id,
      :presencia_id,
      :estatus_id,
      :creditos_fotos,
      :observaciones,

      documentos_attributes: [
        :id,
        :tipo_documento_id,
        :archivo,
        :_destroy
      ]
    )
  end
end

