class CreateArDiagramViews < ActiveRecord::Migration
  def change
    create_table :ar_diagram_views do |t|
      t.string :name
      t.float :zoom

      t.timestamps
    end
  end
end
