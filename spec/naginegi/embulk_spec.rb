require 'spec_helper'

RSpec.describe Naginegi::Embulk do
  describe '#select_table_configs' do
    subject { Naginegi::Embulk.new('warn', '').select_table_configs(table_configs, target_table_names) }

    context 'all tables' do
      let(:table_hoge) { Naginegi::TableConfig.new({ 'name' => 'hoge' }) }
      let(:table_fuga) { Naginegi::TableConfig.new({ 'name' => 'fuga' }) }
      let(:table_configs) { [table_hoge, table_fuga] }
      let(:target_table_names) { [] }
      it { expect(subject).to match(table_configs) }
    end

    context 'target table selected' do
      let(:table_hoge) { Naginegi::TableConfig.new({ 'name' => 'hoge' }) }
      let(:table_fuga) { Naginegi::TableConfig.new({ 'name' => 'fuga' }) }
      let(:table_configs) { [table_hoge, table_fuga] }
      let(:target_table_names) { ['hoge'] }
      it { expect(subject).to match([table_hoge]) }
    end
  end
end
