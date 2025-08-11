class Event < ApplicationRecord
  belongs_to :creator, class_name: "User"

  has_many :event_attendances, foreign_key: "event_id", class_name: "EventAttendance", dependent: :destroy
  has_many :attendees, through: :event_attendances, source: :attendee

  validates :name, presence: true, length: { minimum: 5, maximum: 100 }
  validates :description, presence: true, length: { minimum: 5, maximum: 40000 }
  validates :date, presence: true
  validates :time, presence: true

  enum :access, { restricted: 0, open: 1 }

  scope :past, -> { where("datetime(date || ' ' || time) < ?", Time.zone.now) }
  scope :upcoming, -> { where("datetime(date || ' ' || time) > ?", Time.zone.now) }

  scope :accessible_to, ->(user) {
  where(
    arel_table[:access].eq(1)
    .or(
      arel_table[:id].in(user.event_attendances.select(:event_id))
    )
  )
  }
end
