module Resque
  module Plugins
    module DataWarehouse
      class Transaction
        @queue = :transaction

        def self.perform(transaction_id, transaction_type, transaction_date)
          puts "Whee-hee, we're gonna work on a transaction for #{transaction_type} ID #{transaction_id} on #{transaction_date}\n"
          redis = Resque.redis
          record = TransactionRecord.new(transaction_id, transaction_type)
          got_lock = false
          retries = 0
          while (!got_lock && retries<2)
            if (got_lock=record.get_lock)
              num_trans = redis.llen(record.transaction_key)
              puts "we'll be processing #{num_trans} transactions\n"
              num_trans_actual = 0
              while (data = redis.lpop(record.transaction_key)) 
                num_trans_actual = num_trans_actual+1
                puts "transaction\n"
                next_record = TransactionRecord.new(transaction_id, transaction_type).from_json(data)
                puts "next_record is #{next_record.inspect}\n"
                record = record.merge(next_record)
                puts "merged is #{record.inspect}\n"
              end
              puts "Read #{num_trans_actual} transactions"
              puts "Final trans #{record.inspect}\n"
              record.execute unless num_trans_actual==0
              puts "done!"
              record.release_lock
            else
              retries = retries+1
            end
          end
        end
    
        def enqueue(model, action = 'save')
          record = TransactionRecord.new(model.id, model.class.to_s, model.updated_at, model.attributes, action)
          Resque.redis.rpush(record.transaction_key, record.transaction_data.to_json)
          Resque.enqueue(self.class, model.id, model.class.to_s, model.updated_at)
        rescue Exception => ex
          puts "transaction failing due to exception #{ex.inspect} #{ex.backtrace.join("\n")}"
        end
        
      end
    end
  end
end
