class Admin::ExoticasCatalogosController < Admin::AdminController

  def index
    @catalogos = ExoticaCatalogo.order(:tipo, :orden, :nombre)
  end

  def new
    @catalogo = ExoticaCatalogo.new
  end

  def create
    @catalogo = ExoticaCatalogo.new(catalogo_params)

    if @catalogo.save
      redirect_to admin_exoticas_catalogos_path,
                  notice: "El catálogo fue creado correctamente."
    else
      render :new
    end
  end

  def edit
    @catalogo = ExoticaCatalogo.find(params[:id])
  end

  def update
    @catalogo = ExoticaCatalogo.find(params[:id])

    if @catalogo.update(catalogo_params)
      redirect_to admin_exoticas_catalogos_path,
                  notice: "El catálogo fue actualizado correctamente."
    else
      render :edit
    end
  end

  def destroy
    @catalogo = ExoticaCatalogo.find(params[:id])
    @catalogo.destroy

    redirect_to admin_exoticas_catalogos_path,
                notice: "El catálogo fue eliminado correctamente."
  end

  private

  def catalogo_params
    params.require(:exotica_catalogo).permit(
      :tipo,
      :clave,
      :nombre,
      :descripcion,
      :activo,
      :orden
    )
  end

end