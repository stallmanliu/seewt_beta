class CreateOcciTestModels < ActiveRecord::Migration
  def change
    create_table :occi_test_models do |t|
      t.sring :name
      t.text :description

      t.timestamps null: false
    end
  end
end
