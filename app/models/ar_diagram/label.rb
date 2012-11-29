module ArDiagram
  class Label < ArDiagram::Base
    has_many :tables, :dependent => :nullify
  end
end