class EspecieDatatable

  delegate :params, :h, :link_to, :check_box_tag, :number_to_currency, to: :@view

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
          link_to(especie.id, especie),
          especie.nombre.humanize,
          link_to(especie.categoria_taxonomica_id.to_s.blank? ? 'ND' : CategoriaTaxonomica.cat_taxonom(especie.categoria_taxonomica_id),
                  "/categorias_taxonomica/#{especie.categoria_taxonomica_id}"),
          especie.is_root? ? 'Raíz' : link_to(Especie.find(especie.id_nombre_ascendente).nombre, "/especies/#{especie.id_nombre_ascendente}"),
          especie.is_root? ? 'Raíz' : link_to(Especie.find(especie.id_ascend_obligatorio).nombre, "/especies/#{especie.id_ascend_obligatorio}"),
          especie.estatus == 2 ? 'Activo' : 'Inactivo',
          Especie.dameEstadoDeConservacion(especie),
          Especie.dameRegionesNombresBibliografia(especie),
          '',
          especie.fuente,
          especie.nombre_autoridad.to_s.truncate(20),
          especie.numero_filogenetico,
          especie.cita_nomenclatural.to_s.truncate(20),
          especie.sis_clas_cat_dicc.to_s.truncate(20),
          especie.anotacion,
          #especie.updated_at.strftime("%B %e, %Y - %H:%m:%S"),
          #especie.created_at.strftime("%B %e, %Y - %H:%m:%S"),
          especie.updated_at.to_date,
          especie.created_at.to_date,
          link_to('Ver', especie),
          link_to('Editar', "/especies/#{especie.id}/edit"),
          link_to('Eliminar', "/especies/#{especie.id}", method: :delete, data: { confirm: '¿Estás seguro de eliminar esta especie?' }),
          link_to('Nuevo grupo o especie descendente de este', "/especies/new?parent_id=#{especie.id}"),
          ''
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

    if params[:sSearch_1].present? && is_integer?(params[:sSearch_1])
      especies=especies.caso_ids('id', params[:sSearch_1])
    end

    if params[:sSearch_2].present?
      especies=especies.caso_insensitivo('nombre', params[:sSearch_2])
    end

    if params[:sSearch_3].present?
      especies=especies.caso_sensitivo('categoria_taxonomica_id', params[:sSearch_3])
    end

    if params[:sSearch_6].present?
      especies=especies.caso_sensitivo('estatus', params[:sSearch_6])
    end

    if params[:sSearch_8].present?
      if ((ids=Especie.dameIdsDelNombre(params[:sSearch_8], true)).present?)
        especies=especies.where("id IN (#{ids})")
      else
        especies=Especie.none
      end
    end

    if params[:sSearch_9].present?
      if ((ids=Especie.dameIdsDeLaDistribucion(params[:sSearch_9])).present?)
        especies=especies.where("id IN (#{ids})")
      else
        especies=Especie.none
      end
    end

    if params[:sSearch_10].present?
      if ((ids=Especie.dameIdsDeLaRegion(params[:sSearch_10])).present?)
        especies=especies.where("id IN (#{ids})")
      else
        especies=Especie.none
      end
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
    columns = %w[id id nombre categoria_taxonomica_id id_nombre_ascendente id_ascend_obligatorio estatus nom_reg_biblio especies_estatuses especies_catalogos fuente
nombre_autoridad numero_filogenetico cita_nomenclatural sis_clas_cat_dicc anotacion created_at updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "DESC" : "ASC"
  end
end
