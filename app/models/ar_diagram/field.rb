module ArDiagram
  class Field < ArDiagram::Base
    belongs_to :table

    attr_accessible :name

    validates_uniqueness_of :name, :scope => :table_id

    def relationship
      return self.dbd_table.field_relationship self.name
    end
  end
end