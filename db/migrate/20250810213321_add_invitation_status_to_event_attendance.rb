class AddInvitationStatusToEventAttendance < ActiveRecord::Migration[8.0]
  def change
    add_column :event_attendances, :invitation_status, :integer
  end
end
