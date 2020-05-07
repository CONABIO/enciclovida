class Admin::EspecieCatalogoRegionBibliografia < EspecieCatalogoRegionBibliografia

  establish_connection :admin
  attr_accessor :biblio

end
