require "spec_helper"
require 'yaml'
require 'active_record/connection_handling'
require 'active_record'

ActiveRecord::Base.logger = Logger.new(STDOUT)

# We want connection host preference to be deterministic in tests
class NonRandomizingArray < Array
  def shuffle; self end
end

RSpec.describe ActiveRecord::ConnectionAdapters::PostgreSQLFallbackAdapter do
  let(:db_config) do
    # For minimal resistance, just allow the current user to connect to Postgres via TCP localhost
    # Otherwise, adjust database.yml to your needs
    config = YAML::load(File.open('spec/config/database.yml'))
    config['host'] ||= 'localhost'
    config['connect_timeout'] = 1
    config
  end
  
  def run_test_query
    ActiveRecord::Base.connection.query('SELECT 1')
  end
    
  after do
    ActiveRecord::Base.connection_pool.disconnect!
  end
    
  it "connects with no special behaviour when host is a string" do    
    ActiveRecord::Base.establish_connection(db_config)
    
    expect {
      run_test_query
    }.to_not raise_error
  end
  
  it "connects normally when a single host is passed in an array" do
    db_config['host'] = [db_config['host']]
    
    ActiveRecord::Base.establish_connection(db_config)
    
    expect {
      run_test_query
    }.to_not raise_error    
  end
  
  it 'connects to the second host when the first is unavailable' do
    db_config['host'] = NonRandomizingArray.new(['127.0.0.2', db_config['host']])
    
    ActiveRecord::Base.establish_connection(db_config)
    
    expect {
      run_test_query
    }.to_not raise_error 
  end
  
  it 'raises PG::ConnectionBad when all hosts fail' do
    db_config['host'] = ['127.0.0.2']
    
    ActiveRecord::Base.establish_connection(db_config)
    
    expect {
      run_test_query
    }.to raise_error(PG::ConnectionBad)    
  end
end
