class Plantid < ActiveRecord::Base
	self.abstract_class = true
	self.table_name_prefix  = 'pi_'
end