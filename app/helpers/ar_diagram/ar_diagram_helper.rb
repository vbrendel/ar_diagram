module ArDiagram
  module ArDiagramHelper
    def field_relationships(table, field)
      relationship = {
          :belongs_to => [],
          :has_many => [],
          :has_one => [],
      }
      relationship[:belongs_to] = []
      relationship[:has_many] = []
      relationship[:has_one] = []

      prefix_match = /(^.*)\:\:/.match(table.name)
      prefix = prefix_match.nil? ? "" : "#{prefix_match[1].underscore}-"
      table_name_match = /.*\/(.*)/.match(table.name.underscore)
      table_name = table_name_match.nil? ? table.name.underscore : table_name_match[1]

      table.field_relationships.each_pair do |f, r|
        unless r.options[:through]
          case r.macro
            when :belongs_to
              relationship[r.macro] << "#{prefix}#{css_id(f.to_s.pluralize)}__id" if ("#{r.name}_id" == field)
            when :has_many, :has_one
              relationship[r.macro] << "#{prefix}#{css_id(f.to_s)}__#{table_name}_id" if (field == "id")
          end
        end
      end
      [].tap do |result|
        result << "data-belongs-to=#{relationship[:belongs_to].join(",")}" if relationship[:belongs_to].length > 0
        result << "data-has-many=#{relationship[:has_many].join(",")}" if relationship[:has_many].length > 0
        result << "data-has-one=#{relationship[:has_one].join(",")}" if relationship[:has_one].length > 0
      end.join(" ")
    end
  end
end
