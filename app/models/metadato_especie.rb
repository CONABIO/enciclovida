class MetadatoEspecie < ActiveRecord::Base
  self.table_name = :metadato_especies

  belongs_to :especie
  belongs_to :metadato

  def fotos_bi(usuario_id)
    # Por algun caso extraño por si se borro a mano la foto
    return unless metadato

    return if ConabioPhoto.find_by_native_photo_id(metadato.id.to_s)
    taxon = especie

    begin
      fotos_buscador = especie.photos
    rescue
      puts 'ERROR: Especie no existe'
      return
    end

    if fotos_buscador
      # Para no borrar las anteriores fotos
      photo = ConabioPhoto.new_from_api_response(metadato, usuario_id)
      photo.save
      taxon_photo = TaxonPhoto.new
      taxon_photo.especie_id = especie.id
      taxon_photo.photo_id = photo.id
      taxon_photo.save
    else
      fotos_buscador = fotos_naturalista
      taxon.save
    end
  end
end