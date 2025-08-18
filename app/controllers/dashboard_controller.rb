require 'sinatra/base'
require 'sinatra/json'

class DashboardController < Sinatra::Base
  # Engagement data is complex to calculate, so we'll keep it as mock data.
  # In a real app, this would be the result of an analytics query.
  MOCK_TEAM_ENGAGEMENT_DATA = [
    { category: 'Quests', value: 75, fullMark: 100 },
    { category: 'Feedback', value: 85, fullMark: 100 },
    { category: 'Meetings', value: 90, fullMark: 100 },
    { category: 'Knowledge', value: 60, fullMark: 100 },
    { category: 'Skills', value: 70, fullMark: 100 },
  ]
  MOCK_PERSONAL_ENGAGEMENT_DATA = [
    { category: 'Quests', value: 95, fullMark: 100 },
    { category: 'Feedback', value: 60, fullMark: 100 },
    { category: 'Meetings', value: 100, fullMark: 100 },
    { category: 'Knowledge', value: 80, fullMark: 100 },
    { category: 'Skills', value: 45, fullMark: 100 },
  ]

  get '/' do
    # Fetch all dashboard data from the database in separate queries
    agenda_items = DB.execute("SELECT * FROM agenda_items ORDER BY due_date ASC")
    activity_stream = DB.execute("SELECT * FROM activity_stream ORDER BY id DESC LIMIT 5")
    meetings = DB.execute("SELECT * FROM meetings ORDER BY meeting_date DESC")

    # Respond with a single JSON object containing all the data
    json({
      agendaItems: agenda_items,
      activityStream: activity_stream,
      meetings: meetings,
      teamEngagement: MOCK_TEAM_ENGAGEMENT_DATA,
      personalEngagement: MOCK_PERSONAL_ENGAGEMENT_DATA
    })
  end
end