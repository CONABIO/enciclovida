require 'roo'

class Admin::UpdateMapsController < Admin::AdminController

  def upload
  end

  def process_file
    archivo = params[:archivo_excel]

    if archivo.nil?
      redirect_to admin_update_maps_upload_path,
                  alert: "Por favor, selecciona un archivo."
      return
    end

    begin
      # Abrir archivo Excel
      xlsx = Roo::Spreadsheet.open(archivo.path)
      hoja = xlsx.sheet(0)

      # Agrupar mapas por idCAT
      proveedores_hash = Hash.new do |hash, key|
        hash[key] = {
          "id_cat" => key,
          "mapas" => {}
        }
      end

      # Leer Excel desde la segunda fila
      hoja.each_row_streaming(offset: 1) do |fila|

        nombre_cientifico = fila[0]&.cell_value
        titulo            = fila[1]&.cell_value
        id_cat            = fila[13]&.cell_value
        layers            = fila[15]&.cell_value
        styler            = fila[16]&.cell_value
        bbox              = fila[17]&.cell_value
        anio              = fila[21]&.cell_value
        autor             = fila[22]&.cell_value

        # Ignorar filas sin idCAT
        next if id_cat.blank?

        # Nombre consecutivo del mapa
        numero_mapa = proveedores_hash[id_cat]["mapas"].size + 1
        nombre_mapa = "Mapa #{numero_mapa}"

        mapa = {
          "nombre_cientifico" => nombre_cientifico,
          "titulo"            => titulo,
          "layers"            => layers,
          "styles"            => styler,
          "bbox"              => bbox,
          "anio"              => anio,
          "autor"              => autor
        }

        proveedores_hash[id_cat]["mapas"][nombre_mapa] = mapa
      end

      # Actualizar información de GeoServer
      Especie.update_geoserver_info(proveedores_hash)

      redirect_to admin_update_maps_upload_path,
                  notice: "Datos importados exitosamente."

    rescue => e
      Rails.logger.error "ERROR actualizando mapas: #{e.class}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      redirect_to admin_update_maps_upload_path,
                  alert: "Hubo un error al importar los datos: #{e.message}"
    end
  end

end