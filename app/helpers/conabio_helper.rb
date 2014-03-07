module ConabioHelper
  def taxon_image(photos, params = {})
    html ||=''
    if photos.blank?
      return "<em>No existe en el #{link_to('Banco de Im&aacute;genes'.html_safe, 'http://bdi.conabio.gob.mx', :target => :_blank)} una foto asociada con este tax&oacute;n</em>".html_safe
    end

    photos.each do |p|
      params[:size] ||= 'square'
      image_params = {}
      image_params[:alt] = params[:nombre].present? ? params[:nombre] : 'Tax&oacute;n'.html_safe
      image_params[:title] = image_params[:alt]
      image_params[:class] = "#{params[:size]} photo".strip
      image_params[:width] = '490px;'
      html+= link_to image_tag(p['thumb_url'], image_params), p['native_page_url'], :target => :_blank
      html += '&nbsp;'
    end
    html.html_safe
  end
end