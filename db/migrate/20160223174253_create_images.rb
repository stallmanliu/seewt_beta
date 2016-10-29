class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :name
      t.string :type
      t.string :size
      t.string :location
      t.text :description

      t.timestamps null: false
    end
  end
end
