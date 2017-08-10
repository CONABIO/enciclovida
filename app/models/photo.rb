#encoding: utf-8
class Photo < ActiveRecord::Base

  belongs_to :usuario
  has_many :taxon_photos, :dependent => :destroy
  has_many :especies, :class_name => 'Especie', :through => :taxon_photos

  attr_accessor :api_response, :id, :usuario_id, :native_photo_id, :square_url, :thumb_url, :small_url, :medium_url, :large_url, :original_url, :created_at, :updated_at, :native_page_url, :native_username, :native_realname, :license, :type, :file_content_type, :file_file_name, :file_file_size, :file_processing, :mobile, :file_updated_at, :metadata
  serialize :metadata

  # licensing extras
  attr_accessor :make_license_default
  attr_accessor :make_licenses_same
  attr_accessor :attribution_txt  # Para poder ver la atribucion que ya viene armada en la API de naturalista
  MASS_ASSIGNABLE_ATTRIBUTES = [:make_license_default, :make_licenses_same]

  cattr_accessor :descendent_classes
  cattr_accessor :remote_descendent_classes

  before_save :set_license, :trim_fields
  #after_save :update_default_license,          #no son necesarias
  #           :update_all_licenses

  COPYRIGHT = 0
  NO_COPYRIGHT = 7

  LICENSES = [
      ['CC-BY', :cc_by_name, :cc_by_description],
      ['CC-BY-NC', :cc_by_nc_name, :cc_by_nc_description],
      ['CC-BY-SA', :cc_by_sa_name, :cc_by_sa_description],
      ['CC-BY-ND', :cc_by_nd_name, :cc_by_nd_description],
      ['CC-BY-NC-SA',:cc_by_nc_sa_name, :cc_by_nc_sa_description],
      ['CC-BY-NC-ND', :cc_by_nc_nd_name, :cc_by_nc_nd_description]
  ]

  LICENSE_CODES = LICENSES.map{|row| row.first}
  LICENSES.each do |code, name, description|
    const_set code.gsub(/\-/, '_'), code
  end

  LICENSE_INFO = {
      0 => {:code => 'C',                       :short => '(c)',          :name => 'Copyright', :url => 'http://en.wikipedia.org/wiki/Copyright'},
      1 => {:code => CC_BY_NC_SA,  :short => 'CC BY-NC-SA',  :name => 'Attribution-NonCommercial-ShareAlike License', :url => 'http://creativecommons.org/licenses/by-nc-sa/3.0/'},
      2 => {:code => CC_BY_NC,     :short => 'CC BY-NC',     :name => 'Attribution-NonCommercial License', :url => 'http://creativecommons.org/licenses/by-nc/3.0/'},
      3 => {:code => CC_BY_NC_ND,  :short => 'CC BY-NC-ND',  :name => 'Attribution-NonCommercial-NoDerivs License', :url => 'http://creativecommons.org/licenses/by-nc-nd/3.0/'},
      4 => {:code => CC_BY,        :short => 'CC BY',        :name => 'Attribution License', :url => 'http://creativecommons.org/licenses/by/3.0/'},
      5 => {:code => CC_BY_SA,     :short => 'CC BY-SA',     :name => 'Attribution-ShareAlike License', :url => 'http://creativecommons.org/licenses/by-sa/3.0/'},
      6 => {:code => CC_BY_ND,     :short => 'CC BY-ND',     :name => 'Attribution-NoDerivs License', :url => 'http://creativecommons.org/licenses/by-nd/3.0/'},
      7 => {:code => 'PD',                      :short => 'PD',           :name => 'Public domain', :url => 'http://en.wikipedia.org/wiki/Public_domain'},
      8 => {:code => 'GFDL',                    :short => 'GFDL',         :name => 'GNU Free Documentation License', :url => 'http://www.gnu.org/copyleft/fdl.html'}
  }
  LICENSE_NUMBERS = LICENSE_INFO.keys
  LICENSE_INFO.each do |number, info|
    const_set info[:code].upcase.gsub(/\-/, '_'), number
    const_set info[:code].upcase.gsub(/\-/, '_') + '_CODE', info[:code]
  end

  SQUARE = 75
  THUMB = 100
  SMALL = 240
  MEDIUM = 500
  LARGE = 1024

  def best_photo
    if original_url.present?
      original_url
    elsif medium_url.present?
      medium_url
    elsif large_url.present?
      large_url
    else
      nil
    end
  end

  def to_s
    "<#{self.class} id: #{id}, usuario_id: #{usuario_id}>"
  end

  def licensed_if_no_user
    if usuario.blank? && (license == COPYRIGHT || license.blank?)
      errors.add(
          :license,
          "must be set if the photo wasn't added by an #{CONFIG.site_name_short} user.")
    end
  end

  def set_license
    return true unless license.blank?
    return true unless usuario
    #self.license = Photo.license_number_for_code(user.preferred_photo_license)
    self.license = CC_BY_NC      #ya que el usuario no sube fotos propias, es por default esta licencia
    true
  end

  def trim_fields
    %w(native_realname native_username).each do |c|
      self.send("#{c}=", read_attribute(c).to_s[0..254]) if read_attribute(c)
    end
    true
  end

  # Return a string with attribution info about this photo
  def attribution
    if license == PD
      I18n.t('copyright.no_known_copyright_restrictions', :name => attribution_name, :license_name => I18n.t("copyright.#{license_name.gsub(' ','_').gsub('-','_').downcase}", :default => license_name))
    elsif open_licensed?
      I18n.t('copyright.some_rights_reserved_by', :name => attribution_name, :license_short => license_short)
    else
      I18n.t('copyright.all_rights_reserved', :name => attribution_name)
    end
  end

  def attribution_name
    if native_realname.present?
      native_realname
    elsif !native_username.blank?
      native_username
    else
      I18n.t('copyright.anonymous')
    end
  end

  def license_short
    LICENSE_INFO[license.to_i].try(:[], :short)
  end

  def license_name
    LICENSE_INFO[license.to_i].try(:[], :name)
  end

  def license_code
    LICENSE_INFO[license.to_i].try(:[], :code)
  end

  def license_url
    LICENSE_INFO[license.to_i].try(:[], :url)
  end

  def copyrighted?
    license.to_i == COPYRIGHT
  end

  def creative_commons?
    license.to_i > COPYRIGHT && license.to_i < NO_COPYRIGHT
  end

  def open_licensed?
    license.to_i > COPYRIGHT && license != PD
  end

  # Try to choose a single taxon for this photo.  Only works if class has 
  # implemented to_taxa
  def to_taxon
    return unless respond_to?(:to_taxa)
    photo_taxa = to_taxa(:lexicon => TaxonName::SCIENTIFIC_NAMES, :valid => true, :active => true)
    photo_taxa = to_taxa(:lexicon => TaxonName::SCIENTIFIC_NAMES) if photo_taxa.blank?
    photo_taxa = to_taxa if photo_taxa.blank?
    return if photo_taxa.blank?
    photo_taxa = photo_taxa.sort_by{|t| t.rank_level || Taxon::ROOT_LEVEL + 1}
    photo_taxa.detect(&:species_or_lower?) || photo_taxa.first
  end

  # Sync photo object with its native source.  Implemented by descendents
  def sync
    nil
  end

  def update_attributes(attributes)
    MASS_ASSIGNABLE_ATTRIBUTES.each do |a|
      self.send("#{a}=", attributes.delete(a.to_s)) if attributes.has_key?(a.to_s)
      self.send("#{a}=", attributes.delete(a)) if attributes.has_key?(a)
    end
    super(attributes)
  end

  def update_default_license
    return true unless [true, "1", "true"].include?(@make_license_default)
    user.update_attribute(:preferred_photo_license, Photo.license_code_for_number(license))
    true
  end

  def update_all_licenses
    return true unless [true, "1", "true"].include?(@make_licenses_same)
    Photo.update_all(["license = ?", license], ["user_id = ?", user_id])
    true
  end

  def editable_by?(user)
    return false if user.blank?
    user.id == user_id || observations.exists?(:user_id => user.id)
  end

  def orphaned?
    return false if taxon_photos.loaded? ? taxon_photos.size > 0 : taxon_photos.exists?
    true
  end

  def source_title
    self.class.name.gsub(/Photo$/, '').underscore.humanize.titleize
  end

  def best_url(size = "medium")
    size = size.to_s
    sizes = %w(original large medium small thumb square)
    size = "medium" unless sizes.include?(size)
    size_index = sizes.index(size)
    methods = sizes[size_index.to_i..-1].map{|s| "#{s}_url"} + ['original']
    try_methods(*methods)
  end

  def as_json(options = {})
    options[:except] ||= []
    options[:except] += [:metadata, :file_content_type, :file_file_name,
                         :file_file_size, :file_processing, :file_updated_at, :mobile]
                         #:original_url]
    options[:methods] ||= []
    options[:methods] += [:license_name, :license_url, :attribution]
    super(options)
  end

  # Retrieve info about a photo from its native source given its native id.  
  # Should be implemented by descendents
  def self.get_api_response(native_photo_id, options = {})
    nil
  end

  # Create a new Photo object from an API response.  Should be implemented by 
  # descendents
  def self.new_from_api_response(api_response, options = {})
    nil
  end

  # Destroy a photo if it no longer belongs to any observations or taxa
  def self.destroy_orphans(id)
    photos = where(:id => id)
    return if photos.blank?
    photos.each do |photo|
      photo.destroy if photo.orphaned?
    end
  end

  def self.license_number_for_code(code)
    return COPYRIGHT if code.blank?
    LICENSE_INFO.detect{|k,v| v[:code] == code}.try(:first)
  end

  def self.license_code_for_number(number)
    LICENSE_INFO[number].try(:[], :code)
  end

  def self.default_json_options
    {
        :methods => [:license_code, :attribution],
        :except => [:original_url, :file_processing, :file_file_size,
                    :file_content_type, :file_file_name, :mobile, :metadata, :user_id,
                    :native_realname, :native_photo_id]
    }
  end

  private

  def self.attributes_protected_by_default
    super - [inheritance_column]
  end
end
