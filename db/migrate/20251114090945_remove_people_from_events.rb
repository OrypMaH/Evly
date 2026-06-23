class RemovePeopleFromEvents < ActiveRecord::Migration[6.1]
  def change
    remove_column :events, :people, :integer
  end
end
