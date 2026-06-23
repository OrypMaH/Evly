class AddEducationalOrganizationIdToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :educational_organization_id, :integer
    
    add_foreign_key :events, :educational_organizations
  end
end
