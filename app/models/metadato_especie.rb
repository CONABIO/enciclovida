class Metadato < ActiveRecord::Base

  before_save :valida_object_name
  after_save :asocia_metadatos
  has_many :metadato_especies, :class_name => 'MetadatoEspecie', :foreign_key => 'metadato_id', :dependent => :destroy

  def valida_object_name
# Quita las siguientes cadenas: sp.$ | sp. | ssp. | sp$ | spp$ | sp..$ | spp..$
    object = []
    object_name.split(',').each do |obj|
      obj << squeeze('.').gsub(/( spp.$)|( spp. )|( sp[p.]$)|( sp[p.] )|( sp$)|( sp )/, ' ').squeeze(' ').strip
    end
    object.join(',')
  end

  def asocia_metadatos
    object_name.split(',').each do |obj|
      next unless taxon = Especie.where(:nombre_cientifico => obj).first
      next if MetadatoEspecie.where(:especie_id => taxon, :metadato_id => self).first
      me = MetadatoEspecie.new(:especie_id => taxon, :metadato_id => self)
      me.save
    end
  end
end