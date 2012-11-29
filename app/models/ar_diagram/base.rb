module ArDiagram
  class Base < ActiveRecord::Base
    self.abstract_class = true
    establish_connection(
        :adapter => "sqlite3",
        :database => "db/ar_diagram.sqlite3"
    )
  end
end