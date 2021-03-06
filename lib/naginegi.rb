require 'naginegi/version'
require 'naginegi/embulk_config'
require 'naginegi/embulk'
require 'naginegi/mysql'
require 'naginegi/postgresql'
require 'logger'

module Naginegi
  class EmbulkRunner
    def initialize(db_configs: nil, log_level: 'warn', embulk_run_option: '')
      @logger = Logger.new(STDOUT)
      @logger.datetime_format = '%Y-%m-%d %H:%M:%S'

      @db_configs = db_configs || YAML.load_file('database.yml')
      @log_level = log_level
      @embulk_run_option = embulk_run_option
    end

    def generate_config(bq_config)
      Naginegi::EmbulkConfig.new.generate_config(@db_configs, bq_config)
    end

    def run(bq_config, target_table_names = [], retry_max = 2)
      cmd = 'embulk --version'
      unless system(cmd)
        @logger.error('Cannot execute Embulk!!')
        @logger.error('Cofirm Embulk install and environment')
        return
      end

      error_tables = run_and_retry(bq_config, target_table_names, retry_max, 0)
      unless error_tables.empty?
        @logger.error('------------------------------------')
        @logger.error('[FAILED TABLES]')
        error_tables.each { |table| @logger.error(table) }
        @logger.error('------------------------------------')
      end

      error_tables.empty?
    end

    private

    def run_and_retry(bq_config, target_table_names, retry_max, retry_count)
      error_tables = Naginegi::Embulk.new(@log_level, @embulk_run_option).run(
        @db_configs,
        table_configs,
        bq_config,
        target_table_names
      )
      if !error_tables.empty? && retry_count < retry_max
        @logger.warn('------------------------------------')
        @logger.warn("retry start -> #{retry_count + 1} time")
        @logger.warn('------------------------------------')
        error_tables = run_and_retry(bq_config, error_tables, retry_max, retry_count + 1)
      end
      error_tables
    end

    def table_configs
      @table_configs ||= Naginegi::TableConfig.generate_table_configs
    end
  end
end
