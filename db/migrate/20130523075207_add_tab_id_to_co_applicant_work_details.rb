class AddTabIdToCoApplicantWorkDetails < ActiveRecord::Migration
  def change
    add_column :co_applicant_work_details, :tab_id, :integer
  end
end
