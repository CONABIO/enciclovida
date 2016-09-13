class ComentariosController < ApplicationController
  skip_before_filter :set_locale, only: [:show, :respuesta_externa, :new, :create, :update, :destroy, :update_admin, :ultimo_id_comentario]
  before_action :set_comentario, only: [:show, :respuesta_externa, :edit, :update, :destroy, :update_admin, :ultimo_id_comentario]
  before_action :authenticate_usuario!, :except => [:new, :create, :respuesta_externa]
  before_action :only => [:index, :show, :update, :edit, :destroy, :admin, :update_admin, :extrae_comentarios_generales, :show_correo, :ultimo_id_comentario] do
    permiso = tiene_permiso?(100)  # Minimo administrador
    render :_error unless permiso
  end

  before_action :only => [:extrae_comentarios_generales, :show_correo, :admin, :show, :create] do
    @xolo_url = "https://#{CONFIG.smtp.user_name}:#{CONFIG.smtp.password}@#{CONFIG.smtp.address}/home/enciclovida/"
    @folder = Rails.env.production? ? {inbox: 'INBOX', pendientes: 'Pendientes', resueltos: 'Resueltos', sent: 'SENT'} : {inbox: 'INBOXDEV', pendientes: 'PendientesDEV', resueltos: 'ResueltosDEV', sent: 'SENTDEV'}
  end

  layout false, only:[:update, :show, :dame_correo, :ultimo_id_comentario]


  # GET /comentarios
  # GET /comentarios.json
  def index
    @comentarios = Comentario.all
  end

  # GET /comentarios/1
  # GET /comentarios/1.json
  # Show de la vista de admins
  def show
    @ficha = if params[:ficha].present?
               params[:ficha] == '1' ? true : false
             else
               false
             end
    #las lineas de acá arriba no se puede sustituir por:
    #@ficha = (params[:ficha].present? && params[:ficha] == '1')

    cuantos = @comentario.descendants.count
    categoriaComentario = @comentario.categoria_comentario_id

    #if !@comentario.general
      if cuantos > 0
        resp = @comentario.descendants.map{ |c|
          c.completa_info(@comentario.usuario_id)
          c
        }

        @comentarios = {estatus:1, cuantos: cuantos, resp: resp}

      else
        @comentarios = {estatus:1, cuantos: cuantos}
      end
    #end

    # Para saber el id del ultimo comentario, antes de sobreescribir a @comentario
    ultimo_comentario = @comentario.subtree.order('ancestry ASC').map(&:id).reverse.first

    # Especie
    especie_id = @comentario.especie_id

    # Crea el nuevo comentario con las clases de la gema ancestry
    @comentario = Comentario.children_of(ultimo_comentario).new

    # El ID del administrador
    @comentario.usuario_id = current_usuario.id

    # Estatus 6 quiere decir que es parte del historial de un comentario
    @comentario.estatus = 6

    # Categoria comentario ID
    @comentario.categoria_comentario_id = categoriaComentario

    # Para no poner la caseta de verificacion
    @comentario.con_verificacion = false

    # Proviene de un administrador
    @comentario.es_admin = true

    # Asigna la especie
    @comentario.especie_id = especie_id
  end

  #Show cuando alguien externo responde a CONABIO
  def respuesta_externa
    comentario_root = @comentario.root

    @ficha = if params[:ficha].present?
               params[:ficha] == '1' ? true : false
             else
               false
             end

    # Si es una respuesta de usuario o es para mostrar en la ficha
    if (params[:created_at].present? && comentario_root.created_at.strftime('%d-%m-%y_%H-%M-%S') != params[:created_at])
      render :file => '/public/404.html', :status => 404, :layout => false
    else

      @comentario_resp = @comentario
      cuantos = comentario_root.descendant_ids.count

      if cuantos > 0
        resp = @comentario.descendants.map{ |c|
          c.completa_info(comentario_root.usuario_id)
          c
        }

        @comentarios = {estatus:1, cuantos: cuantos, resp: resp}

      else
        @comentarios = {estatus:1, cuantos: cuantos}
      end

      # Para crear el comentario si NO es el render de la ficha
      if @ficha
        render 'show', layout: false
      else
        # Para saber el id del ultimo comentario, antes de sobreescribir a @comentario
        ultimo_comentario = @comentario_resp.subtree.order('ancestry ASC').map(&:id).reverse.first

        # Crea el nuevo comentario con las clases de la gema ancestry
        @comentario = Comentario.children_of(ultimo_comentario).new

        # Datos del usuario
        @comentario.usuario_id = @comentario_resp.usuario_id
        @comentario.nombre = @comentario_resp.nombre
        @comentario.correo = @comentario_resp.correo
        @comentario.institucion = @comentario.institucion

        # Estatus 6 quiere decir que es parte del historial de un comentario
        @comentario.estatus = 6

        # Categoria comentario ID
        @comentario.categoria_comentario_id = 26

        # Caseta de verificacion
        @comentario.con_verificacion = true

        # Proviene de un administrador
        @comentario.es_admin = false

        # Si es una respuesta de un usuario
        @comentario.es_respuesta = true

        # Asigna la especie
        @comentario.especie_id = @comentario_resp.especie_id

        render 'show'
      end

    end
  end

  # GET /comentarios/new
  def new
    @especie_id = params[:especie_id]

    if @especie_id.present?
      begin
        @especie = Especie.find(@especie_id)
      end

    end

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

    if @especie_id.present?  && @especie_id != '0'
      begin
        @especie = Especie.find(@especie_id)
      end
    else
      @especie = 0
    end

    @comentario = Comentario.new(comentario_params.merge(especie_id: @especie_id))
    params = comentario_params

    respond_to do |format|
      if params[:con_verificacion].present? && params[:con_verificacion] == '1'
        if (verify_recaptcha(:model => @comentario, :message => t('recaptcha.errors.missing_confirm')) && @comentario.save) || (!Rails.env.production? && @comentario.save)

          if params[:es_respuesta].present? && params[:es_respuesta] == '1'
            comentario_root = @comentario.root
            @comentario.completa_info(comentario_root.usuario_id)

            format.json {render json: {estatus: 1, created_at: @comentario.created_at.strftime('%d/%m/%y-%H:%M'),
                                       nombre: @comentario.nombre}.to_json}
          else
            EnviaCorreo.confirmacion_comentario(@comentario).deliver
            format.html { redirect_to especie_path(@especie_id), notice: '¡Gracias! Tu comentario fue enviado satisfactoriamente.' }
          end

        else
          # Hubo un error al enviar el formulario
          if params[:es_respuesta].present? && params[:es_respuesta] == '1'
            format.json {render json: {estatus: 0}.to_json}
          else
            format.html { render action: 'new' }
          end

        end

      # Para evitar el google captcha a los usuarios administradores, la respuesta siempre es en json
      else
        if params[:es_admin].present? && params[:es_admin] == '1' && @comentario.save
          if @comentario.root.general  # Si es comentario general
            envia_correo(@comentario)
          else  # Si fue un comentario en la plataforma
            EnviaCorreo.respuesta_comentario(@comentario).deliver
          end
          if usuario=@comentario.usuario
            nombre = usuario.nombre + usuario.apellido
          end
          created_at = @comentario.created_at.strftime('%d/%m/%y-%H:%M')
          format.json {render json: {estatus: 1, ancestry: "#{@comentario.ancestry}/#{@comentario.id}", nombre: nombre, created_at:  created_at ||= '' }.to_json}
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

    if @comentario.changed? && @comentario.save
      if Comentario::RESUELTOS.include?(@comentario.estatus)
        EnviaCorreo.comentario_resuelto(@comentario).deliver
      end

      render json: {estatus: 1}.to_json
    else
      render json: {estatus: 0}.to_json
    end
  end

  # DELETE /comentarios/1
  # DELETE /comentarios/1.json
  def destroy
    @comentario.estatus = 5

    if @comentario.save
      render text: '1'
    else
      render text: '0'
    end
  end

  # Administracion de los comentarios GET /comentarios/administracion
  def admin
    @pagina = params[:pagina].present? ? params[:pagina].to_i : 1
    @por_pagina = params[:por_pagina].present? ? params[:por_pagina].to_i : Comentario::POR_PAGINA_PREDETERMINADO
    offset = (@pagina-1)*@por_pagina

    procesa_correos({mborigen:  @folder[:inbox], mbdestino: @folder[:pendientes], delete: true})
    #procesa_correos({mborigen: 'Pendientes', mbdestino: 'Resueltos', delete: true})

    if params[:comentario].present?
      params = comentario_params
      consulta = 'Comentario.datos_basicos'

      if params[:categoria_comentario_id].present?
        consulta << ".where(categoria_comentario_id: #{params[:categoria_comentario_id].to_i})"
      end

      if params[:estatus].present?
        consulta << ".where('comentarios.estatus=#{params[:estatus].to_i}')"
      end

      consulta << ".where('comentarios.estatus < 5')"

      # Comentarios totales
      @totales = eval(consulta).count

      sql = eval(consulta).to_sql

      # Para ordenar por created_at
      if params[:created_at].present?
        sql = sql + " ORDER BY created_at #{params[:created_at]}"
      elsif params[:nombre_cientifico].present?
        sql = sql + " ORDER BY nombre_cientifico #{params[:nombre_cientifico]}"
      else
        sql = sql + ' ORDER BY comentarios.estatus ASC, created_at ASC'
      end

      sql+= " OFFSET #{offset} ROWS FETCH NEXT #{@por_pagina} ROWS ONLY"

    else
      # Comentarios totales
      @totales = Comentario.datos_basicos.where('comentarios.estatus < 5').count

      # estatus = 5 quiere decir oculto a la vista
      sql = Comentario.datos_basicos.where('comentarios.estatus < 5').to_sql
      sql = sql + " ORDER BY comentarios.estatus ASC, created_at ASC OFFSET #{offset} ROWS FETCH NEXT #{@por_pagina} ROWS ONLY"
    end

    @comentarios = Comentario.find_by_sql(sql)

    @comentarios.each do |c|
      c.cuantos = c.descendants.count
      c.completa_info(c.root.usuario_id)
    end

    @categoria_comentario = CategoriaComentario.grouped_options

    response.headers['x-total-entries'] = @totales.to_s

    if (@pagina > 1 && @comentarios.any?) || (params.present? && params[:ajax].present? && params[:ajax] == '1')
    # Tiene resultados el scrollling o peticiones de ajax
      render :partial => 'comentarios/admin'
    elsif @pagina > 1 && @comentarios.empty?  # Fin del scrolling
      render text: ''
    end

  end

  #Extrae los correos de la cuenta enciclovida@conabio.gob.mx y los guarda en la base
  # en el formato de la tabla comentarios para tener un front-end adminsitrable
  def extrae_comentarios_generales
   #procesa_correos({mborigen: 'INBOX', mbdestino: 'INBOXDEV', delete: false})
   procesa_correos({mborigen: @folder[:inbox], mbdestino: @folder[:pendientes], delete: true})
    response = Comentario.find_all_by_categoria_comentario_id(29)
    render 'comentarios/generales', :locals => {:response => response}
  end

  def show_correo
    render text: dame_correo(params[:id]).html_part.decoded
  end

  private

  def procesa_correos(opts={}) #carpeta entera
    Mail.find(count: 1000, mailbox: opts[:mborigen], order: :asc, delete_after_find: opts[:delete]||=false, keys: opts[:search]||='ALL') { |m|
      guarda_correo_bd(m)
      copia_correo(m, opts[:mbdestino])
    }
  end

  def guarda_correo_bd(correo)
    comment = Comentario.new

    tiene_id = correo.subject.to_s.include?('###[') && correo.subject.to_s.include?(']###')#correo.subject.to_s.include?('###[')


    comment.correo = correo.from.first#.encode('ASCII-8BIT').force_encoding('UTF-8')
    comment.nombre = correo.header[:from].display_names.join(',')
    comment.especie_id = 0
    comment.categoria_comentario_id = 29
    comment.created_at = correo.header[:date].value.to_time

    if tiene_id
      id_original = correo.subject.slice!(/###\[[[:alnum:]]+\]###/).slice!(/[[:alnum:]]+/)
      comentario_root = Comentario.find(id_original)
      comment.estatus = 6
      comment.ancestry = comentario_root.subtree_ids.join('/')

      #Linea ya no necesaria, ya que  ¬¬ si tendre que hacer diferenciación, pero con un array de string (thx caloncho)
      #comment.comentario = dame_primer_texto(Nokogiri::HTML(correo.html_part.decoded.gsub("html", "oldhtml")))

      #NO HACERSE BOLAS CON all ESTO, ESCRIBIRLO BONITO
      puts "\ncomment.ancestry: "+comment.ancestry
      papa_inmediato = comment.ancestry.split('/').last
      puts "\npapa_inmediato: "+papa_inmediato
      correo_nuevo = dame_textos(Nokogiri::HTML(correo.html_part.decoded.gsub("html>", "jtml>")))
      puts "\ncorreo_nuevo.to_s: "+correo_nuevo.to_s
      correo_nuevo2 = correo_nuevo.join('|').gsub("\r","")
      puts "\ncorreo_nuevo2: "+correo_nuevo2
      historial_correos = eval(Comentario.find(papa_inmediato).general.commentArray).join('|').gsub("\r","")
      puts "\nhistorial_correos: "+historial_correos
      correo_nuevo2.slice!(historial_correos)
      puts "\ncorreo_nuevo2: "+correo_nuevo2
      comment.comentario = correo_nuevo2.gsub("|","\n")

      #inicio_correos_viejos = comment.comentario.index(/\*\*\*::[[:print:]]+::\*\*\*/)
      #comment.comentario = comment.comentario[0..inicio_correos_viejos]

    else
      #comment.comentario = correo.subject.codifica64 ##Para poder guardar en la bd, si se desea ver en browser hacer un force_encoding(utf-8)
      #comment.comentario = correo.text_part.decoded
      comment.comentario = correo.html_part.decoded
      #comment.comentario = dame_textos(Nokogiri::HTML(correo.html_part.decoded))
    end

    if comment.save
      correo.subject = correo.subject.to_s + "###[#{tiene_id ? id_original : comment.id}]###"
      comment.general.update_column(:subject, correo.subject.codifica64)
      ##comentario, truena pq el papa inmediato es vació pq al momento de enviar el correo no lo guardo en la tabla comentarioGral, so, arreglar ello,
      ##NOTA IMPORTANTE, LA COMA ES MAL DELIMITADOR, USAR OTRO ASAP
      comment.general.update_column(:commentArray, (correo_nuevo.present? ? (correo_nuevo.to_s) : dame_textos(Nokogiri::HTML(correo.html_part.decoded.gsub("html>", "jtml>"))).to_s ))
    end
  end

  def dame_textos html
    html.search('//text()').map(&:text).keep_if &:present? #MAGIA!!!!!! :D
  end

  def dame_primer_texto html
    resp = ''
    html.children.each do |g|
      next if (g.text == '' || (g.children.length == 0 && g.name != 'text'))
      resp = ((g.children.length == 0) && (g.name=='text')) ? g.text : (dame_primer_texto g)
      break if resp != ''
    end
    return resp
  end

  #Copia un correo en string a una carpeta dada
  def copia_correo(correo, mbdestino)
    RestClient.put(@xolo_url+mbdestino, correo.to_s)
  end

  def dame_correo(id)
    c = Comentario.find(id.to_s)
    s = "#{Base64.decode64(c.general.subject).force_encoding('UTF-8')}".force_encoding('ASCII-8BIT')
    #s = "#{s} [ID:##{c.id}]" if c.is_root?
    response = Mail.find(count: 1000, order: :asc, mailbox: @folder[:pendientes] ,delete_after_find: false, keys: ['SUBJECT', s])
    response.last  # Deberia ser solo uno, cachar si es diferente de uno
  end

  def cuerpo_correo_respuesta mensaje, to_reply
    "<div>"+
        "***:: Su comentario enviado a EncicloVida ha sido contestado ::***"+
        "</div><br /><br />"+
        "<div>#{mensaje}</div><br /><br />"+
        "<div>"+
        "<p>Gracias por usar nuestra plataforma.<br />" +
        "Le recordamos contestar (reply) a este mismo correo con la finalidad de que mantener un historial de conversación.<br />" +
        "Si tiene otra nueva duda/comentario/aportación, lo invitamos a enviar un nuevo correo y se le asignará un nuevo ticket de apoyo.<br />" +
        "¡Muchas Gracias!</p>"+
        "</div>"+
        "<br /><hr><br />"+
        "<p>En #{to_reply.header[:date].value.to_time.strftime('%d/%m/%y-%H:%M')} se escribió lo siguiente:</p>"+
        "<blockquote>"+
        to_reply.html_part.decoded.force_encoding('UTF-8')+
        "</blockquote>"
  end

  def envia_correo(comentario)
    last_received_mail = dame_correo(comentario.root.id) # doy elroot pq de todos modos jalo el último q recibí
    respuesta = last_received_mail.reply # creo la respuesta usndo la gema Mail
    respuesta_body = cuerpo_correo_respuesta(comentario.comentario, last_received_mail) # String
    respuesta.html_part = Mail::Part.new do
      content_type 'text/html; charset=UTF-8'
      body respuesta_body
    end

    respuesta.deliver if (Rails.env.production? || respuesta.to.first == 'albertoglezba@gmail.com' || respuesta.to.first.include?("@conabio.gob.mx"))
    copia_correo(respuesta.to_s, @folder[:sent])
    comentario.general.update_column(:subject, respuesta.subject.codifica64)
    comentario.general.update_column(:commentArray, dame_textos(Nokogiri::HTML(respuesta_body)).to_s)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_comentario
    @comentario = Comentario.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comentario_params
    params.require(:comentario).permit(:comentario, :usuario_id, :correo, :nombre, :estatus, :ancestry, :institucion, :con_verificacion, :es_admin, :es_respuesta, :especie_id, :categoria_comentario_id, :ajax, :nombre_cientifico, :created_at)
  end
end