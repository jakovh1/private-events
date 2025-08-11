class EventsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :destroy, :update, :edit ]
  def index
    @past_events = Event.past
    @upcoming_events = Event.upcoming
    @all_attendances = EventAttendance.all
    @available_events = user_signed_in? ? Event.upcoming.accessible_to(current_user).includes(:event_attendances) : []
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.created_events.build(event_params)
    if @event.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_state
    end
  end
  def destroy
    event = Event.find(params[:id])
    event.destroy
    if event.destroyed?
      redirect_to root_path, status: :see_other
    else
      flash[:notice] = "An error occured, try again later."
      redirect_to :event_path, status: :unprocessable_entity
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    if @event.update(event_params)
      redirect_to @event
    else
      render :new, status: unprocessable_entity
    end
  end

  private

  def event_params
    params.expect(event: [ :name, :description, :date, :time, :access ])
  end
end
