class CreateBackendConfigs < ActiveRecord::Migration
  def change
    create_table :backend_configs do |t|
      t.string :name
      t.string :type
      t.string :location
      t.text :status
      t.text :description

      t.timestamps null: false
    end
  end
end
