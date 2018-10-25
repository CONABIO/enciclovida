class Metamares::Dato < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.datos"

  ESTATUS_DATOS = ['Public access'.to_sym, 'Restricted access'.to_sym, 'Private access'.to_sym]
  CREATIVE_COMMONS = [:cc0, :cc_by, :cc_by_nc, :cc_by_sa, :cc_by_nd, :cc_by_nc_sa, :cc_by_nc_nd, :no_licence]

end