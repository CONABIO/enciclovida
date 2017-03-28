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

  def self.new_from_api_response(api_response, usuario_id = nil, options = {})
    copyright = api_response.artist.present? ? "#{api_response.artist} / Banco de Imágenes CONABIO" : 'Banco de Imágenes CONABIO'
    imagen = "#{CONFIG.bdi_imagenes.to_s}/#{api_response.path.sub('/fotosBDI/Toda la Base del BI/', '')}"

    params = options.merge(
        :large_url => "#{imagen}?w=1024&h=1024&mode=max",
        :medium_url => "#{imagen}?w=500&h=500&mode=max",
        :small_url => "#{imagen}?w=240&h=240&mode=max",
        :thumb_url => "#{imagen}?w=100&h=100&mode=max",
        :native_photo_id => api_response.id,
        :square_url => "#{imagen}?w=75&h=75&mode=crop",
        :original_url => imagen,
        :native_page_url => "#{CONFIG.bdi_fotoweb}#{api_response.path.gsub('/fotosBDI/','').gsub(' ','%20')}",
        :native_username => copyright,
        :native_realname => copyright,
        :license => 3
    )

    usuario_id.present? ? new(params.merge(:usuario_id => usuario_id)) : new(params)
  end
end
