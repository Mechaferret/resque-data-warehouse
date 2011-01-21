class Transactional < ActiveRecord::Base
  warehoused
end

class TransactionalFact < ActiveRecord::Base
  def execute_transaction
    puts "executing transaction on transactional fact"
    self.save
  end
end