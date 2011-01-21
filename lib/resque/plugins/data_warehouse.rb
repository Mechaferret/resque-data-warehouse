module Resque
  module Plugins
    #
    # data_warehoused
    #
    module DataWarehouse
    	Dir[File.dirname(__FILE__) + '/data_warehouse/*.rb'].each{|g| require g}  
    	def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        def warehoused
          include InstanceMethods
          after_commit_on_save :record_to_fact
          after_destroy :destroy_fact
        end
      end
      
      module InstanceMethods
        def record_to_fact
          DataWarehouse::Transaction.new.enqueue(self)
        end

        def destroy_fact
          DataWarehouse::Transaction.new.enqueue(self, 'delete')
        end
      end

    end
  end
end
