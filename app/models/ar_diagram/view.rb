module ArDiagram
  class View < ArDiagram::Base
    attr_accessible :name

    has_many :tables, :dependent => :destroy
    has_many :visible_tables, :class_name => "Table", :conditions => { :archive => false }

    validates_presence_of :name
    validates_uniqueness_of :name

    def to_param
      "#{id}-#{name.downcase.strip.gsub(/[^a-z0-9\- ]/i, '').gsub(/[ \-]+/, '-')}"
    end

    def new_table model
      self.dbd_tables.create({:name => model})
    end
  end
end
