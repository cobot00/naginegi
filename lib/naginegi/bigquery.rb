require 'json'
require 'erb'
require 'google/cloud/bigquery'
require 'unindent'
require 'date'

module Naginegi
  class BigQuery
    CONTENTS = <<-EOS.unindent
    in:
      type: <%= db_type %>
      user: <%= user %>
      password: <%= password %>
      database: <%= database %>
      host: <%= host %>
      options: <%= options %>
      query: |
        <%= query %>
    out:
      type: bigquery
      auth_method: <%= auth_method %>
      json_keyfile: <%= json_keyfile %>
      project: <%= project %>
      service_account_email: <%= service_account_email %>
      dataset: <%= dataset %>
      table: <%= table_name %>
      schema_file: <%= schema_file %>
      auto_create_table: true
      path_prefix: <%= path_prefix %>
      source_format: NEWLINE_DELIMITED_JSON
      file_ext: .json.gz
      delete_from_local_when_job_end: 1
      formatter:
        type: jsonl
      encoders:
      - {type: gzip}
    EOS

    def initialize(config)
      @config = config.dup
      @current_date = Date.today
    end

    def self.generate_schema(columns)
      json_body = columns.map(&:to_json).join(",\n")
      "[\n" + json_body + "\n]\n"
    end

    def self.generate_sql(table_config, columns)
      columns = columns.map(&:converted_value)
      sql = "SELECT #{columns.join(',')}"
      sql << " FROM #{table_config.name}"
      sql << " WHERE #{table_config.condition}" if table_config.condition
      sql << "\n"
      sql
    end

    def generate_embulk_config(db_name, database_config, table_config, columns)
      db_type = database_config['db_type']
      host = database_config['host']
      user = database_config['username']
      password = database_config['password']
      database = database_config['database']
      options = "{useLegacyDatetimeCode: false, serverTimezone: #{database_config['timezone']}}"
      query = Naginegi::BigQuery.generate_sql(table_config, columns)

      auth_method = @config['auth_method']
      json_keyfile = @config['json_keyfile']
      project = @config['project_id']
      service_account_email = @config['service_email']
      dataset = database_config['bq_dataset']
      table_name = actual_table_name(table_config.name, database_config['daily_snapshot'] || table_config.daily_snapshot)
      schema_file = "#{@config['schema_dir']}/#{db_name}/#{table_config.name}.json"
      path_prefix = "/var/tmp/embulk_#{db_name}_#{table_config.name}"

      ERB.new(CONTENTS).result(binding)
    end

    def delete_table(dataset, table_name)
      bq = Google::Cloud::Bigquery.new(
        project: @config['project_id'],
        keyfile: @config['json_keyfile']
      )
      bq.service.delete_table(dataset, table_name)
    end

    def actual_table_name(table_name, daily_snapshot)
      return table_name unless daily_snapshot
      table_name + @current_date.strftime('%Y%m%d')
    end
  end
end
