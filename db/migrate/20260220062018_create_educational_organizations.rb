class CreateEducationalOrganizations < ActiveRecord::Migration[6.1]
  def change
    create_table :educational_organizations do |t|
      t.string :name
      t.string :federal_district
      t.string :federal_subject

      t.timestamps
      
      t.index :name, unique: true
    end
  end
end
