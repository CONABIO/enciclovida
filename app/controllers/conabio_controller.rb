class ConabioController < ApplicationController
  #before_filter :return_here, :only => [:options]
  before_filter :authenticate_usuario!

  # Return a HTML fragment containing checkbox inputs for CONABIO photos.
  # Params:
  #   taxon_id:        a taxon_id
  #   q:        a search param
  def photo_fields
    @photos = []

    if params[:taxon_id].present?
      @taxon = Especie.find(params[:taxon_id])
      if @taxon.nombre_cientifico != params[:q]
        @taxon = Especie.where(:nombre_cientifico => params[:q]).first
      end
    end

    per_page = params[:limit].to_i
    per_page = 36 if per_page.blank? || per_page.to_i > 36
    page = params[:page].to_i
    page = 1 if page == 0
    offset = per_page*(page-1)+(page-1)
    limit = if offset > per_page
              75
            else
              per_page
            end

    @photos = ConabioPhoto::search_conabio(@taxon) if @taxon
    @photos = @photos[offset,per_page]

    partial = params[:partial].to_s
    partial = 'photo_list_form' unless %w(photo_list_form bootstrap_photo_list_form).include?(partial)
    render :partial => "photos/#{partial}", :locals => {
        :photos => @photos,
        :index => params[:index],
        :local_photos => false }
  end

end
