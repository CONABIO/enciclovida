require 'yaml'
require 'active_support/core_ext/hash'
require 'active_support/hash_with_indifferent_access'

class BuscadorConfig

  def initialize(config_file)
    if config_file.is_a? Hash
      @config = config_file
    else
      @config = YAML.load_file(config_file)[Rails.env]
    end

    @config = HashWithIndifferentAccess.new(@config)
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
