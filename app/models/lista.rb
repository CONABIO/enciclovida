class Lista < ActiveRecord::Base

  self.table_name='listas'
  validates :nombre_lista, :presence => true, :uniqueness => true
  before_update :quitaRepetidos
  #validates :formato, :presence => true

  ESTATUS_LISTA = [
      [0, 'No'],
      [1, 'Sí']
  ]

  FORMATOS = [
      [1, '.csv'],
      [2, '.xls'],
      [3, '.txt']
  ]

  COLUMNAS = %w(id nombre_cientifico nombre_comun categoria_taxonomica tipo_distribucion estado_conservacion nombre_autoridad
                estatus fuente foto_principal cita_nomenclatural sis_clas_cat_dicc anotacion created_at updated_at)

  def to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << nombres_columnas
      datos = selecciona_columnas
      datos.each do |d|
        csv << d
      end
    end
  end

  # Arma el query para ostrar el contenido de las listas
  def selecciona_columnas
    return [] unless cadena_especies.present?
    resultados = []

    begin
      taxones = Especie.find(cadena_especies.split(',').first(50))
    rescue
      # Si algun taxon ya no tiene ese ID
      taxones = []
    end

    taxones.each do |taxon|
      resultado = []
      columnas.split(',').each do |col|

        case col
          when 'id', 'nombre_cientifico', 'nombre_autoridad', 'fuente', 'foto_principal',
              'cita_nomenclatural', 'sis_clas_cat_dicc', 'anotacion', 'created_at', 'updated_at'
            resultado << taxon.send(col)
          when 'estatus'
            resultado << Especie::ESTATUS_SIGNIFICADO[taxon.estatus]
          when 'nombre_comun'
            nombres_comunes = taxon.nombres_comunes.map(&:nombre_comun).uniq
            resultado << nombres_comunes.join(',')
          when 'tipo_distribucion'
            tipos_distribuciones = taxon.tipos_distribuciones.map(&:descripcion).uniq
            resultado << tipos_distribuciones.join(',')
          when 'estado_conservacion'
            estados_conservacion = taxon.estados_conservacion.map(&:descripcion).uniq
            resultado << estados_conservacion.join(',')
          when 'categoria_taxonomica'
            resultado << taxon.categoria_taxonomica.nombre_categoria_taxonomica
          else
            next
        end
      end
      resultados << resultado
    end
    resultados
  end

  private

  # Este metodo es identico al del lista_helper para evitar incluirlo
  def nombres_columnas
    cabecera = []
    columnas.split(',').each do |col|
      cabecera << I18n.t("listas_columnas.#{col}")
    end
    cabecera
  end

  def quitaRepetidos
    self.cadena_especies = cadena_especies.split(',').compact.uniq.join(',') if cadena_especies.present?
  end
end