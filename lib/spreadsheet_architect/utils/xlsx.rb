module SpreadsheetArchitect
  module Utils
    module XLSX

      def self.get_type(value, type=nil)
        return type unless (type.respond_to?(:empty?) ? type.empty? : type.nil?)
        
        if value.is_a?(Numeric)
          if value.is_a?(Float) || value.is_a?(BigDecimal)
            type = :float
          else
            type = :integer
          end
        elsif value.respond_to?(:strftime)
          if value.is_a?(DateTime) || value.is_a?(Time)
            type = :time
          else
            type = :date
          end
        else
          type = :string
        end

        return type
      end

      def self.convert_styles_to_axlsx(styles={})
        styles = {} unless styles.is_a?(Hash)
        styles = self.symbolize_keys(styles)

        if styles[:color].respond_to?(:sub) && !styles[:color].empty?
          styles[:fg_color] = styles.delete(:color).sub('#','')
        end

        if styles[:background_color].respond_to?(:sub) && !styles[:background_color].empty?
          styles[:bg_color] = styles.delete(:background_color).sub('#','')
        end

        if styles[:align]
          if styles[:align].is_a?(Hash)
            styles[:alignment] = {horizontal: styles[:align][:horizontal], vertical: styles[:align][:vertical]}
            styles.delete(:align)
          else
            styles[:alignment] = {horizontal: styles.delete(:align)}
          end
        end
        styles[:b] = styles.delete(:bold) || styles[:b]
        styles[:sz] = styles.delete(:font_size) || styles[:sz]
        styles[:i] = styles.delete(:italic) || styles[:i]
        styles[:u] = styles.delete(:underline) || styles[:u]

        styles.delete_if{|k,v| v.nil?}
      end

      def self.range_hash_to_str(hash, num_columns, num_rows, col_names=Array('A'..'ZZZ'))
        case hash[:columns]
        when Integer
          start_col = end_col = col_names[hash[:columns]]
        when Range
          start_col = col_names[hash[:columns].first]
          end_col = col_names[hash[:columns].last]
        when Symbol
          start_col = 'A'
          end_col = col_names[num_columns-1]
        else
          raise SpreadsheetArchitect::Exceptions::InvalidRangeStylesOptionError.new(:columns)
        end

        case hash[:rows]
        when Integer
          start_row = end_row = hash[:rows]
        when Range
          start_row = hash[:rows].first
          end_row = hash[:rows].last
        when Symbol
          start_row = 0
          end_row = num_rows-1
        else
          raise SpreadsheetArchitect::Exceptions::InvalidRangeStylesOptionError.new(:rows)
        end

        return "#{start_col}#{start_row}:#{end_col}#{end_row}"
      end

      def self.verify_range(range, num_rows, col_names=Array('A'..'ZZZ'))
        if range.is_a?(String)
          if range.include?(':')
            front, back = range.split(':')
            start_col, start_row = front.scan(/\d+|\D+/)
            end_col, end_row = back.scan(/\d+|\D+/)

            unless col_names.include?(start_col) && col_names.include?(end_col)
              raise SpreadsheetArchitect::Exceptions::BadRangeError.new(:columns)
            end
            
            unless start_row.to_i <= num_rows && end_row.to_i <= num_rows
              raise SpreadsheetArchitect::Exceptions::BadRangeError.new(:rows)
            end
          else
            raise SpreadsheetArchitect::Exceptions::BadRangeError.new(:format)
          end
        else
          raise SpreadsheetArchitect::Exceptions::BadRangeError.new(:type)
        end
      end

      private

      # only converts the first 2 levels
      def self.symbolize_keys(hash={})
        new_hash = {}
        hash.each do |k,v|
          if v.is_a?(Hash)
            v.each do |k2,v2|
              new_hash[k2.to_sym] = v2
            end
          else
            new_hash[k.to_sym] = v
          end
        end
        return new_hash
      end

    end
  end
end
