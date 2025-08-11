class EventAttendancesController < ApplicationController
  before_action :authenticate_user!, only: [ :create, :destroy, :update ]

  def create
    @event = Event.find(params[:event_id])
    already_invited = @event.event_attendances.exists?(attendee: @attendee)

    if @event.creator_id == current_user.id
      @attendee = User.find_by(username: params[:attendee_username])

      if already_invited
        flash[:alert] = "#{params[:attendee_username]} is already invited."
        redirect_to event_path(@event)

      elsif @attendee != nil
        @event_invitation = @event.event_attendances.build(attendee: @attendee, invitation_status: 0)

        if @event_invitation.save
          flash[:notice] = "Invitation sent to #{@attendee.username}!"
          redirect_to event_path(@event)

        else
          flash[:alert] = "Couldn’t send invitation to the #{@attendee.username}."
          redirect_to event_path(@event)

        end
      else
        flash[:alert] = "User #{@attendee.username} does not exist."
        redirect_to event_path(@event)

      end
    else user_signed_in?
      @event_invitation = @event.event_attendances.build(attendee: current_user, invitation_status: 1)
      if @event_invitation.save
        flash[:notice] = "See you there!"
        respond_to do |format|
          format.turbo_stream { render "event_attendances/update_attending", locals: { event: @event } }
        end
      else
        flash[:notice] = "An error occured, try again later."
      end
    end
  end

  def destroy
    @attendance = EventAttendance.find(params[:id])
    @event = Event.find(params[:event_id])
    @attendance.destroy

    if @attendance.destroyed?
      respond_to do |format|
        format.turbo_stream { render "event_attendances/update_attending", locals: { event: @event } }
      end
    end
  end

  def update
    attendance = EventAttendance.find_by(id: params[:id])
    new_status_casted = params[:invitation_status].to_i

    if new_status_casted == 1
      if attendance.update(invitation_status: new_status_casted)
        flash[:notice] = "See you there!"
        respond_to do |format|
          format.turbo_stream { render "event_attendances/update_attending", locals: { event: attendance.event } }
        end
      else
        flash[:notice] = "An error occured, try again later."
      end
    elsif new_status_casted == 0
      if attendance.update(invitation_status: new_status_casted)
        flash[:notice] = "You can still attend #{attendance.event.name} if you change your mind."
        respond_to do |format|
          format.turbo_stream { render "event_attendances/update_attending", locals: { event: attendance.event } }
        end
      else
        flash[:notice] = "An error occured, try again later."
      end
    else
      flash[:notice] = "An error occured, try again later."
    end
  end
end
