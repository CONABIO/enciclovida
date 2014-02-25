class Lista < ActiveRecord::Base

  include ListasHelper
  self.table_name='listas'
  validates :nombre_lista, :presence => true, :uniqueness=>true
  before_update :quitaRepetidos
  #validates :formato, :presence => true

  self.per_page = 10
  WillPaginate.per_page = 10

  ESTATUS_LISTA = [
      [0, 'No'],
      [1, 'Sí']
  ]

  FORMATOS = [
      [1, '.csv'],
      [2, '.xls'],
      [3, '.txt']
  ]

  ATRIBUTOS_TABLAS = [
      ['id', 'identificador único'],
      ['nombre_cientifico', 'nombre científico'],
      ['nombre_autoridad', 'nombre de la autoridad'],
      ['categoria_taxonomica_id', 'categoria taxonómica'],
      ['estatus', 'estatus del nombre'],
      ['fuente', 'fuente'],
      ['cita_nomenclatural', 'cita nomenclatural'],
      ['sis_clas_cat_dicc', 'sistema de clasificación, catálogo o diccionario'],
      ['anotacion', 'anotación'],
      ['created_at', 'fecha de creación'],
      ['updated_at', 'fecha de actualización']
  ]

  def self.to_csv(lista, options = {})
    CSV.generate(options) do |csv|
      columnas=lista.columnas.split(',')
      csv << ListasHelper.nombreComunAtributos(lista).split(',')
      if lista.cadena_especies.present?
        Especie.find(lista.cadena_especies.split(',')).each do |taxon|
          csv << taxon.attributes.values_at(*columnas)
        end
      end
    end
  end

  private

  def quitaRepetidos
    self.cadena_especies = self.cadena_especies.split(',').compact.uniq.join(',') if self.cadena_especies.present?
  end
end


