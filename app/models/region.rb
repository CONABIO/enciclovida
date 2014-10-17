class Region < ActiveRecord::Base

  self.table_name='regiones'
  self.primary_key='id'

  belongs_to :tipo_region
  has_many :especies_regiones, :class_name => 'EspecieRegion', :foreign_key => 'region_id'
  has_ancestry

  def self.regiones_principales(id)
    limites = Bases.limites(1000000)  #por default toma la primera
    id_inferior = limites[:limite_inferior]
    id_superior = limites[:limite_superior]
    where(:tipo_region_id => id, :id => id_inferior..id_superior).where("nombre_region != 'ND'").order(:nombre_region)
  end

  def regiones_especificas
    children.where("nombre_region != 'ND'").order(:nombre_region)
  end

  def personalizaBusqueda
    if self.ancestry.present?
      parientes ||=''
      Region.find(self.ancestry.split('/').push(self.id)).each do |reg|
        parientes+="#{reg.nombre_region} (#{TipoRegion.find(reg.tipo_region_id).descripcion}) > "
      end
      parientes[0..-4]
    else
      "#{self.nombre_region} (#{TipoRegion.find(self.tipo_region_id).descripcion})"
    end
  end
end
