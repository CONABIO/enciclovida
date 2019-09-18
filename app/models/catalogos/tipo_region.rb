class TipoRegion < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.TipoRegion"
  self.primary_key = 'IdTipoRegion'

  alias_attribute :id, :IdTipoRegion
  alias_attribute :descripcion, :Descripcion

  TIPOS_REGIONES = ['ESTADO', 'REGIONES HIDROLÓGICAS PRIORITARIAS', 'REGIONES MARINAS PRIORITARIAS',
                    'REGIONES TERRESTRES PRIORITARIAS', 'ECORREGIONES MARINAS', 'REGIONES MORFOLÓGICAS', 'REGIONES COSTERAS']

  REGION_POR_NIVEL = {'100' => 'País', '110' => 'Estatal', '111' => 'Municipal',
                      '200' => 'Regiones hidrólogicas prioritarias', '300' => 'Regiones Marinas prioritarias',
                      '400' => 'Regiones terrestres prioritarias', '500' => 'Ecorregiones marinas',
                      '510' => 'Regiones morfológicas', '511' => 'Regiones costeras'}

  FILTRO = ['ESTADO', 'ECORREGIONES MARINAS']

end
