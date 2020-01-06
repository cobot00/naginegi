require 'naginegi/version'
require 'naginegi/embulk_utility'
require 'naginegi/embulk'
require 'naginegi/mysql'

module Naginegi
  class EmbulkClient
    def generate_config(bq_config)
      Naginegi::EmbulkUtility::ConfigGenerator.new.generate_config(database_configs, bq_config)
    end

    def run(bq_config, target_table_names = [], retry_max = 0)
      cmd = 'embulk --version'
      unless system(cmd)
        puts 'Cannot execute Embulk!!'
        puts 'Cofirm Embulk install and environment'
        return
      end

      error_tables = run_and_retry(bq_config, target_table_names, retry_max, 0)
      error_tables.empty?
    end

    private

    def run_and_retry(bq_config, target_table_names, retry_max, retry_count)
      error_tables = Naginegi::Embulk.new.run(
        database_configs,
        table_configs,
        bq_config,
        target_table_names
      )
      if !error_tables.empty? && retry_count < retry_max
        puts '------------------------------------'
        puts 'retry start -> #{retry_count + 1} time'
        puts '------------------------------------'
        error_tables = run_and_retry(bq_config, error_tables, retry_max, retry_count + 1)
      end
      error_tables
    end

    def database_configs
      @database_configs ||= YAML.load_file('database.yml')
    end

    def table_configs
      @table_configs ||= Naginegi::MySQL::TableConfig.generate_table_configs
    end
  end
end
