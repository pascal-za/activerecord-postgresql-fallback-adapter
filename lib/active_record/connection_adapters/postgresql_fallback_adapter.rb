require 'active_support'
require 'active_support/deprecation'
require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionHandling
    def postgresql_fallback_connection(config)
      # See ActiveRecord::ConnectionHandling.postgresql_connection for original implementation
      
      conn_params = config.symbolize_keys
      conn_params.delete_if { |_, v| v.nil? }
      conn_params[:user] = conn_params.delete(:username) if conn_params[:username]
      conn_params[:dbname] = conn_params.delete(:database) if conn_params[:database]

      valid_conn_param_keys = PG::Connection.conndefaults_hash.keys + [:requiressl]
      conn_params.slice!(*valid_conn_param_keys)

      ConnectionAdapters::PostgreSQLFallbackAdapter.new(nil, logger, conn_params, config)
    end
  end

  module ConnectionAdapters
    class PostgreSQLFallbackAdapter < PostgreSQLAdapter
      def connect
        if @connection_parameters[:host].respond_to?(:each)
          @connection_parameters[:host].shuffle.each do |host|
            begin
              @connection = PG::Connection.new(@connection_parameters.merge(host: host))
             
              break
            rescue ::PG::ConnectionBad
              logger.error "[PostgreSQL] Failed to connect to host #{host}"
              @connection = nil
            end
          end
 
          unless @connection         
            sleep rand(0.5..2.0) # Avoid DoS of upstream hosts during a reconnect storm (such as during data center problems)
            raise ::PG::ConnectionBad.new("No hosts usable amongst #{@connection_parameters[:host].inspect}")
          end
        else
          @connection = PG::Connection.new(@connection_parameters)
        end

        # Compatibility with Rails 4
        if OID::Money.respond_to?(:precision)
          OID::Money.precision = (postgresql_version >= 80300) ? 19 : 10 
        end

        configure_connection
      rescue ::PG::Error => error
        if error.message.include?("does not exist")
          raise ActiveRecord::NoDatabaseError.new(error.message, error)
        else
          raise
        end
      end

      def exec_no_cache(sql, name, binds)
        type_casted_binds = (respond_to?(:type_casted_binds))? type_casted_binds(binds) : binds
        
        log(sql, name, binds, type_casted_binds) do
          connect unless @connection
          
          begin
            @connection.async_exec(sql, type_casted_binds)
          rescue ::PG::ConnectionBad => e
            disconnect!
            connect
            raise e
          end            
        end
      end
    end
  end
end