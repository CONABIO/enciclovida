require 'yaml'
require 'active_support/core_ext/hash'
require 'active_support/hash_with_indifferent_access'

class BuscadorConfig

  def initialize(config_file)
    @config = if config_file.is_a?(Hash)
      config_file
    elsif config_file.is_a?(String) && File.exist?(config_file)
      YAML.load_file(config_file, aliases: true, permitted_classes: [Symbol])[Rails.env] || {}
    else
      raise ArgumentError, "Invalid config file: #{config_file.inspect}"
    end
    @config = ActiveSupport::HashWithIndifferentAccess.new(@config || {})
  end

  def to_hash
    @config
  end

  def method_missing(method_id, *args, &block)
    if @config.key? method_id
      value =  @config.fetch(method_id)
      if value.is_a? Hash
        value = BuscadorConfig.new(value)
      end
      value
    elsif @config.class.method_defined? method_id
      @config.send(method_id, *args, &block)
    else
      nil
    end
  end
end
