class CreateArDiagramFields < ActiveRecord::Migration
  def change
    create_table :ar_diagram_fields do |t|
      t.string :name
      t.string :display_name
      t.string :description
      t.integer :relationship
      t.references :table

      t.timestamps
    end
  end
end
