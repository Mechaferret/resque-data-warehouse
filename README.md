Resque Data Warehouse
=====================

A [Resque][rq] plugin. Requires Resque 1.9.10.

resque-data-warehouse allows you to use Redis to queue up and then Resque to process transactions 
on transaction-heavy tables that need to be replicated on other tables optimized for 
reporting. 

Transactions for a given object (classname + ID) are queued up behind a Redis key, 
and then processed using Resque jobs. If load is low, each transaction will be processed
almost immediately after it occurs; at higher loads, multiple transactions will queue up
before the Resque job gets to them, and then only the last transaction will be applied to the
data warehousing table, thus minimizing database load and dynamically adjusting the delay
in the copy to match the current load.

This only works with Rails; it has only been tested with Rails 2.3.4 in which case the after_commit
gem is also required.

Usage / Examples
----------------

Suppose you have a database class Transactional, that gets a lot of traffic, and you want to have a counterpart
to this class, TransactionalFact, in a data warehouse. All you need to do are the following:

* Create an ActiveRecord model named TransactionalFact, with all the instance variables you want in it.
* Add a method to TransactionalFact named execute_transaction, which assumes that all the fields in the fact that 
match the original Transactional are already set, saves them, and then performs any additional logic (denormalization, etc.)
to update any remaining fields.
* Require 'resque-data-warehouse' in Transactional, and add a line "warehoused".

Very simple examples of both classes:

    class Transactional < ActiveRecord::Base
      require 'resque-data-warehouse'
      warehoused
    end

    class TransactionalFact < ActiveRecord::Base
      def execute_transaction
        self.save
        # Any additional logic here
      end
    end

Customize & Extend
==================

No customizations are available right now, but some obvious ones (such as how to derive the name of the warehoused class)
are likely to occur soon.

Install
=======

### As a gem

    $ gem install resque-data-warehouse

### In a Rails app, as a plugin

    $ ./script/plugin install git://github.com/Mechaferret/resque-data-warehouse.git


Acknowledgements
================

Thanks to resque and Redis for making this work possible.

[rq]: http://github.com/defunkt/resque