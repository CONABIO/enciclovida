class Region < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.Region"
  self.primary_key = 'IdRegion'

  # Los alias con las tablas de catalogos
  alias_attribute :id, :IdRegion
  alias_attribute :nombre_region, :NombreRegion
  alias_attribute :tipo_region_id, :IdTipoRegion
  alias_attribute :clave_region, :ClaveRegion
  alias_attribute :id_region_asc, :IdRegionAsc

  belongs_to :tipo_region, foreign_key: attribute_alias(:tipo_region_id)

  scope :validas, -> { where.not(nombre_region: 'ND') }
  scope :filtros, -> { select(:id, :nombre_region).select("descripcion").validas.where.not(clave_region: '').left_joins(:tipo_region).where("#{TipoRegion.table_name}.#{TipoRegion.attribute_alias(:descripcion)} IN ('#{TipoRegion::FILTRO.join("','")}')").order(:tipo_region_id, :nombre_region) }

  # TODO: Quitar este parche cuando las bibliografias de espeice_region esten relacionadas como se deben ...
  scope :select_observaciones, -> { select("*, #{EspecieRegion.table_name}.#{EspecieRegion.attribute_alias(:observaciones)} AS observaciones") }

  def self.regiones_asignadas(regiones)
    resp = {}

    regiones.each do |region|
      resp = region.asocia_regiones(resp)
    end

    resp
  end

  # Regresa un hash de los filtros con las regiones
  def self.dame_regiones_filtro
    regiones = {}

    filtros.each do |f|
      regiones[f.descripcion] = [] unless regiones[f.descripcion].present?
      regiones[f.descripcion] << f
    end

    regiones
  end

  def asocia_regiones(resp = {})
    region = {nombre: nombre_region, reg_desc: {}, observaciones: observaciones}

    # Es root
    if id_region_asc == id
      resp[id] = region
    else
      # El padre ya existia
      if resp[id_region_asc].present?
        resp[id_region_asc][:reg_desc][id] = region
      else  # No necesariamente es un root
        padre = Region.find(id_region_asc)
        resp[id_region_asc] = {nombre: padre.nombre_region, reg_desc: {}}
        resp[id_region_asc][:reg_desc][id] = region
      end
    end

    resp
  end

end
