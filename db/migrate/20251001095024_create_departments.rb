class CreateDepartments < ActiveRecord::Migration[6.1]
  def change
    create_table :departments do |t|
      t.string :name
      t.text :description
      t.bigint :parent_id

      t.timestamps
    end
  end
end
