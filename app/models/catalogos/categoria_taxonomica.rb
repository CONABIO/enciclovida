class CategoriaTaxonomica < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.CategoriaTaxonomica"
  self.primary_key = 'idCategoriaTaxonomica'

  # Los alias con las tablas de catalogos
  alias_attribute :id, :IdCategoriaTaxonomica
  alias_attribute :nombre_categoria_taxonomica, :NombreCategoriaTaxonomica
  alias_attribute :nivel1, :IdNivel1
  alias_attribute :nivel2, :IdNivel2
  alias_attribute :nivel3, :IdNivel3
  alias_attribute :nivel4, :IdNivel4

  has_many :especies

  scope :caso_rango_valores, ->(columna, rangos) { where("#{columna} IN (#{rangos})") }
  scope :cat_taxonom, ->(valor) { find(valor).nombre_categoria_taxonomica }
  scope :cat_tax_asociadas, ->(nivel2) { select(:id, :nombre_categoria_taxonomica).select("CONCAT(#{attribute_alias(:nivel1)},#{attribute_alias(:nivel2)},#{attribute_alias(:nivel3)},#{attribute_alias(:nivel4)}) AS nivel").where(nivel2: nivel2).order(:nivel1, :nivel2, :nivel3, nivel4: :asc) }

  # Todas las categorias
  CATEGORIAS  = self.all.map{|cat| I18n.transliterate(cat.nombre_categoria_taxonomica).gsub(' ','_').downcase.strip}.uniq
  # Despliego solo estas categorias para la vista basica
  CATEGORIAS_OBLIGATORIAS = %w(Reino phylum división clase orden familia género especie subespecie)
  # Para un mejor uso de las infraespecies
  CATEGORIAS_INFRAESPECIES = %w(subespecie forma subforma variedad subvariedad)
  # Reinos
  CATEGORIAS_REINOS = %w(animalia plantae protoctista fungi prokaryotae)
  # Categorias para geodatos
  CATEGORIAS_GEODATOS = CATEGORIAS_INFRAESPECIES + %w(especie)
  # Las categorias utilizadas en el checklist
  CATEGORIAS_CHECKLIST = CATEGORIAS_OBLIGATORIAS + %w(subclase superorden)

  # Abreviaciones de las categorias taxonomicas
  ABREVIACIONES = {
      reino: 'R',
      division: 'D',
      phylum: 'P',
      clase: 'C',
      orden: 'O',
      familia: 'F',
      genero: 'G',
      especie: 'E'
  }

  CATEGORIAS_DIVISION = {
      1 => {
          0 => 'Reino',
          1 => 'Subreino'
      },
      2 => {
          0 => 'División',
          1 => 'Subdivisión'
      },
      3 => {
          0 => 'Clase',
          1 => 'Subclase',
          2 => 'Superorden'
      },
      4 => {
          0 => 'Orden',
          1 => 'Suborden'
      },
      5 => {
          0 => 'Familia',
          1 => 'Subfamilia',
          2 => {
              0 => 'Tribu',
              1 => 'Subtribu'
          }
      },
      6 => {
          0 => 'Género',
          1 => 'Subgénero',
          2 => {
              0 => 'Sección',
              1 => 'Subsección'
          },
          3 => {
              0 => 'Serie',
              1 => 'Subserie'
          }
      },
      7 => {
          0 => 'Especie',
          1 => 'Subespecie',
          2 => {
              0 => 'Variedad',
              1 => 'Subvariedad'
          },
          3 => {
              0 => 'Forma',
              1 => 'Subforma'
          }
      }
  }

  CATEGORIAS_PHYLUM = {
      1 => {
          0 => 'Reino',
          1 => 'Subreino',
          2 => 'Superphylum'
      },
      2 => {
          0 => 'Phylum',
          1 => 'Subphylum',
          2 => 'Superclase',
          3 => 'Grado'
      },
      3 => {
          0 => 'Clase',
          1 => 'Subclase',
          2 => 'Infraclase',
          3 => 'Superorden'
      },
      4 => {
          0 => 'Orden',
          1 => 'Suborden',
          2 => 'Infraorden',
          3 => 'Superfamilia'
      },
      5 => {
          0 => 'Familia',
          1 => 'Subfamilia',
          2 => 'Supertribu',
          3 => {
              0 => 'Tribu',
              1 => 'Subtribu'
          }
      },
      6 => {
          0 => 'Género',
          1 => 'Subgénero',
          2 => {
              0 => 'Sección',
              1 => 'Subsección'
          },
          3 => {
              0 => 'Serie',
              1 => 'Subserie'
          }
      },
      7 => {
          0 => 'Especie',
          1 => 'Subespecie',
          2 => {
              0 => 'Variedad',
              1 => 'Subvariedad'
          },
          3 => {
              0 => 'Forma',
              1 => 'Subforma'
          }
      }
  }

  def self.categorias_redis()
    # Orden en particular de como se despliegan las categorias en redis
    cat = %w(especie subespecie variedad subvariedad forma subforma
    Reino subreino superphylum
    division subdivision phylum subphylum superclase grado
    clase subclase infraclase superorden
    orden suborden infraorden superfamilia
    familia subfamilia supertribu tribu subtribu
    genero subgenero seccion subseccion serie subserie)

    categorias = cat.map{|cat| "'#{cat}'"}
    "[#{categorias.join(',')}]"
  end
end
