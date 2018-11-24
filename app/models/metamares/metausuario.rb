class Metausuario < Usuario

  has_one :directorio, :foreign_key => :usuario_id, :class_name=> 'Metamares::Directorio'

  after_create :añade_directorio

  def añade_directorio
    directorio.new.save
  end

end