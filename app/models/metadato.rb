class Metadato < ActiveRecord::Base

  before_save :valida_object_name
  after_save :asocia_metadatos
  has_many :metadato_especies, :class_name => 'MetadatoEspecie', :foreign_key => 'metadato_id', :dependent => :destroy

  def valida_object_name
# Quita las siguientes cadenas: sp.$ | sp. | ssp. | sp$ | ssp$ | sp..$ | ssp..$
    object = []

    # Lo separo por comas porque puede haber mas de una especie
    object_name.split(',').each do |obj|
      object << obj.squeeze('.').gsub(/( ssp.$)|( ssp. )|( ssp.)|( ss[p.]$)|( ss[p.] )|( sp$)|( sp )/, ' subsp. ').squeeze(' ').strip
    end
    self.object_name=object.join(',')
  end

  def asocia_metadatos
    object_name.split(',').each do |obj|
      next unless taxon = Especie.where(:nombre_cientifico => obj).first
      next if MetadatoEspecie.where(:especie_id => taxon, :metadato_id => self).first
      me = MetadatoEspecie.new(:especie_id => taxon.id, :metadato_id => id)
      me.save
    end
  end
end
