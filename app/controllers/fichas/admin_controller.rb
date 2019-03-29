class Fichas::AdminController < Fichas::FichasController

  before_action :set_ficha, only: [:edit, :update, :show, :destroy]
  #layout false

  def edit
    @form_params = { url: '/fichas/admin', method: 'post' }
  end

  def show

  end

  def set_ficha
    begin
      @taxon = Fichas::Taxon.where(IdCat: params[:id]).first

      especie = @taxon.especie
      especie.asigna_categorias

      @sin_info_msj = 'Sin información disponible'

      # A partir de la especie, acceder a:
      # I. Clasificación y descripción de la especie
      @nombre_comun = @taxon.nombreComun
      @legislacion = @taxon.legislaciones || Fichas::Legislacion.new
      @sinonimo = @taxon.sinonimos.first

      # II. Distribución de la especie
      @distribucion = @taxon.distribuciones.first || Fichas::Distribucion.new
      @endemica = @taxon.endemicas.first || Fichas::Endemica.new

      @habitat = @taxon.habitats.first || Fichas::Habitat.new
      # III. Tipo de ambiente en donde se desarrolla la especie
      @tipoClima = @habitat.tipoclima
      @suelo = @habitat.suelo
      @geoforma = @habitat.geoforma
      @ecorregion = @habitat.ecorregion.first
      @ecosistema = @habitat.ecosistema.first
      #@cat_eacorregionwwf = Cat_Ecorregionwwf.find_by(IdEcorregion: @ecorregion.ecorregionId)
      @habitatAntropico = @habitat.habitatAntropico

      # IV. Biología de la especie
      @demografiaAmenazas = @taxon.demografiaAmenazas.first || Fichas::Demografiaamenazas.new
      # V. Ecología y demografía de la especie
      @interaccion = @demografiaAmenazas.interaccion
      @amenazaDirecta = @demografiaAmenazas.amenazaDirecta.first

      # VI. Genética de la especie
      @historiaNatural = @taxon.historiaNatural || Fichas::Historianatural.new
      @infoReproduccion = @historiaNatural.get_info_reproduccion

      # VII. Importancia de la especie
      @culturaUsos = @historiaNatural.culturaUsos.first


      # VIII. Estado de conservación de la especie
      @conservacion = @taxon.conservacion.first || Fichas::Conservacion.new

      # IX. Especies prioritarias para la conservación
      #

      # X. Necesidades de información
      #

      # XI. Metadatos:
      @metadato = @taxon.metadatos.first

      if @metadato && @asociado = @metadato.asociado.first
        @organizacion = @asociado.organizacion
        @responsable = @asociado.responsable
        @puesto = @asociado.puesto
        @contacto = @asociado.contacto.first

        if @ciudad = @contacto.ciudad
          @pais = @ciudad.pais
        end
      end

      # XII. Referencias: (Agregado)
      @referencias = @taxon.referenciasBibliograficas

      @ficha = {
          taxon: @taxon, especie: especie,
          # I. Clasificación y descripción de la especie
          edad_peso_largo: @taxon.dame_edad_peso_largo,
          nombre_comun: @nombre_comun, legislaciones: @legislacion, sinonimo: @sinonimo,
          # II. Distribución de la especie
          distribucion: @distribucion, endemica: @endemica, habitat: @habitat,
          # III. Tipo de ambiente en donde se desarrolla la especie
          tipoClima: @tipoClima, suelo: @suelo, geoforma: @geoforma, ecorregion: @ecorregion, ecosistema: @ecosistema, cat_eacorregionwwf: @cat_eacorregionwwf,
          # IV. Biología de la especie
          historiaNatural: @historiaNatural, demografiaamenazas: @demografiaamenazas, infoReproduccion: @infoReproduccion,
          # V. Ecología y demografía de la especie
          interaccion: @interaccion,
          # VI. Genética de la especie
          # VII. Importancia de la especie
          culturaUsos: @culturaUsos,
          # VIII. Estado de conservación de la especie
          amenazaDirecta: @amenazaDirecta, conservacion: @conservacion,
          # IX. Especies prioritarias para la conservación
          # X. Necesidades de información
          # XI. Metadatos
          metadato: @metadato, asociado: @asociado, organizacion: @organizacion, responsable: @responsable, puesto: @puesto, contacto: @contacto, ciudad: @ciudad, pais: @pais,
          # XII. Referencias: (Agregado)
          referencias: @referencias
      }

    rescue
      render :_error and return
    end
  end

end