class TipoRegion < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.tipos_regiones"
  self.primary_key = 'id'
  has_many :regiones

  TIPOS_REGIONES = ['ESTADO', 'REGIONES HIDROLÓGICAS PRIORITARIAS', 'REGIONES MARINAS PRIORITARIAS',
                    'REGIONES TERRESTRES PRIORITARIAS', 'ECORREGIONES MARINAS', 'REGIONES MORFOLÓGICAS', 'REGIONES COSTERAS']

  REGION_POR_NIVEL = {'100' => 'País', '110' => 'Estatal', '111' => 'Municipal',
                      '200' => 'Regiones hidrólogicas prioritarias', '300' => 'Regiones Marinas prioritarias',
                      '400' => 'Regiones terrestres prioritarias', '500' => 'Ecorregiones marinas',
                      '510' => 'Regiones morfológicas', '511' => 'Regiones costeras'}

  def self.iniciales
    limites = Bases.limites(1000000)  #por default toma la primera
    id_inferior = limites[:limite_inferior]
    id_superior = limites[:limite_superior]
    where(:descripcion => TIPOS_REGIONES, :id => id_inferior..id_superior)
  end
end
