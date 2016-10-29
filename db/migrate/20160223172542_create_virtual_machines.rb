class CreateVirtualMachines < ActiveRecord::Migration
  def change
    create_table :virtual_machines do |t|
      t.string :name
      t.string :backend
      t.string :location
      t.string :status
      t.text :description

      t.timestamps null: false
    end
  end
end
