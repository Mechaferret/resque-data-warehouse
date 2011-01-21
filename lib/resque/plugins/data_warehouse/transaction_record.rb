module Resque
  module Plugins
    module DataWarehouse
      class TransactionRecord
        attr_accessor :id, :type, :date, :values, :action
    
        def initialize(id, type, date = nil, values = nil, action = 'save')
          self.id     = id
          self.type   = type
          self.date   = date
          self.values = values
          self.action = action
          self
        end
    
        def from_json(data)
          data_array  = JSON.parse(data)
          self.date   = Time.parse(data_array[0])
          self.values = data_array[1]
          self.action = data_array[2]
          self
        end
    
        def transaction_key
          "#{self.type}_#{self.id}"
        end
    
        def transaction_data
          [self.date, self.values, self.action]
        end
    
        def fact
          @fact ||= Fact.find(self.type, self.values)
        end
    
        def get_lock
          redis = Resque.redis
          if redis.setnx("#{self.transaction_key}_lock", 1)
            puts "got lock"
            return true
          else
            puts "no lock"
            return false
          end
        end
    
        def release_lock
          redis = Resque.redis
          redis.del("#{self.transaction_key}_lock")
          puts "released lock"
        end
    
        def execute
          if self.action=='delete'
            self.fact.send("destroy")
          else
            self.fact.send("execute_transaction")
          end
        end
    
        def empty?
          self.id.blank? || self.type.blank? || self.date.blank?
        end
    
        def merge(t2)
          if t2.empty?
            return self
          elsif self.empty?
            return t2
          end
          d = (self.date <= t2.date) ? t2.date : self.date
          data = (self.date <= t2.date) ? t2.values : self.values
          action = (self.date <= t2.date) ? t2.action : self.action
          TransactionRecord.new(self.id, self.type, d, data, action)
        end
      end
    end
  end
end