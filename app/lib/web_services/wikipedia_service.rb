class WikipediaService < MetaService

  attr_accessor :base_url

  def initialize(options = {})
    super(options)
    locale = options[:locale] || I18n.locale || 'en'
    subdomain = locale.to_s.split('-').first
    self.base_url = "http://#{subdomain}.wikipedia.org"
    @endpoint = "#{self.base_url}/w/api.php?"
    @method_param = 'action'
    @default_params = { :format => 'xml' }
  end

  def url_for_title(title)
    "#{self.base_url}/wiki/#{title}"
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

end
