class CategoriaTaxonomica < ActiveRecord::Base
  self.table_name = 'categorias_taxonomicas'
  self.primary_key = 'id'
  has_many :especies

  scope :caso_rango_valores, ->(columna, rangos) { where("#{columna} IN (#{rangos})") }
  scope :cat_taxonom, ->(valor) { find(valor).nombre_categoria_taxonomica }

  # Todas las categorias
  CATEGORIAS  = self.all.map{|cat| I18n.transliterate(cat.nombre_categoria_taxonomica).gsub(' ','_').downcase}.uniq
  # Despliego solo estas categorias para la vista basica
  CATEGORIAS_OBLIGATORIAS = %w(Reino phylum división clase orden familia género especie subespecie)
  # Para un mejor uso de las infraespecies
  CATEGORIAS_INFRAESPECIES = %w(subespecie forma subforma variedad subvariedad)
  # Reinos
  CATEGORIAS_REINOS = %w(animalia plantae protoctista fungi prokaryotae)

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

  def self.categorias_redis(tipo)
    # Orden en particular de como se despliegan las categorias en redis
    cat = %w(especie subespecie variedad subvariedad forma subforma
    Reino subreino superphylum
    division subdivision phylum subphylum superclase grado
    clase subclase infraclase superorden
    orden suborden infraorden superfamilia
    familia subfamilia supertribu tribu subtribu
    genero subgenero seccion subseccion serie subserie)

    # Estas categorias no se encuentran en las establecidas por los catalogos
    # parvorden superseccion grupo infraphylum epiclase cohorte grupo_especies raza estirpe subgrupo hiporden subterclase)

    categorias_com = cat.map{|cat| "'com_#{cat}'"}
    categorias_cien = cat.map{|cat| "'cien_#{cat}'"}

    categorias = categorias_com + categorias_cien
    "[#{categorias.uniq.join(',')}]"
  end
end
