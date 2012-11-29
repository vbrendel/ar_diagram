class CreateArDiagramLabels < ActiveRecord::Migration
  def change
    create_table :ar_diagram_labels do |t|
      t.string :name
      t.string :color
    end
  end
end
