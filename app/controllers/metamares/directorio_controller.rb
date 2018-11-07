class Metamares::DirectorioController < Metamares::MetamaresController

  #before_action :authenticate_usuario!
  #before_action  do
  #  tiene_permiso?('AdminMetamares')  # Minimo administrador
  #end

  before_action :set_directorio, except: [:index, :new]

  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @directorio = Metamares::Directorio.new(directorio_params)

    respond_to do |format|
      if @directorio.save
        format.html { redirect_to @directorio, notice: 'Los datos se actualizaron exitosamente.' }
        format.json { render action: 'show', status: :created, location: @directorio }
      else
        format.html { render action: 'new' }
        format.json { render json: @estatuse.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @directorio.update(usuario_params)
        format.html { redirect_to metamares_directorio_index_path, notice: 'Los datos se actualizaron exitosamente' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @estatuse.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @directorio.destroy
    respond_to do |format|
      format.html { redirect_to estatuses_url }
      format.json { head :no_content }
    end
  end


  private

  def directorio_params
    params.require(:directorio).permit(:nombre, :apellido, :email, :institucion, :password, :password_confirmation,
                                    usuario_roles_attributes: [:id, :usuario_id, :rol_id, :done, :_destroy])
  end

  def set_directorio
    begin
      @directorio = Metamares::Directorio.find(params[:id])
    rescue
      render :_error and return
    end
  end

end
