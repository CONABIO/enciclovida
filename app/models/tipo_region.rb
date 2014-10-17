class TipoRegion < ActiveRecord::Base

  self.table_name='tipos_regiones'
  self.primary_key='id'
  has_many :regiones

  TIPOS_REGIONES = ['ESTADO', 'REGIONES HIDROLÓGICAS PRIORITARIAS', 'REGIONES MARINAS PRIORITARIAS',
                    'REGIONES TERRESTRES PRIORITARIAS', 'ECORREGIONES MARINAS', 'REGIONES MORFOLÓGICAS', 'REGIONES COSTERAS']

  def self.iniciales
    limites = Bases.limites(1000000)  #por default toma la primera
    id_inferior = limites[:limite_inferior]
    id_superior = limites[:limite_superior]
    where(:descripcion => TIPOS_REGIONES, :id => id_inferior..id_superior)
  end
end
