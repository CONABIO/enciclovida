class Fichas::AdminController < Fichas::FichasController



  def edit
    @form_params = { url: '/fichas/admin', method: 'post' }
    @taxon = Fichas::Taxon.find(1)
  end

end