class DefaultFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::OutputSafetyHelper

  helpers = field_helpers +
            %w[date_select datetime_select time_select] +
            %w[collection_select select country_select time_zone_select] -
            %w[hidden_field label fields_for] # Don't decorate these

  custom_params = %w[description label label_after wrapper label_class field_value]

  helpers.each do |name|
    define_method(name) do |field, *args|
      options = args.extract_options!
      options = options.dup
      options[:field_name] = name

      if name == 'radio_button'
        options[:field_value] = args[0]
      end

      if %w[text_field file_field].include?(name.to_s)
        css_class = Array(options[:class] || '')
        css_class << 'text' if name == "text_field"
        css_class << 'file' if name == "file_field"
        options[:class] = css_class.uniq.join(' ')
        options[:wrapper] ||= {}
        options[:wrapper][:class] = "#{options[:wrapper][:class]} #{name}".strip
      end

      custom_params.each { |p| options.delete(p.to_sym) }

      field_content = super(field, *args, options)
      form_field(field, field_content, options)
    end
  end

  def time_zone_select(method, priority_zones = nil, options = {}, html_options = {})
    html_options[:class] = "#{html_options[:class]} time_zone_select".strip
    options[:include_blank] = true unless options.key?(:include_blank)
    
    field_content = @template.select(
      object_name,
      method,
      time_zone_options_for_select(priority_zones, options[:selected]),
      options,
      html_options
    )
    
    form_field(method, field_content, options.merge(html_options))
  end

  def form_field(field, field_content = nil, options = {}, &block)
    options = field_content if block_given?
    wrapper_options = options.delete(:wrapper) || {}
    wrapper_options[:class] = ["field", "#{field}_field", wrapper_options[:class]].compact.join(' ').strip
    
    label_content = build_label_content(field, options) if options[:label] != false
    description = build_description_content(options[:description]) if options[:description]
    
    content = block_given? ? @template.capture(&block) : field_content
    arranged_content = arrange_content(label_content, content, description, options)
    
    @template.content_tag(:div, arranged_content.html_safe, wrapper_options)
  end

  private

  def time_zone_options_for_select(priority_zones, selected)
    zones = ActiveSupport::TimeZone.all
    option_tags = []
    
    if priority_zones
      if priority_zones.is_a?(Regexp)
        priority_zones = zones.select { |z| z.to_s.match(priority_zones) }
      end
      option_tags += priority_zones.map { |z| time_zone_option_tag(z, selected) }
      option_tags << ["-------------", "", disabled: true]
    end
    
    option_tags += zones.map { |z| time_zone_option_tag(z, selected) }
    option_tags.join("\n").html_safe
  end

  def time_zone_option_tag(zone, selected)
    opts = {
      value: zone.name,
      data: {
        "time-zone-abbr" => zone.tzinfo&.current_period&.abbreviation.to_s,
        "time-zone-tzname" => zone.tzinfo&.name.to_s,
        "time-zone-offset" => zone.utc_offset,
        "time-zone-formatted-offset" => zone.formatted_offset
      }
    }
    opts[:selected] = "selected" if selected == zone.name
    content_tag(:option, zone.to_s, opts)
  end

  def build_label_content(field, options)
    label_field = if options[:field_name] == 'radio_button'
      "#{field}_#{options[:field_value]}".parameterize.underscore
    else
      field
    end

    label_tag = label(label_field, options[:label].to_s.html_safe, 
      class: options[:label_class])
    
    if options[:required]
      label_tag += content_tag(:span, " *", class: 'required')
    end
    
    content_tag(options[:label_after] ? :span : :div, label_tag, class: "inlabel")
  end

  def build_description_content(text)
    return unless text.present?
    content_tag(:div, text, class: "description")
  end

  def arrange_content(label, content, description, options)
    parts = []
    if options[:label_after]
      parts = [content, label, description]
    elsif options[:description_after]
      parts = [label, content, description]
    else
      parts = [label, description, content]
    end
    parts.compact.join(' ').html_safe
  end
end