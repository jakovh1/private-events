class EventAttendance < ApplicationRecord
  belongs_to :attendee, class_name: "User"
  belongs_to :event

  enum :invitation_status, { pending: 0, accepted: 1 }
  scope :with_upcoming_events, -> { joins(:event).merge(Event.upcoming) }
end
