class EspecieDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Especie.count,
        iTotalDisplayRecords: especies.total_entries,
        aaData: data,

    }
  end

  private

  def data
    especies.map do |especie|
      [
          especie.id,
          link_to(especie.nombre.humanize, especie),
          link_to(especie.categoria_taxonomica_id.to_s.blank? ? 'ND' : CategoriaTaxonomica.find(especie.categoria_taxonomica_id).nombre_categoria_taxonomica.humanize,
                  "/categorias_taxonomica/#{especie.categoria_taxonomica_id}"),
          especie.id_nombre_ascendente,
          especie.id_ascend_obligatorio,
          especie.estatus == 2 ? 'Activo' : 'Inactivo',
          especie.fuente,
          especie.nombre_autoridad.to_s.truncate(20),
          especie.numero_filogenetico,
          especie.cita_nomenclatural.to_s.truncate(20),
          especie.sis_clas_cat_dicc.to_s.truncate(20),
          especie.anotacion,
          especie.updated_at.strftime("%B %e, %Y - %H:%m:%S"),
          especie.created_at.strftime("%B %e, %Y - %H:%m:%S"),
          link_to('Ver', especie),
          link_to('Editar', "/especies/#{especie.id}/edit"),
          link_to('Eliminar', "/especies/#{especie.id}", method: :delete, data: { confirm: '¿Estás seguro de eliminar esta especie?' })
      ]
    end
  end

  def especies
    @especies ||= fetch_especies
  end

  def fetch_especies
    especies = Especie.order("#{sort_column} #{sort_direction}")
    especies = especies.page(page).per_page(per_page)
    if params[:sSearch].present?
      especies = especies.where("LOWER(nombre) LIKE LOWER('%#{params[:sSearch]}%')")
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
    columns = %w[id nombre categoria_taxonomica_id id_nombre_ascendente id_ascend_obligatorio estatus fuente
nombre_autoridad numero_filogenetico cita_nomenclatural sis_clas_cat_dicc anotacion created_at updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "DESC" : "ASC"
  end
end
