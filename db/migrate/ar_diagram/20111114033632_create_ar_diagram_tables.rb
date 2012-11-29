class CreateArDiagramTables < ActiveRecord::Migration
  def change
    create_table :ar_diagram_tables do |t|
      t.string :name
      t.string :display_name
      t.boolean :archive
      t.text :description
      t.references :label
      t.references :view

      t.integer :position_x
      t.integer :position_y

      t.timestamps
    end
    add_index :ar_diagram_tables, :label_id
  end
end
