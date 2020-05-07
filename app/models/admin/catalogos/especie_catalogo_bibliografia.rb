class Admin::EspecieCatalogoBibliografia < EspecieCatalogoBibliografia

  establish_connection :admin
  attr_accessor :biblio

end