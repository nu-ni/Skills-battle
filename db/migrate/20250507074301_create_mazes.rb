class CreateMazes < ActiveRecord::Migration[8.0]
  def change
    create_table :mazes do |t|
      t.string :name
      t.string :creator
      t.integer :size
      t.integer :difficulty
      t.text :remark
      t.text :data
      t.text :solution
      t.integer :solution_length

      t.timestamps
    end
  end
end
