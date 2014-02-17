class ConabioController < ApplicationController
  layout false

  # Return a HTML fragment containing checkbox inputs for CONABIO photos.
  # Params:
  #   taxon_id:        a taxon_id
  #   q:        a search param
  def photo_fields
    @photos = []
    @q = if !params[:q].blank?
      params[:q]
    elsif taxon_id = params[:taxon_id]
      @taxon = Especie.find(taxon_id)
      @taxon.name
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

    @photos = search_conabio(@q)
  end

  private

  def search_conabio(query)
    search_json = conabio(:server => 'bdi.conabio.gob.mx:9090', :timeout => 5, :photos => true).search(query)
    return [] if search_json.blank?

    JSON.parse(search_json)
  end

  def conabio(options = {})
    @conabio ||= ConabioService.new(options)
  end
end
