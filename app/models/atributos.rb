class Atributos

  def self.alias(clase, terminacion)
    attr ||=''
    tabla=clase.to_s.underscore.pluralize.downcase
    clase.attribute_names.each do |a|

      if a.eql?('id')
        attr+="#{tabla}.#{a} AS id_#{terminacion}, "

      elsif a.eql?('created_at')
        attr+="#{tabla}.#{a} AS created_at_#{terminacion}, "

      elsif a.eql?('updated_at')
        attr+="#{tabla}.#{a} AS updated_at_#{terminacion}, "

      else
        attr+="#{tabla}.#{a}, "
      end
    end
    attr[0..-3]
  end

end