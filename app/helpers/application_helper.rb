module ApplicationHelper
  def bitacora
    if Rol::CON_BITACORA.include?(Usuario.find(session[:usuario]).rol_id.to_s)
      addon='<ul>'
      Bitacora.all.order('id DESC').limit(10).each do |bitacora|
        addon+="<li>#{link_to(bitacora.usuario.usuario, bitacora.usuario)} #{bitacora.descripcion}</li>"
      end
      addon
    else
      ''
    end
  end

  def cite(citation = nil, &block)
    @_citations ||= []
    if citation.blank? && block_given?
      citation = capture(&block)
    end
    citations = [citation].flatten
    links = citations.map do |c|
      #c = c.citation if c.is_a?(Source)    #para no implementar la tabla sources
      @_citations << c unless @_citations.include?(c)
      i = @_citations.index(c) + 1
      link_to(i, "#ref#{i}", :name => "cit#{i}")
    end
    content_tag :sup, links.uniq.sort.join(',').html_safe
  end

  def references(options = {})
    return if @_citations.blank?
    lis = ""
    @_citations.each_with_index do |citation, i|
      lis += if options[:linked]
               l = link_to i+1, "#cit#{i+1}"
               content_tag(:li, "#{l}. #{citation}".html_safe, :class => "reference", :id => "ref#{i+1}")
             else
               content_tag(:li, citation.html_safe, :class => "reference", :id => "ref#{i+1}")
             end
    end
    if options[:linked]
      content_tag :ul, lis.html_safe, :class => "references"
    else
      content_tag :ol, lis.html_safe, :class => "references"
    end
  end

  def formatted_user_text(text, options = {})
    return text if text.blank?

    # make sure attributes are quoted correctly
    text = text.gsub(/(\w+)=['"]([^'"]*?)['"]/, '\\1="\\2"')

    # Make sure P's don't get nested in P's
    text = text.gsub(/<\\?p>/, "\n\n") unless options[:skip_simple_format]
    text = sanitize(text, options)
    text = compact(text, :all_tags => true) if options[:compact]
    text = simple_format(text, {}, :sanitize => false) unless options[:skip_simple_format]
    text = auto_link(text.html_safe, :sanitize => false).html_safe
    # Ensure all tags are closed
    Nokogiri::HTML::DocumentFragment.parse(text).to_s.html_safe
  end
end
