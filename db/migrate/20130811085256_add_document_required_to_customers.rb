class AddDocumentRequiredToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :document_required, :boolean
  end
end
