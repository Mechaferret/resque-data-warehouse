require File.dirname(__FILE__) + '/test_helper'

class LockTest < Test::Unit::TestCase
  def setup
    $success = $lock_failed = $lock_expired = 0
    Resque.redis.flushall
    @worker = Resque::Worker.new(:transaction)
  end

  def test_lint
    assert_nothing_raised do
      Resque::Plugin.lint(Resque::Plugins::DataWarehouse)
    end
  end
  
  def test_create
    t = Transactional.new(:name=>'Test 1', :description=>'First transaction', :other_id=>2)
    t.save
    @worker.process
    tf = TransactionalFact.find(t.id)
    assert !tf.nil?
    assert tf.name==t.name
    assert tf.description==t.description
    assert tf.other_id==t.other_id
  end

  def test_update
    t = Transactional.new(:name=>'Test 1', :description=>'First transaction', :other_id=>2)
    t.save
    @worker.process
    tf = TransactionalFact.find(t.id)
    assert !tf.nil?
    assert tf.name==t.name
    assert tf.description==t.description
    assert tf.other_id==t.other_id
    t.description = 'Change me'
    t.save
    @worker.process
    tf = TransactionalFact.find(t.id)
    assert !tf.nil?
    assert tf.name==t.name
    assert tf.description==t.description
    assert tf.other_id==t.other_id
  end

  def test_delete
    t = Transactional.new(:name=>'Test 1', :description=>'First transaction', :other_id=>2)
    t.save
    @worker.process
    tf = TransactionalFact.find(t.id)
    assert !tf.nil?
    assert tf.name==t.name
    assert tf.description==t.description
    assert tf.other_id==t.other_id
    t.destroy
    @worker.process
    assert_raise(ActiveRecord::RecordNotFound) do
      tf = TransactionalFact.find(t.id)
    end
  end

  def test_multiple_transactions
    t = Transactional.new(:name=>'Test 1', :description=>'First transaction', :other_id=>2)
    t.save
    assert_raise(ActiveRecord::RecordNotFound) do
      tf = TransactionalFact.find(t.id)
    end
    t.description = 'Update me'
    t.save
    @worker.process
    tf = TransactionalFact.find(t.id)
    assert !tf.nil?
    assert tf.name==t.name
    assert tf.description==t.description
    assert tf.other_id==t.other_id
  end

end
