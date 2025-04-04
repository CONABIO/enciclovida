class Catalogo < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.CatalogoNombre"
  self.primary_key = 'IdCatNombre'

  attr_accessor :sigla

  # Los alias con las tablas de catalogos
  alias_attribute :id, :IdCatNombre
  alias_attribute :descripcion, :Descripcion
  alias_attribute :nivel1, :Nivel1
  alias_attribute :nivel2, :Nivel2
  alias_attribute :nivel3, :Nivel3
  alias_attribute :nivel4, :Nivel4
  alias_attribute :nivel5, :Nivel5
  alias_attribute :nivel6, :Nivel6
  alias_attribute :nivel7, :Nivel7

  scope :nom, -> { where(nivel1: 4, nivel2: 1).where("#{attribute_alias(:nivel3)} > 0") }
  scope :iucn, -> { where(nivel1: 4, nivel2: 2).where("#{attribute_alias(:nivel3)} > 0").where.not(descripcion: 'Riesgo bajo (LR): Dependiente de conservación (cd)') }
  scope :cites, -> { where(nivel1: 4, nivel2: 3).where("#{attribute_alias(:nivel3)} > 0") }
  scope :prioritarias, -> { where(nivel1: 4, nivel2: 4).where("#{attribute_alias(:nivel3)} > 0") }
  scope :ambientes, -> { where(nivel1: 2, nivel2: 6).where("#{attribute_alias(:nivel3)} > 0").where.not(descripcion: AMBIENTE_EQUIV_MARINO) }
  scope :usos, -> { where(id: USOS).order(:descripcion) }
  scope :evaluacion_conabio, -> { where(nivel1: 4, nivel2: 6).where("#{attribute_alias(:nivel3)} > 0").where("#{attribute_alias(:nivel3)} < 4") }
  scope :formas_crecimiento, -> { where(nivel1: 18, nivel3: 0).where("#{attribute_alias(:nivel2)} > 0").order(:descripcion) }

  AMBIENTE_EQUIV_MARINO = ['Nerítico', 'Nerítico y oceánico', 'Oceánico']
  USOS = [1216, 1217, 464, 1058, 465, 468, 469, 470, 471, 1055, 1057, 1056, 2381, 2386]
  EVALUACION = ['Extinto (EX)','Extinto en estado silvestre (EW)','Datos insuficientes (DD)']  # Evaluaciones que no tienen datos, se quitan de la busqueda

  # REVISADO: Regresa true or false si el catalogo es de los permitidos a mostrar
  def es_catalogo_permitido?
    [4,11,18,25].include?(nivel1) || (nivel1 == 2 && nivel2 == 6 && nivel3>0)
  end

  def es_nom?
    nivel1 == 4 && nivel2 == 1 && nivel3 > 0
  end

  def es_iucn?
    nivel1 == 4 && nivel2 == 2 && nivel3 > 0
  end
  
  def es_cites?
    nivel1 == 4 && nivel2 == 3 && nivel3 > 0
  end  

  def es_ambiente?
    nivel1 == 2 && nivel2 == 6 && nivel3 > 0
  end

  def es_usos?
    USOS.include?(id)
  end

  # REVISADO: Regresa la categoria superior del nombre del catalogo
  def dame_nombre_catalogo
    if nivel1 == 18
      if cat = Catalogo.where(nivel1: nivel1, nivel2: 0, nivel3: 0).first
        cat.descripcion
      end

    else
      if cat = Catalogo.where(nivel1: nivel1, nivel2:nivel2, nivel3: 0).first
        cat.descripcion
      else
        'No determinado'
      end
    end
  end

  # REVISADO: regresa todos los ambientes
  def self.ambiente_todos
    ambientes
  end

  # REVISADO: Las categorias de conservacion para la busqueda avanzada
  def self.nom_cites_iucn_todos
    nom = self.nom
    nom = [nom[2],nom[0],nom[1],nom[3]]  # Orden propuesto por cgalindo
    iucn = self.iucn
    iucn = [iucn[0],iucn[1],iucn[2],iucn[3],iucn[4]]  # Orden propuesto por cgalindo
    cites = self.cites

    evaluacion_conabio = self.evaluacion_conabio
    evaluacion_conabio.each do |eval|
      eval.sigla = eval.descripcion.split('(')[1].gsub(')','')
      eval.descripcion = eval.descripcion + ' Evaluación CONABIO'
    end

    { nom: nom, iucn: iucn, evaluacion_conabio: evaluacion_conabio, cites: cites }
  end

  # REVISADO: Regresa todas las proritarias
  def self.prioritaria_todas
    prioritarias
  end
end
