class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :surname, limit: 50
      t.string :name, limit: 50
      t.string :patronymic, limit: 50
      t.string :contact, limit: 50
      t.string :password_digest

      t.timestamps
    end
  end
end
