class Lista < ActiveRecord::Base

  self.table_name = 'listas'
  validates :nombre_lista, :presence => true, :uniqueness => true
  before_update :quita_repetidos
  #validates :formato, :presence => true

  ESTATUS_LISTA = [
      [0, 'No'],
      [1, 'Sí']
  ]

  FORMATOS = [
      [1, '.csv'],
      [2, '.xlsx']
  ]

  # Columnas permitidas a exportar por el usuario
  COLUMNAS_GENERALES = %w(id catalogo_id x_naturalista_id x_snib_id x_snib_reino nombre_cientifico fuente
                        cita_nomenclatural sis_clas_cat_dicc anotacion created_at updated_at
                        x_nombres_comunes x_nombre_comun_principal x_categoria_taxonomica
                        x_tipo_distribucion  nombre_autoridad x_estatus x_foto_principal)
  COLUMNAS_RIESGO_COMERCIO = %w(x_nom x_iucn x_cites)
  COLUMNAS_CATEGORIAS = CategoriaTaxonomica::CATEGORIAS.map{|cat| "x_#{cat}"}

  def to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << nombres_columnas

      datos.each do |taxon|
        datos_taxon = []

        columnas.split(',').each do |col|
          datos_taxon << eval("taxon.#{col}")
        end
        csv << datos_taxon
      end
    end
  end

  # Arma el query para mostrar el contenido de las listas
  def datos(params={})
    return [] unless cadena_especies.present?
    taxones = []

    # Por default muestra todos
    Especie.caso_rango_valores('especies.id',cadena_especies).order('nombre_cientifico ASC').limit(params[:limit] ||= 300000).each do |taxon|

      cols = columnas.split(',')
      cols.each do |col|

        case col
          when 'x_snib_id'
            if proveedor = taxon.proveedor
              taxon.x_snib_id = proveedor.snib_id
            end
          when 'x_snib_reino'
            if proveedor = taxon.proveedor
              taxon.x_snib_reino = proveedor.snib_reino
            end
          when 'x_naturalista_id'
            if proveedor = taxon.proveedor
              taxon.x_naturalista_id = proveedor.naturalista_id
            end
          when 'x_categoria_taxonomica'
            taxon.x_categoria_taxonomica = taxon.categoria_taxonomica.nombre_categoria_taxonomica
          when 'x_estatus'
            taxon.x_estatus = Especie::ESTATUS_SIGNIFICADO[taxon.estatus]
          when 'x_foto_principal'
            if adicional = taxon.adicional
              taxon.x_foto_principal = adicional.foto_principal
            end
          when 'x_nombre_comun_principal'
            if adicional = taxon.adicional
              taxon.x_nombre_comun_principal = adicional.nombre_comun_principal
            end
          when 'x_nombres_comunes'
            nombres_comunes = taxon.nombres_comunes.order(:nombre_comun).map{|nom| "#{nom.nombre_comun} (#{nom.lengua})"}.uniq
            next unless nombres_comunes.any?
            taxon.x_nombres_comunes = nombres_comunes.join(',')
          when 'x_tipo_distribucion'
            tipos_distribuciones = taxon.tipos_distribuciones.map(&:descripcion).uniq
            next unless tipos_distribuciones.any?
            taxon.x_tipo_distribucion = tipos_distribuciones.join(',')
          when 'x_nom'
            nom = taxon.estados_conservacion.where('nivel1=4 AND nivel2=1 AND nivel3>0').distinct
            next unless nom.length == 1
            taxon.x_nom = nom[0].descripcion
          when 'x_iucn'
            iucn = taxon.estados_conservacion.where('nivel1=4 AND nivel2=2 AND nivel3>0').distinct
            next unless iucn.length == 1
            taxon.x_iucn = iucn[0].descripcion
          when 'x_cites'
            cites = taxon.estados_conservacion.where('nivel1=4 AND nivel2=3 AND nivel3>0').distinct
            next unless cites.length == 1
            taxon.x_cites = cites[0].descripcion
          else
            next
        end
      end

      # Para agregar todas las categorias taxonomicas que pidio, primero se intersectan
      cats = COLUMNAS_CATEGORIAS & cols

      if cats.any?
        next unless taxon.ancestry_ascendente_directo.present?
        ids = taxon.ancestry_ascendente_directo.gsub('/',',')

        Especie.select('nombre, nombre_categoria_taxonomica').categoria_taxonomica_join.caso_rango_valores('especies.id',ids).each do |ancestro|
          categoria = 'x_' << I18n.transliterate(ancestro.nombre_categoria_taxonomica).gsub(' ','_').downcase
          next unless COLUMNAS_CATEGORIAS.include?(categoria)
          eval("taxon.#{categoria} = ancestro.nombre")  # Asigna el nombre del ancestro si es que coincidio con la categoria
        end
      end

      taxones << taxon
    end
    taxones
  end

  def nombres_columnas(web = false)
    cabecera = []
    columnas.split(',').each do |col|
      cabecera << I18n.t("listas_columnas.generales.#{col}", default: I18n.t("listas_columnas.categorias.#{col}"))
    end
    web ? cabecera.join(',') : cabecera
  end

  private

  def quita_repetidos
    self.cadena_especies = cadena_especies.split(',').compact.uniq.join(',') if cadena_especies.present?
  end
end
