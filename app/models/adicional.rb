class Adicional < ActiveRecord::Base

  establish_connection(:development)
  self.table_name='enciclovida.adicionales'

  belongs_to :especie
  belongs_to :icono

  attr_accessor :select_nom_comun, :text_nom_comun

  # Lenguas aceptadas de NaturaLista
  LENGUAS_ACEPTADAS = %w(spanish espanol_mexico huasteco maya maya_peninsular mayan_languages mazateco mixteco mixteco_de_yoloxochitl totonaco otomi nahuatl zapoteco english)
end