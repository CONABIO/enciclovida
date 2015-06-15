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
      [2, '.xlsx'],
      [3, '.txt']
  ]

  # Columnas permitidas a exportar por el usuario
  COLUMNAS_GENERALES = %w(id nombre_cientifico nombre_comun categoria_taxonomica tipo_distribucion estado_conservacion nombre_autoridad
                estatus foto_principal fuente cita_nomenclatural sis_clas_cat_dicc anotacion created_at updated_at)
  COLUMNAS_CATEGORIAS = %w(reino division subdivision clase subclase superorden orden suborden
                familia subfamilia tribu subtribu genero subgenero seccion subseccion
                serie subserie especie subespecie variedad subvariedad forma subforma
                subreino superphylum phylum subphylum superclase grado infraclase
                infraorden superfamilia supertribu parvorden superseccion grupo
                infraphylum epiclase cohorte grupo_especies raza estirpe
                subgrupo hiporden)

  def to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << nombres_columnas

      datos.each do |dato|
        csv << dato
      end
    end
  end

  # Arma el query para mostrar el contenido de las listas
  def datos
    return [] unless cadena_especies.present?
    taxones = []

    Especie.caso_rango_valores('especies.id',cadena_especies).order('nombre_cientifico ASC').find_each do |taxon|

      cols = columnas.split(',')
      cols.each do |col|

        case col
          #when 'id', 'catalogo_id', 'nombre_cientifico', 'nombre_autoridad', 'fuente',
          #    'cita_nomenclatural', 'sis_clas_cat_dicc', 'anotacion', 'created_at', 'updated_at'
          #  resultado << taxon.send(col)
          when 'categoria_taxonomica'
            taxon.x_categoria_taxonomica = taxon.categoria_taxonomica.nombre_categoria_taxonomica
          when 'estatus'
            taxon.x_estatus = Especie::ESTATUS_SIGNIFICADO[taxon.estatus]
          when 'foto_principal'
            if adicional = taxon.adicional
              taxon.x_foto_principal = adicional.foto_principal
            end
          when 'nombre_comun_principal'
            if adicional = taxon.adicional
              taxon.x_nombre_comun_principal = adicional.nombre_comun_principal
            end
          when 'nombres_comunes'
            nombres_comunes = taxon.nombres_comunes.order(:nombre_comun).map{|nom| "#{nom.nombre_comun} (#{nom.lengua})"}.uniq
            next unless nombres_comunes.any?
            taxon.x_nombres_comunes = nombres_comunes.join(',')
          when 'tipo_distribucion'
            tipos_distribuciones = taxon.tipos_distribuciones.map(&:descripcion).uniq
            next unless tipos_distribuciones.any?
            taxon.x_tipo_distribucion = tipos_distribuciones.join(',')
          when 'estado_conservacion'
            taxon.estados_conservacion.distinct.each do |cat_riesgo|
              if cat_riesgo.nivel1 == 4 # Son categorias de riesgo
                if cat_riesgo.nivel2 == 1 && cat_riesgo.nivel3 > 0 # Es de NOM
                  taxon.x_nom = cat_riesgo.descripcion
                elsif cat_riesgo.nivel2 == 2 && cat_riesgo.nivel3 > 0 # Es de IUCN
                  taxon.x_iucn = cat_riesgo.descripcion
                elsif cat_riesgo.nivel2 == 3 && cat_riesgo.nivel3 > 0 # Es de CITES
                  taxon.x_cites = cat_riesgo.descripcion
                end
              end
            end

          else
            next
        end
      end

      # Para agregar todas las categorias taxonomicas que pidio
      next unless taxon.ancestry_ascendente_directo.present?
      ids = taxon.ancestry_ascendente_directo.gsub('/',',')

      Especie.select('nombre, nombre_categoria_taxonomica').categoria_taxonomica_join.caso_rango_valores('especies.id',ids).each do |ancestro|
        categoria = I18n.transliterate(ancestro.nombre_categoria_taxonomica).gsub(' ','_')
        next unless COLUMNAS.include?(categoria)
        taxon.send("x_#{categoria}", ancestro.nombre)  # Asigna el nombre del ancestro si es que coincidio con la categoria
      end
      resultados << taxon
    end
    taxones
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

  def quita_repetidos
    self.cadena_especies = cadena_especies.split(',').compact.uniq.join(',') if cadena_especies.present?
  end
end
