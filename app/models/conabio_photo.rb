class ConabioPhoto < Photo

  Photo.descendent_classes ||= []
  Photo.descendent_classes << self

  validate :licensed_if_no_user

  def sync
    new_photo = self.class.new_from_api_response(self.class.get_api_response(native_photo_id))
    cols = Photo.column_names - %w(id user_id native_photo_id type created_at updated_at)
    cols.each do |c|
      send("#{c}=", new_photo.send(c))
    end
    save
  end

  def self.search_conabio(taxon)
    return [] unless metadatos = taxon.metadatos

    metadatos.map do |resp|
      new_from_api_response(resp)
    end.compact
  end

  def self.get_api_response(photo_id)
    begin
      Metadato.find(photo_id)
    rescue
      nil
    end
  end

  def self.new_from_api_response(api_response, options = {})
    copyright = api_response.artist.present? ? "#{api_response.artist} / Banco de Imágenes CONABIO" : 'Banco de Imágenes CONABIO'
    imagen = "http://bdi.conabio.gob.mx:5050/#{api_response.path.sub('/fotosBDI/Toda la Base del BI/', '')}"
    new(options.merge(
            :large_url => imagen,
            :medium_url => imagen,
            :small_url => imagen,
            :thumb_url => imagen,
            :native_photo_id => api_response.id,
            :square_url => imagen,
            :original_url => imagen,
            :native_page_url => "http://bdi.conabio.gob.mx/fotoweb/Grid.fwx?columns=4&rows=8&search=#{api_response.transmission_reference}",
            :native_username => copyright,
            :native_realname => copyright,
            :license => 3
        ))
  end
end
