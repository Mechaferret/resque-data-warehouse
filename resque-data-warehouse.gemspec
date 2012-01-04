Gem::Specification.new do |s|
  s.name              = 'resque-data-warehouse'
  s.version           = '0.1.2'
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = 'A Resque plugin for using Resque and Redis to store and process transactions between transactional and data warehouse tables.'
  s.homepage          = 'http://github.com/mechaferret/resque-data-warehouse'
  s.email             = 'mechaferret@gmail.com'
  s.authors           = ['Monica McArthur']
  s.has_rdoc          = false

  s.files             = %w(README.md Rakefile LICENSE HISTORY.md)
  s.files            += Dir.glob('lib/**/*')
  s.files            += Dir.glob('test/**/*')

  s.add_dependency('resque',       '>= 1.9.10')
  s.add_dependency('rails',       ['>= 3.0.0'])
  s.add_dependency('json',       [">= 1.4.6", "< 1.6"])

  s.description       = <<desc
  A Resque plugin. Allows you to use Redis to queue up and then Resque to process transactions 
  on transaction-heavy tables that need to be replicated on other tables optimized for 
  reporting.
desc
end
