class ExoticaDocumento < ActiveRecord::Base
  self.table_name = "exoticas_documentos"

  belongs_to :exotica_invasora

  belongs_to :tipo_documento,
             class_name: "ExoticaCatalogo"

  attr_accessor :archivo

  before_save :guardar_archivo
  before_destroy :eliminar_archivo_fisico

  private

  def guardar_archivo
    puts "========================="
    puts archivo.inspect
    puts "========================="
    return unless archivo.present?

    carpeta = Rails.root.join("public", "exoticas")
    FileUtils.mkdir_p(carpeta)

    extension = File.extname(archivo.original_filename)
    nombre = "#{SecureRandom.uuid}#{extension}"

    File.open(carpeta.join(nombre), "wb") do |f|
      f.write(archivo.read)
    end

    self.ruta = "/exoticas/#{nombre}"
    self.nombre_original = archivo.original_filename
    self.titulo = File.basename(archivo.original_filename, extension)
  end
  
  def eliminar_archivo_fisico
    return if ruta.blank?
    archivo = Rails.root.join("public", ruta.delete_prefix("/"))
    File.delete(archivo) if File.exist?(archivo)
  end

end