class DashboardController < ApplicationController
  get '/' do
    protected!
    agenda_items = AgendaItem.order(due_date: :asc)
    activity_stream = ActivityStream.includes(:user).order(created_at: :desc).limit(5)
    meetings = Meeting.order(meeting_date: :desc)
    
    activity_json = activity_stream.map do |activity|
      { id: activity.id, user_name: activity.user.username, action: activity.action, created_at: activity.created_at }
    end
    
    mock_activity_data = {
      personal: { quests: { allTime: 5, thisWeek: 1 }, feedback: { allTime: 8, thisWeek: 3 } },
      team: { quests: { allTime: 256, thisWeek: 12 }, feedback: { allTime: 891, thisWeek: 34 } }
    }

    json({ agendaItems: agenda_items, activityStream: activity_json, meetings: meetings, activityData: mock_activity_data })
  end
end