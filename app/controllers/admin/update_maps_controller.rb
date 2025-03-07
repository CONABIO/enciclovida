class Admin::UpdateMapsController < ApplicationController
  require 'roo'

  def upload
  end
  
  def process_file
    archivo = params[:archivo_excel]
  
    if archivo.nil?
      redirect_to admin_update_maps_upload_path, alert: "Por favor, selecciona un archivo."
      return
    end
    begin
      # Abre el archivo Excel
      xlsx = Roo::Spreadsheet.open(archivo.path)
      hoja = xlsx.sheet(0) # Asume que los datos están en la primera hoja
  
      # Hash para agrupar mapas por id_cat
      proveedores_hash = Hash.new { |hash, key| hash[key] = { "id_cat" => key, "mapas" => {} } }
  
      # Itera sobre cada fila del Excel, omitiendo la primera fila de encabezados
      hoja.each_row_streaming(offset: 1) do |fila|
        id_cat = fila[13]&.cell_value
        nombre_cientifico = fila[0]&.cell_value
        titulo = fila[1]&.cell_value
        layers = fila[15]&.cell_value
        styles = fila[16]&.cell_value
        bbox = fila[17]&.cell_value
        anio = fila[21]&.cell_value
        autor = fila[22]&.cell_value
  
        # Verifica que id_cat no sea nulo
        next if id_cat.nil?
  
        # Genera el nombre del mapa
        numero_mapa = proveedores_hash[id_cat]["mapas"].size + 1
        nombre_mapa = "Mapa #{numero_mapa}"
  
        # Crea el objeto mapa
        mapa = {
          "nombre_cientifico" => nombre_cientifico,
          "titulo" => titulo,
          "layers" => layers,
          "styles" => styles,
          "bbox" => bbox,
          "anio" => anio,
          "autor" => autor
        }
        # Agrega el mapa al hash correspondiente en el hash de mapas
        proveedores_hash[id_cat]["mapas"][nombre_mapa] = mapa
      end
      # Convierte el hash a un array de objetos
      # proveedores_array = proveedores_hash.values
      Especie.update_geoserver_info(proveedores_hash)

      redirect_to admin_update_maps_upload_path, notice: "Datos importados exitosamente."
    rescue => e
      redirect_to admin_update_maps_upload_path, alert: "Hubo un error al importar los datos: #{e.message}"
    end
  end
end