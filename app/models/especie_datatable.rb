class EspecieDatatable

  delegate :params, :h, :link_to, :image_tag, :check_box_tag, :number_to_currency, to: :@view

  def is_integer?(object)
    true if Integer(object) rescue false
  end

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Especie.count,
        iTotalDisplayRecords: datosEspecies(1),
        aaData: data,
    }
  end

  private

  def data
    datosEspecies.map do |especie|
      [
          check_box_tag("box_especie_#{especie.id}", especie.id),
          especie.is_root? ? link_to(image_tag('app/32x32/zoom.png'), especie) +
              link_to(image_tag('app/32x32/edit.png'), "/especies/#{especie.id}/edit") +
              link_to(image_tag('app/32x32/trash.png'), "/especies/#{especie.id}", method: :delete, data: { confirm: '¿Estás seguro de eliminar esta especie?' }) :
              "#{link_to(image_tag('app/32x32/zoom.png'), especie)}
                  #{link_to(image_tag('app/32x32/database.png'), '', :id => "arbol_#{especie.id}", :onclick => 'return muestraArbol(this.id);')}
                  #{link_to(image_tag('app/32x32/edit.png'), "/especies/#{especie.id}/edit")}
                  #{link_to(image_tag('app/32x32/trash.png'), "/especies/#{especie.id}", method: :delete, data: { confirm: '¿Estás seguro de eliminar esta especie?' })}",
          link_to("Nuevo taxón descendiente de #{especie.nombre_cientifico}", "/especies/new?parent_id=#{especie.id}"),
          especie.id,
          especie.nombre_cientifico,
          especie.nombre_autoridad,
          link_to(especie.categoria_taxonomica_id.to_s.blank? ? 'ND' : CategoriaTaxonomica.cat_taxonom(especie.categoria_taxonomica_id),
                  "/categorias_taxonomica/#{especie.categoria_taxonomica_id}"),
          especie.is_root? ? especie.nombre_cientifico : link_to(Especie.find(especie.parent_id).nombre_cientifico, "/especies/#{especie.parent_id}"),
          especie.is_root? ? especie.nombre_cientifico : link_to(Especie.find(especie.id_ascend_obligatorio).nombre_cientifico, "/especies/#{especie.id_ascend_obligatorio}"),
          especie.estatus == 2 ? 'válido/correcto' : 'sinónimo',
          Especie.dameEspecieEstatuses(especie),
          Especie.dameEstadoDeConservacion(especie),
          Especie.dameRegionesNombresBibliografia(especie),
          '',
          '',
          especie.fuente,
          especie.cita_nomenclatural,
          especie.sis_clas_cat_dicc,
          especie.anotacion,
          #especie.updated_at.strftime("%B %e, %Y - %H:%m:%S"),
          #especie.created_at.strftime("%B %e, %Y - %H:%m:%S"),
          especie.created_at.to_date,
          especie.updated_at.to_date
      ]
    end
  end

  def datosEspecies(especial=nil)
    if especial.nil?
      @especies ||= fetch_especies

    else
      begin
        fetch_especies.total_entries
      rescue
        0
      end
    end
  end

  def fetch_especies
    especies=Especie.limit(params[:iDisplayLength]).ordenar(sort_column, sort_direction)
    especies=especies.page(page).per_page(per_page)

    if params[:sSearch].present?
      if ((ids=Especie.dameIdsDelNombre(params[:sSearch])).present?)
        especies=especies.where("id IN (#{ids})")
      else
        especies=Especie.none
      end
    end

    if params[:sSearch_2].present? && params[:sSearch_3].present?
      if ((ids=Especie.dameIdsCategoria(params[:sSearch_2], params[:sSearch_3])).present?)
        especies=especies.where("id IN (#{ids})")
      else
        especies=Especie.none
      end
    elsif params[:sSearch_2].blank?
      if params[:sSearch_3].present? && is_integer?(params[:sSearch_3])
        especies=especies.caso_ids('id', params[:sSearch_3])
      end

      if params[:sSearch_4].present?
        if params[:sSearch_4].include?('|')
          especies=especies.caso_sensitivo('id', params[:sSearch_4].split('|').last)
        else
          especies=especies.caso_insensitivo('nombre_cientifico', params[:sSearch_4])
        end
      end

      if params[:sSearch_5].present?
        especies=especies.caso_insensitivo('nombre_autoridad', params[:sSearch_5])
      end

      if params[:sSearch_6].present?
        especies=especies.caso_sensitivo('categoria_taxonomica_id', params[:sSearch_6])
      end
    end

    if params[:sSearch_9].present?
      especies=especies.caso_sensitivo('estatus', params[:sSearch_9])
    end

    if params[:sSearch_11].present?
      if ((ids=Especie.dameIdsDeConservacion(params[:sSearch_11])).present?)
        especies=especies.where("id IN (#{ids})")
      else
        especies=Especie.none
      end
    end

    if params[:sSearch_12].present?
      if ((ids=Especie.dameIdsDelNombre(params[:sSearch_12], true)).present?)
        especies=especies.where("id IN (#{ids})")
      else
        especies=Especie.none
      end
    end

    if params[:sSearch_13].present?
      if ((ids=Especie.dameIdsDeLaRegion(params[:sSearch_13])).present?)
        especies=especies.where("id IN (#{ids})")
      else
        especies=Especie.none
      end
    end

    if params[:sSearch_14].present?
      if ((ids=Especie.dameIdsDeLaDistribucion(params[:sSearch_14])).present?)
        especies=especies.where("id IN (#{ids})")
      else
        especies=Especie.none
      end
    end

    if params[:sSearch_15].present?
      especies=especies.caso_insensitivo('fuente', params[:sSearch_15])
    end

    if params[:sSearch_16].present?
      especies=especies.caso_insensitivo('cita_nomenclatural', params[:sSearch_16])
    end

    if params[:sSearch_17].present?
      especies=especies.caso_insensitivo('sis_clas_cat_dicc', params[:sSearch_17])
    end

    if params[:sSearch_18].present?
      especies=especies.caso_insensitivo('anotacion', params[:sSearch_18])
    end

    if params[:sSearch_19].present?
      especies=especies.caso_fecha('created_at', params[:sSearch_19])
    end

    if params[:sSearch_20].present?
      especies=especies.caso_fecha('updated_at', params[:sSearch_20])
    end

    especies
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[id accion1 accion2 id nombre categoria_taxonomica_id id_nombre_ascendente id_ascend_obligatorio estatus descripcion
nombre_comun descripcion adicional1 adicional2 fuente nombre_autoridad cita_nomenclatural
sis_clas_cat_dicc anotacion created_at updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "DESC" : "ASC"
  end

  def nombreCientifico(taxon)
    if taxon.depth == 7
      generoID=taxon.ancestry_acendente_obligatorio.split("/")[5]
      genero=Especie.find(generoID).nombre
      genero + ' ' + taxon.nombre
    elsif taxon.depth == 8
      generoID=taxon.ancestry_acendente_obligatorio.split("/")[5]
      genero=Especie.find(generoID).nombre
      especieID=taxon.ancestry_acendente_obligatorio.split("/")[6]
      especie=Especie.find(especieID).nombre
      genero + ' ' + ' ' + especie + ' ' + taxon.nombre
    else
      taxon.nombre
    end
  end
end
