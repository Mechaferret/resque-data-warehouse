require 'resque/plugins/data_warehouse'
ActiveRecord::Base.send(:include, Resque::Plugins::DataWarehouse)
