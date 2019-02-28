def datosLongevidadLargoPeso
  datos = {}
  datos[:longevidad] = {}
  datos[:peso] = {}
  datos[:largo] = {}
  datos[:estatus] = false

  if @taxon.edadinicialmachos.present? || @taxon.edadfinalmachos.present? || @taxon.edadinicialhembras.present? || @taxon.edadfinalhembras.present?
    datos[:longevidad][:datos] = []
    datos[:longevidad][:datos][:estatus] = true
    datos[:estatus] = true
    datos[:longevidad][:datos][0] = @taxon.edadinicialmachos
    datos[:longevidad][:datos][1] = @taxon.edadfinalmachos
    datos[:longevidad][:datos][2] = @taxon.edadinicialhembras
    datos[:longevidad][:datos][3] = @taxon.edadfinalhembras
  end




end

