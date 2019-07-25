class ComentariosController < ApplicationController

  before_action do
    @no_render_busqueda_basica = true
  end

  skip_before_action :set_locale, only: [:respuesta_externa, :create, :update, :destroy, :update_admin, :ultimo_id_comentario]
  before_action :set_comentario, only: [:show, :respuesta_externa, :edit, :update, :destroy, :update_admin, :ultimo_id_comentario]
  before_action :authenticate_usuario!, :except => [:new, :create, :respuesta_externa, :show, :extrae_comentarios_generales]
  before_action :only => [:index, :update, :edit, :destroy, :admin, :update_admin, :show_correo, :ultimo_id_comentario] do
    tiene_permiso?('AdminComentarios', true)  # Minimo administrador de comentarios
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

  #Show de los comentarios SIN LAYOUT (fichas, respuesta externa y admin)
  def show
    @ficha = (params[:ficha].present? && params[:ficha] == '1')

    cuantos = @comentario.descendants.count
    categoriaContenido = @comentario.categorias_contenido_id

    if cuantos > 0
      resp = @comentario.descendants.map{ |c|
        c.completa_info(@comentario.usuario_id)
        c
      }

      @comentarios = {estatus:1, cuantos: cuantos, resp: resp}

    else
      @comentarios = {estatus:1, cuantos: cuantos}
    end

    # Para saber el id del ultimo comentario, antes de sobreescribir a @comentario
    ultimo_comentario = @comentario.subtree.order('ancestry ASC').map(&:id).reverse.first

    # Especie
    especie_id = @comentario.especie_id

    # Crea el nuevo comentario con las clases de la gema ancestry
    @comentario = Comentario.children_of(ultimo_comentario).new

    # El ID del administrador
    @comentario.usuario_id = current_usuario.id unless @ficha

    # Estatus 6 quiere decir que es parte del historial de un comentario
    @comentario.estatus = Comentario::RESPUESTA

    # Categoria comentario ID
    @comentario.categorias_contenido_id = categoriaContenido

    # Para no poner la caseta de verificacion
    @comentario.con_verificacion = false

    # Proviene de un administrador
    @comentario.es_admin = true

    # Asigna la especie
    @comentario.especie_id = especie_id
  end

  #Show cuando alguien externo responde a CONABIO
  def respuesta_externa
    @comentario_root = @comentario.root
    @comentario_root.completa_info(@comentario_root.usuario_id)
    @especie_id = params[:especie_id] || 0  # Si es cero, es porque era un comentario general y lo cambiaron de tipo de comentario
    @ficha = (params[:ficha].present? && params[:ficha] == '1')

    # Si es una respuesta de usuario o es para mostrar en la ficha
    if (params[:created_at].present? && @comentario_root.created_at.strftime('%d-%m-%y_%H-%M-%S') != params[:created_at])
      render :file => '/public/404.html', :status => 404, :layout => false
    else

      @comentario_resp = @comentario
      cuantos = @comentario_root.descendant_ids.count
      categoriaContenido = @comentario.categorias_contenido_id

      #Esto es para que en el show se muestre el primer comentario ALWAYS (el seguro está en preguntar si resp.present?)
      @comentario_root.completa_info(@comentario_root.usuario_id)
      resp = [@comentario_root]

      if cuantos > 0
        resp = resp + @comentario.descendants.map{ |c|
          c.completa_info(@comentario_root.usuario_id)
          c
        }
      end

      # Como resp ya esta seteado desde arriba, ya no es necesario mandar uno distinto si cuantos == 0
      @comentarios = {estatus:1, cuantos: cuantos, resp: resp}

      # Para crear el comentario si NO es el render de la ficha
      if @ficha
        render 'show', layout: false
      else

        if Comentario::RESUELTOS.include?(@comentario_root.estatus)  #Marcado como resuleto
          @sin_caja = true
        elsif Comentario::OCULTAR == @comentario_root.estatus  # Marcado como eliminado
          @eliminado = true
        elsif Comentario::MODERADOR == @comentario_root.estatus  # Marcado como eliminado
          @moderador = true
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
          @comentario.estatus = Comentario::RESPUESTA

          # Categoria comentario ID
          @comentario.categorias_contenido_id = categoriaContenido

          # Caseta de verificacion
          @comentario.con_verificacion = true

          # Proviene de un administrador
          @comentario.es_admin = false

          # Si es una respuesta de un usuario
          @comentario.es_respuesta = true

          # Asigna la especie
          @comentario.especie_id = @comentario_resp.especie_id
        end  # end si no es un comenatrio resuelto

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
    tipo_proveedor = params[:tipo_proveedor]
    proveedor_id = params[:proveedor_id]
    params = comentario_params

    respond_to do |format|
      if params[:con_verificacion].present? && params[:con_verificacion] == '1'
        if (verify_recaptcha(:model => @comentario, :message => t('recaptcha.errors.missing_confirm')) && @comentario.save) || (!Rails.env.production? && @comentario.save)

          if params[:es_respuesta].present? && params[:es_respuesta] == '1'
            comentario_root = @comentario.root
            @comentario.completa_info(comentario_root.usuario_id)

            # Enviar a los responsables de contenido si es que el usuario siguio la charla
            EnviaCorreo.avisar_responsable_contenido(@comentario, dame_usuarios_envio).deliver

            format.json {render json: {estatus: 1, created_at: @comentario.created_at.strftime('%d/%m/%y-%H:%M'),
                                       nombre: @comentario.nombre}.to_json}
          else
            # Para guardar en la tabla comentarios proveedores
            if proveedor_id.present? && CategoriasContenido::REGISTROS_GEODATA.include?(tipo_proveedor)
              comentario_proveedor = ComentarioProveedor.new
              comentario_proveedor.comentario_id = @comentario.id
              comentario_proveedor.proveedor_id = proveedor_id
              comentario_proveedor.save
            end

            EnviaCorreo.confirmacion_comentario(@comentario).deliver

            # No  SÓLO aquí es donde hay q poner el envio a los responsables de contenido (también allá arriba cuando un usuario responde)
            EnviaCorreo.avisar_responsable_contenido(@comentario, dame_usuarios_envio).deliver if dame_usuarios_envio.present?
            
            format.html { redirect_to especie_path(@especie_id), notice: '¡Gracias! Tu comentario fue enviado satisfactoriamente y lo podrás ver en la ficha una vez que pase la moderación pertinente.' }
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
          else  # Si fue un comentario en la plataforma de administración de comentarios (IMPORTANTE!!)
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
    ya_estaba_resuelto = Comentario::RESUELTOS.include?(@comentario.estatus) #Ya estaba en algun estatus de resuleto?
    if params[:estatus].present?
      @comentario.estatus = params[:estatus]
      @comentario.usuario_id2 = current_usuario.id
      @comentario.fecha_estatus = Time.now
    end

    @comentario.categorias_contenido_id = params[:categorias_contenido_id] if params[:categorias_contenido_id].present?

    if @comentario.changed? && @comentario.save
      if Comentario::RESUELTOS.include?(@comentario.estatus)
        EnviaCorreo.comentario_resuelto(@comentario).deliver unless ya_estaba_resuelto #Solo envia correo cuando cambia el estatus
      end
      if params[:categorias_contenido_id].present?
        EnviaCorreo.avisar_responsable_contenido(@comentario, dame_usuarios_envio).deliver
      end
      render json: {estatus: 1}.to_json
    else
      render json: {estatus: 0}.to_json
    end
  end

  # DELETE /comentarios/1
  # DELETE /comentarios/1.json
  def destroy
    @comentario.estatus = Comentario::OCULTAR

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

    tax_especifica = current_usuario.usuario_especies
    contenido_especifico = current_usuario.categorias_contenidos

    consulta = Comentario.datos_basicos

    if params[:comentario].present?
      params = comentario_params

      if params[:categorias_contenido_id].present?
        consulta = consulta.where(categorias_contenido_id: params[:categorias_contenido_id].to_i)
      end

      if params[:estatus].present?
        consulta = consulta.where('comentarios.estatus = ?', params[:estatus].to_i)
      else
        consulta = consulta.where('comentarios.estatus < ?', Comentario::OCULTAR)
      end
      if tax_especifica.length > 0
        or_taxa = []
        tax_especifica.each do |e|
          or_taxa << " #{Especie.attribute_alias(:id)} = #{e.especie_id}"
          or_taxa << " #{Especie.attribute_alias(:ancestry_ascendente_directo)} LIKE '%#{e.especie_id}%' "
        end
        consulta = consulta.where(or_taxa.join(' OR '))
      end

      if contenido_especifico.length > 0
        consulta = consulta.where(:categorias_contenido_id => contenido_especifico.map(&:subtree_ids).flatten)
      end

      # Comentarios totales
      @totales = consulta.count(:all)

      # Para ordenar por created_at, nombre_cientifico o ambos
      if params[:created_at].present? && params[:nombre_cientifico].present?
        consulta = consulta.order("#{Especie.attribute_alias(:nombre_cientifico)} #{params[:nombre_cientifico]}, comentarios.created_at #{params[:created_at]}")
      elsif params[:created_at].present?
        consulta = consulta.order("comentarios.created_at #{params[:created_at]}")
      elsif params[:nombre_cientifico].present?
        consulta = consulta.order("#{Especie.attribute_alias(:nombre_cientifico)} #{params[:nombre_cientifico]}")
      else
        consulta = consulta.order('comentarios.created_at DESC')
      end

      @comentarios = consulta.offset(offset).limit(@por_pagina)

    else
      # estatus = 5 quiere decir oculto a la vista
      consulta = consulta.where('comentarios.estatus < ?', Comentario::OCULTAR)
      if tax_especifica.length > 0
        or_taxa = []
        tax_especifica.each do |e|
          or_taxa << " #{Especie.attribute_alias(:id)} = #{e.especie_id}"
          or_taxa << " #{Especie.attribute_alias(:ancestry_ascendente_directo)} LIKE '%#{e.especie_id}%' "
          end
        consulta = consulta.where(or_taxa.join(' OR '))
      end
      if contenido_especifico.length > 0
        consulta = consulta.where(:categorias_contenido_id => contenido_especifico.map(&:subtree_ids).flatten)
      end
      # Comentarios totales
      @totales = consulta.count(:all)
      @comentarios = consulta.order('comentarios.created_at DESC').offset(offset).limit(@por_pagina)
    end

    @comentarios.each do |c|
      c.cuantos = c.descendants.count
      c.completa_info(c.root.usuario_id)
    end

    @categorias_contenido = CategoriasContenido.grouped_options

    response.headers['x-total-entries'] = @totales.to_s

    if (@pagina > 1 && @comentarios.any?) || (params.present? && params[:ajax].present? && params[:ajax] == '1')
      # Tiene resultados el scrollling o peticiones de ajax
      render :partial => 'comentarios/admin'
    elsif @pagina > 1 && @comentarios.empty?  # Fin del scrolling
      render text: ''
    end

  end

  # Extrae los correos de la cuenta enciclovida@conabio.gob.mx y los guarda en la base
  # en el formato de la tabla comentarios para tener un front-end adminsitrable
  def extrae_comentarios_generales
    procesa_correos({mborigen: @folder[:inbox], mbdestino: @folder[:pendientes], delete: true})
    render text: 'Procesados'
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
    comment.categorias_contenido_id = CategoriasContenido::COMENTARIO_ENCICLOVIDA
    comment.created_at = correo.header[:date].value.to_time

    if tiene_id
      id_original = correo.subject.slice!(/###\[[[:alnum:]]+\]###/).slice!(/[[:alnum:]]+/)
      comentario_root = Comentario.find(id_original)
      comment.estatus = Comentario::RESPUESTA
      comment.ancestry = comentario_root.subtree_ids.join('/')


      #NO HACERSE BOLAS CON all ESTO, ESCRIBIRLO BONITO
      #Rails.logger.debug "\ncomment.ancestry: "+comment.ancestry
      papa_inmediato = comment.ancestry.split('/').last
      #Rails.logger.debug "\npapa_inmediato: "+papa_inmediato
      correo_nuevo = dame_textos(Nokogiri::HTML(correo.html_part.decoded.gsub("html>", "jtml>")))
      #Rails.logger.debug "\ncorreo_nuevo.to_s: "+correo_nuevo.to_s
      correo_nuevo2 = correo_nuevo.join('|').gsub("\r","")
      #Rails.logger.debug "\ncorreo_nuevo2: "+correo_nuevo2
      historial_correos = eval(Comentario.find(papa_inmediato).general.commentArray).join('|').gsub("\r","")
      #Rails.logger.debug "\nhistorial_correos: "+historial_correos
      correo_nuevo2.slice!(historial_correos)
      #Rails.logger.debug "\ncorreo_nuevo2: "+correo_nuevo2
      comment.comentario = correo_nuevo2.gsub("|","\n")

    else
      comment.comentario = correo.html_part.decoded
    end

    if comment.save
      correo.subject = correo.subject.to_s + "###[#{tiene_id ? id_original : comment.id}]###"
      comment.general.update_column(:subject, correo.subject.codifica64)
      comment.general.update_column(:commentArray, (correo_nuevo.present? ? (correo_nuevo.to_s) : dame_textos(Nokogiri::HTML(correo.html_part.decoded.gsub("html>", "jtml>"))).to_s ))
      EnviaCorreo.confirmacion_comentario_general(comment).deliver if !tiene_id ##para usar el mailer de calonso de confirmación
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
        "<strong>Su comentario enviado a EncicloVida ha sido contestado </strong>"+
        "</div><br /><br />"+
        "<div style='font-style: italic; font-size:larger;'>#{mensaje}</div><br /><br />"+
        "<div>"+
        "<p style='font-size:smaller;'>Gracias por usar nuestra plataforma.<br />" +
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
    params.require(:comentario).permit(:comentario, :usuario_id, :correo, :nombre, :estatus, :ancestry, :institucion,
                                       :con_verificacion, :es_admin, :es_respuesta, :especie_id, :categorias_contenido_id,
                                       :ajax, :nombre_cientifico, :created_at)
  end

  #Dado un comentario, regresa un array con los correos a los cuales se tiene q enviar de acuerdo a los responsables tanto del contenido como de taxonomía específica
  # Por último, TODO, All this debería ir en el modelo de comentarios!!!!!!
  def dame_usuarios_envio

    #Dado una categorias_contenido_id, dame esa y las catagorías papás (las categorias responsables de dicho comentario)
    categorias_responsables = CategoriasContenido.find(@comentario.categorias_contenido_id).path_ids

    #Dame los ascendientes de la especie del comentario si es que tiene una taxonomía asignada, asigno [0] si es comentario general (no tiene un taxon asignado el comentario y sólo se envien a quien son sabelotodos)
    path_especie = @comentario.especie.present? ? @comentario.especie.path_ids : [0]

    #Dame los usuarios que son responsables de dichas CategoriasContenidos (Los objeto Usuarios ya que abajo requiero distintos para sacar la taxonomia asociada)
    usuarios_categorias = Usuario.join_userRolEspeciesCategoriasContenido.where('categorias_contenido.id' => categorias_responsables)

    #Si de los encargados de las categorias, no tienen ninguna taxonomía especifica, entonces es sabelotodo y lo agregamos o lo agregamos si su taxonomía específica pertenece al path de la especie del comentario, (si el usuario tiene taxonomía especifica y es comentario general, entonces dicho usuario se skippea)
    usuarios_especie = usuarios_categorias.map{|u| u if( u.especies.empty? || path_especie.include?(u.id_especie) ) }.compact.map(&:email)

    #Si te metiste en la conversacion tambien te envio correo
    usuarios_metiches =  @comentario.is_root? ? [] : Usuario.where('id' => @comentario.ancestors.drop(1).map(&:usuario_id)).map(&:email)


    #Alternativamente se puede realizar UN SÓLO query a la BD, pero creo que aún hay q probar exhaustivamente
    #En tal caso, usuarios_categorias no se ocuparía
    #usuarios_envio = Usuario.join_userRolEspeciesCategoriasContenido.where('categorias_contenido.id' => categorias_responsables).where.not("especies.id NOT IN (?) AND especies.id IS NOT NULL", path_especie).map(&:email).uniq

    #Rails.logger.debug '------------------UE-----------------------'+usuarios_envio.inspect
    (usuarios_especie + usuarios_metiches).uniq
  end

end