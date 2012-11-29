module ArDiagram
  class Table < ArDiagram::Base
    belongs_to :label
    belongs_to :view
    has_many :fields, :dependent => :delete_all

    validates_uniqueness_of :name, :scope => :view_id

    attr_accessible :name
    attr_reader :field_relationships

    def add_fields fields = nil
      add_fields = fields || self.model.attribute_names
      add_fields.each do |field|
        self.dbd_fields.create({:name => field})
      end
    end

    def model
      begin
        return Object.const_get self.name
      rescue
        return nil
      end
    end

    def field_relationships
      return @field_relationships unless @field_relationships.nil?
      @field_relationships = {}
      self.model.reflect_on_all_associations.each do |relationship|
        @field_relationships[relationship.name] = relationship
      end
      @field_relationships
    end

    def field_relationship field
      return field_relationships[field]
    end
  end
end
