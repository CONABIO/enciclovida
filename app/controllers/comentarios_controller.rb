class ComentariosController < ApplicationController
  skip_before_filter :set_locale, only: [:show, :new, :create, :update, :destroy, :update_admin]
  before_action :set_comentario, only: [:show, :edit, :update, :destroy, :update_admin]
  before_action :authenticate_usuario!, :except => [:new, :create]
  before_action :only => [:index, :show, :update, :edit, :destroy, :admin, :update_admin] do
    permiso = tiene_permiso?(100)  # Minimo administrador
    render :_error unless permiso
  end

  layout false, only:[:update, :show]

  # GET /comentarios
  # GET /comentarios.json
  def index
    @comentarios = Comentario.all
  end

  # GET /comentarios/1
  # GET /comentarios/1.json
  # Despliega el historial del comentario, solo estatus 1,2
  def show
    cuantos = @comentario.descendants.count

    if cuantos > 0
      resp = @comentario.descendants.map{ |c|

        if usuario = c.usuario
          nombre = "#{usuario.nombre} #{usuario.apellido}"
          correo = usuario.email
        else
          nombre = c.nombre
          correo = c.correo
        end

        { id: c.id, especie_id: c.especie_id, comentario: c.comentario, nombre: nombre, correo: correo, created_at: c.created_at, estatus: c.estatus }
      }

      @comentarios = {estatus:1, cuantos: cuantos, resp: resp}

    else
      @comentarios = {estatus:1, cuantos: cuantos}
    end

    # Para saber el ancestry antes de sobreescribir a @comentario
    ancestry = if @comentario.is_root?
                             @comentario.id
                           else
                             "#{@comentario.ancestry}/#{@comentario.id}"
                           end

    nombre = @comentario.nombre
    correo = @comentario.correo
    usuario_id = @comentario.usuario_id

    especie_id = @comentario.especie_id

    # Para crear el form del un comentario al final del historial de comentarios
    @comentario = Comentario.new(especie_id: @especie_id)
    @comentario.usuario_id = current_usuario.id

    # Estatus 2 quiere decir que es parte del historial de un comentario
    @comentario.estatus = 2

    # Para no poner la caseta de verificacion
    @comentario.con_verificacion = false

    # Proviene de un administrador
    @comentario.es_admin = true

    # Asigna el ancestry
    @comentario.ancestry = ancestry

    # Datos personales
    @comentario.nombre = nombre
    @comentario.correo = correo
    @comentario.usuario_id = usuario_id

    # Asigna la especie
    @comentario.especie_id = especie_id
  end

  # GET /comentarios/new
  def new
    @especie_id = params[:especie_id]
    @comentario = Comentario.new
    @comentario.con_verificacion = true
  end

  # GET /comentarios/1/edit
  def edit
  end

  # POST /comentarios
  # POST /comentarios.json
  def create
    @especie_id = params[:especie_id]
    @comentario = Comentario.new(comentario_params.merge(especie_id: @especie_id))

    params = comentario_params

    respond_to do |format|
      if params[:con_verificacion].present? && params[:con_verificacion] == '1'
        if verify_recaptcha(:model => @comentario, :message => t('recaptcha.errors.missing_confirm')) && @comentario.save
          if params[:es_admin].present? && params[:es_admin] == '1'
            format.json {render json: {estatus: 1}.to_json}
          else
            format.html { redirect_to especie_path(@especie_id), notice: '¡Gracias! Tu comentario fue enviado satisfactoriamente.' }
          end

        else
          if params[:es_admin].present? && params[:es_admin] == '1'
            format.json {render json: {estatus: 0}.to_json}
          else
            format.html { render action: 'new' }
          end
        end

      # Para evitar el google captcha a los usuarios administradores, la respuesta siempre es en json
      else
        if @comentario.save
          format.json {render json: {estatus: 1}.to_json}
        else
          format.json {render json: {estatus: 0}.to_json}
        end

      end  # end con_verificacion
    end  # end tipo response
  end

  # PATCH/PUT /comentarios/1
  # PATCH/PUT /comentarios/1.json
  def update
    if params[:estatus].present?
      @comentario.estatus = params[:estatus]
      @comentario.usuario_id2 = current_usuario.id
      @comentario.fecha_estatus = Time.now
    end

    @comentario.categoria_comentario_id = params[:categoria_comentario_id] if params[:categoria_comentario_id].present?

    if @comentario.save
      render json: {estatus: 1}.to_json
    else
      render json: {estatus: 0}.to_json
    end
  end

  # DELETE /comentarios/1
  # DELETE /comentarios/1.json
  def destroy
    @comentario.resuelto = 3

    if @comentario.save
      render text: '1'
    else
      render text: '0'
    end
  end

  # Administracion de los comentarios
  def admin
    if params[:comentario].present?
      params = comentario_params
      consulta = 'Comentario'

      if params[:categoria_comentario_id].present?
        consulta << ".where(categoria_comentario_id: #{params[:categoria_comentario_id].to_i})"
      end

      if params[:estatus].present?
        consulta << ".where(estatus: #{params[:estatus].to_i})"
      end

      # Para ordenar por created_at
      if params[:created_at].present?
        @comentarios = eval(consulta).where('estatus < 4').order("created_at #{params[:created_at]}")
      else
        @comentarios = eval(consulta).where('estatus < 4').order('estatus ASC, created_at ASC')
      end

    else
      # estatus > 3 quiere decir oculto a la vista
      @comentarios = Comentario.where('estatus < 4').order('estatus ASC, created_at ASC')
    end

    @comentarios.each do |c|
      c.cuantos = c.descendants.count
      c.completa_nombre_correo_especie
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_comentario
    @comentario = Comentario.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comentario_params
    params.require(:comentario).permit(:comentario, :usuario_id, :correo, :nombre, :estatus, :ancestry,
                                       :con_verificacion, :especie_id, :categoria_comentario_id, :created_at)
  end
end
