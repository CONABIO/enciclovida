class ExoticasInvasorasController < ApplicationController

  POR_PAGINA = 30

  def index
    @pagina = [params[:pagina].to_i, 1].max

    @catalogos = ExoticaCatalogo
      .activos
      .where.not(tipo: "tipo_documento")
      .group_by(&:tipo)

    @exoticas = ExoticaInvasora
      .joins(:especie)
      .includes(
        :catalogos,
        :documentos,
        especie: :adicional
      )

    if params[:especie_id].present?
      aplicar_busqueda
    else
      aplicar_filtros_catalogos
    end

    @exoticas = @exoticas
      .distinct
      .order(created_at: :desc)

    @totales = @exoticas.count
    @paginas = (@totales.to_f / POR_PAGINA).ceil

    @pagina = @paginas if @paginas > 0 && @pagina > @paginas
    
    @exoticas = @exoticas
      .limit(POR_PAGINA)
      .offset((@pagina - 1) * POR_PAGINA)

    @exoticas.each { |exotica| exotica.especie.asigna_categorias }
  end

  private

  def aplicar_busqueda
    return if params[:especie_id].blank?

    @exoticas = @exoticas.where(
      especie_id: params[:especie_id]
    )
  end

  def aplicar_filtros_catalogos
  @catalogos.each_key.with_index do |tipo, index|
    catalogo_id = params["#{tipo}_id"]
    next if catalogo_id.blank?
    alias_eic = "eic_filtro_#{index}"
    alias_ec = "ec_filtro_#{index}"
    @exoticas = @exoticas.joins("INNER JOIN exoticas_invasoras_catalogos #{alias_eic} ON #{alias_eic}.exotica_invasora_id = exoticas_invasoras.id").joins("INNER JOIN exoticas_catalogos #{alias_ec} ON #{alias_ec}.id = #{alias_eic}.catalogo_id").where("#{alias_ec}.tipo = ?", tipo).where("#{alias_ec}.id = ?", catalogo_id)
  end
end

end