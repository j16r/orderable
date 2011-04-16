module Orderable
  extend ActiveSupport::Concern

  included do
    class_inheritable_accessor :orderable_field
  end

  def self.adapter
    ActiveRecord::Base.connection.adapter_name.downcase
  end

  module ClassMethods
    
    def in_order
      order "#{quoted_orderable_field} ASC"
    end
    
    def orderable_field_is(field = nil)
      self.orderable_field = field.to_sym
    end
    
    def update_order(*id_array)
      id_array = Array.wrap(id_array).flatten.reject(&:blank?).map(&:to_i).uniq
      return if id_array.blank?
      update_all orderable_sql_for_ids(id_array), ['id IN (?)', id_array]
    end

    def quoted_orderable_field
      "#{quoted_table_name}.#{quoted_column}"
    end

    def quoted_column
      connection.quote_column_name(orderable_field)
    end

    def orderable_sql_for_ids(ids)
      ids = ids.join(",")
      case adapter = Orderable.adapter
      when /^mysql/
        ["#{quoted_column} = FIND_IN_SET(id, ?)", ids]
      when /^postgres/
        ["#{quoted_column} = STRPOS(?, ','||id||',')", ",#{ids},"]
      else
        raise ArgumentError, "The database adapter #{adapter} is not supported by orderable"
      end
    end

  end

end
