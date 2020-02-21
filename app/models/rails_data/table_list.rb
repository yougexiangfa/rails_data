require 'csv'
module RailsData::TableList
  extend ActiveSupport::Concern
  included do
    include DataImportHelper
    attribute :parameters, :json, default: {}
    attribute :headers, :string, array: true, default: []
    attribute :footers, :string, array: true, default: []
    attribute :table_items_count, :integer, default: 0
    attribute :timestamp, :string
    attribute :done, :boolean
    attribute :published, :boolean

    belongs_to :data_list, optional: true
    has_many :table_items, dependent: :delete_all
  end

  def run
    clear_old
    export = DataCacheService.new(self)
    export.cache_table
  end

  def direct_xlsx
    _headers = self.headers.presence || self.data_list.headers
    export = RailsData::ExportService::Xlsx.new(data_list: self.data_list, params: self.parameters, headers: _headers)
    export.direct_xlsx
  end

  def cached_xlsx
    export = RailsData::ExportService::Xlsx.new(table_list: self)
    export.cached_xlsx
  end

  def to_ary
    ary = []
    ary << headers
    table_items.each do |table_item|
      ary << table_item.fields
    end
    ary
  end

  def to_csv
    csv = ''
    csv << headers.to_csv
    self.table_items.each do |table_item|
      csv << table_item.fields.to_csv
    end
    csv
  end

  def export_json(*columns)
    indexes = {}
    columns.each { |column| indexes.merge! column => headers.index(column) }
    indexes.compact!

    table_items.map do |table_item|
      r = {}
      indexes.each do |column, index|
        r.merge! column => table_item.fields[index]
      end
      r
    end
  end

  def cached_run(_timestamp = nil)
    unless self.timestamp.present? && self.timestamp == _timestamp.to_s
      self.timestamp = _timestamp
      run
    end
  end

  def clear_old
    self.done = false
    self.class.transaction do
      self.save!
      table_items.delete_all
    end
  end

  def file_name(format)
    name = self.id || 'example'
    "#{name}.#{format}"
  end

end
