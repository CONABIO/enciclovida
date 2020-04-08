class Api::Wikipedia

  attr_accessor :taxon, :nombre_servicio, :servidor, :timeout, :debug, :wsdl, :key, :locale, :endpoint, :method_param, :default_params

  def initialize(opc = {})
    self.servidor = opc[:servidor] || "http://en.wikipedia.org/w/api.php?"
    self.method_param = 'action'
    self.default_params = { :format => 'xml' }
    self.locale = options[:locale] || I18n.locale || 'en'
    self.timeout = opc[:timeout] || 8
    self.debug = opc[:debug] || Rails.env.development? || false
    Rails.logger.debug "[DEBUG] Inicializar el servicio: #{nombre}" if debug
  end

  def nombre
    'Wikipedia (Inglés)'
  end

  def dame_descripcion
    buscar(taxon.nombre_cientifico.limpiar.limpia)
  end

  def summary(title)
    begin
      response = parse(:page => title, :redirects => true)

      hxml = Nokogiri::HTML(HTMLEntities.new.decode(response.at( "text" ).try( :inner_text )))
      hxml.search('table').remove
      hxml.search("//comment()").remove
      summary = ( hxml.search("//p").detect{|node| !node.inner_html.strip.blank?} || hxml ).inner_html.to_s.strip
      summary = summary.sanitize(tags: %w(p i em b strong))
      summary.gsub! /\[.*?\]/, ''
      summary

    rescue Timeout::Error => e
      Rails.logger.info "[INFO] Wikipedia API call failed while setting taxon summary: #{e.message}"
      return
    end
  end

  private

  def buscar(q)
    decoded = ''

    begin
      response = request()
      #response = wikipedia.parse(:page => q, :redirects => true)
      return if response.nil?
      parsed = response.at('text').try(:inner_text).to_s
      decoded = clean_html(parsed) if parsed
    rescue Timeout::Error => e
      Rails.logger.debug "[INFO] Wikipedia API call failed: #{e.message}" if debug
    end

    decoded
  end

  def limpia_html(html, options = {})
    coder = HTMLEntities.new
    html.gsub!(/(data-)?videopayload=".+?"/m, '')
    decoded = coder.decode(html)
    decoded.gsub!('href="//', 'href="http://')
    decoded.gsub!('src="//', 'src="http://')
    decoded.gsub!('href="/', 'href="http://en.wikipedia.org/')
    decoded.gsub!('src="/', 'src="http://en.wikipedia.org/')

    if options[:strip_references]
      decoded.gsub!(/<sup .*?class=.*?reference.*?>.+?<\/sup>/, '')
      decoded.gsub!(/<strong .*?class=.*?error.*?>.+?<\/strong>/, '')
    end

    decoded
  end

  def request(method, args = {})
    params      = args.merge({@method_param => method})
    params      = params.merge(@default_params)
    endpoint    = api_endpoint ? api_endpoint.base_url : @endpoint
    url         = endpoint + params.map {|k,v| "#{k}=#{v}"}.join('&')
    uri         = URI.encode(url)
    request_uri = URI.parse(uri)
    response = nil
    begin
      MetaService.fetch_request_uri(request_uri: request_uri, timeout: @timeout,
                                    api_endpoint: api_endpoint,
                                    user_agent: "#{CONFIG.site_name}/#{self.class}/#{SERVICE_VERSION}")
    rescue Timeout::Error
      raise Timeout::Error, "#{@service_name} didn't respond within #{@timeout} seconds."
    end
  end

  def self.fetch_request_uri(options = {})
    return unless options[:request_uri]
    options[:timeout] ||= 5
    options[:user_agent] ||= CONFIG.site_name
    if options[:api_endpoint]
      api_endpoint_cache = ApiEndpointCache.find_or_create_by(
          api_endpoint: options[:api_endpoint],
          request_url: options[:request_uri].to_s)
      return if api_endpoint_cache.in_progress?
      if api_endpoint_cache.cached?
        return Nokogiri::XML(api_endpoint_cache.response)
      end
    end
    response = nil
    begin
      if api_endpoint_cache
        api_endpoint_cache.update_attributes(request_began_at: Time.now,
                                             request_completed_at: nil, success: nil, response: nil)
      end
      timed_out = Timeout::timeout(options[:timeout]) do
        response = fetch_with_redirects(options)
      end
    rescue Timeout::Error
      if api_endpoint_cache
        api_endpoint_cache.update_attributes(
            request_completed_at: Time.now, success: false)
      end
      raise Timeout::Error
    end
    if api_endpoint_cache
      api_endpoint_cache.update_attributes(
          request_completed_at: Time.now, success: true, response: response.body)
    end
    Nokogiri::XML(response.body)
  end

  def self.fetch_with_redirects(options, attempts = 3)
    http = Net::HTTP.new(options[:request_uri].host, options[:request_uri].port)
    # using SSL if we have an https URL
    http.use_ssl = (options[:request_uri].scheme == "https")
    response = http.get("#{options[:request_uri].path}?#{options[:request_uri].query}",
                        "User-Agent" => options[:user_agent])
    # following redirects if we haven't followed too many already
    if response.is_a?(Net::HTTPRedirection) && attempts > 0
      options[:request_uri] = URI.parse(response["location"])
      return fetch_with_redirects(options, attempts - 1)
    end
    response
  end

end