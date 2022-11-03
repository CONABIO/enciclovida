class BusquedasRegionesController < ApplicationController
	
	skip_before_action :verify_authenticity_token, :set_locale
	layout false, only: [:especies, :ejemplares]
	
	# Registros con un radio alreadedor de tu ubicación
	def ubicacion
	end
	
	# /explora-por-region
	def por_region
		@no_render_busqueda_basica = true
		cache_filtros_ev
	end

	# Servicio para consultar las especies por region, contempla filtros y cache
	def especies
		br = BusquedaRegion.new
		br.params = params
		
		respond_to do |format|
			format.html do
				br_guia = BusquedaRegion.new
				br_guia.params = params
				br_guia.valida_descarga_guia
				
				cache_filtros_ev
				br.especies
				@resp = br.resp
				@valida_guia = br_guia.resp[:estatus]
			end
			format.xlsx do
				br.original_url = request.original_url
				br.descarga_taxa_excel
				render json: br.resp
			end
			format.json do
				if params[:guia] == "1"
					br.original_url = request.original_url
					br.valida_descarga_guia
					
					if br.resp[:estatus]
						br.descarga_taxa_pdf
					end
					
					render json: br.resp and return
				else
					br.especies
					render json: br.resp and return
				end
			end
			
			format.pdf do
				br = BusquedaRegion.new
				br.params = params
				
				if params[:job].present? && params[:job] == "1"
					br.original_url = request.original_url
					br.valida_descarga_guia
					
					if br.resp[:estatus]
						br.descarga_taxa_pdf
					end
					
					render json: br.resp and return
				
				else
					br.descarga_taxa_pdf
					@resp = br.resp
					@url_enciclovida = request.url.gsub('/especies.pdf', '')
					
					render pdf: 'Guía de especies',
					       layout: 'guias.pdf.erb',
					       template: 'busquedas_regiones/guias/especies.pdf.erb',
					       encoding: 'UTF-8',
					       wkhtmltopdf: CONFIG.wkhtmltopdf_path,
					       save_to_file: Rails.root.join('public','descargas_guias', params[:fecha], "#{params[:nombre_guia]}.pdf"),
					       save_only: true,
					       page_size: 'Letter',
					       page_height: 279,
					       page_width:  215,
					       orientation: 'Portrait',
					       disposition: 'attachment',
					       disable_internal_links: false,
					       disable_external_links: false,
					       header: {
							       html: {
									       template: 'busquedas_regiones/guias/header.html.erb'
							       }
					       },
					       footer: {
							       html: {
									       template: 'busquedas_regiones/guias/footer.html.erb'
							       },
					       }
					
					render json: { estatus: true } and return
				end
			end
		
		end
	end

	def guia
		render 'busquedas_regiones/guias/especies'
	end
	
	# Regresa todos los registros de la especie seleccionada
	def ejemplares
		snib = Geoportal::Snib.new
		snib.params = params
		snib.ejemplares
		
		render json: snib.resp
	end
	
	# Regresa la información asociada a un ejemplar por medio de su ID
	def ejemplar
		snib = Geoportal::Snib.new
		snib.params = params
		snib.ejemplar
		
		render json: snib.resp
	end
	
	# Devuelve los municipios por el estado seleccionado
	def municipios_por_estado
		resp = {}
		resp[:estatus] = false
		
		if params[:region_id].present?
			resp[:estatus] = true
			parent_id = Estado::CORRESPONDENCIA[params[:region_id].to_i]
			municipios = Municipio.campos_min.where(cve_ent: parent_id)
			resp[:resultados] = municipios.map{|m| {region_id: m.region_id, nombre_region: m.nombre_region}}
			resp[:parent_id] = parent_id
		else
			resp[:msg] = 'El argumento region_id está vacio'
		end
		
		render json: resp
	end

end