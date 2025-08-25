require 'sinatra/json'
require_relative './application_controller'

class DashboardController < ApplicationController
  before do
    protected!
  end

  get '/' do
    # Standard data fetches
    agenda_items = DB.execute("SELECT * FROM agenda_items ORDER BY due_date ASC")

    activity_sql = <<-SQL
      SELECT 
        a.id,
        u.username AS user_name, 
        a.action, 
        a.created_at 
      FROM activity_stream a
      JOIN users u ON a.user_id = u.id
      ORDER BY a.id DESC LIMIT 5
    SQL
    activity_stream = DB.execute(activity_sql)

    meetings = DB.execute("SELECT * FROM meetings ORDER BY meeting_date DESC")

    # A single, structured mock object for all activity stats
    mock_activity_data = {
      personal: {
        quests:   { allTime: 5, thisWeek: 1 },
        feedback: { allTime: 8, thisWeek: 3 },
        points:   { allTime: 1250, thisWeek: 75 },
        streak:   14 # MODIFIED: Simplified to a single, logical value
      },
      team: {
        quests:   { allTime: 256, thisWeek: 12 },
        feedback: { allTime: 891, thisWeek: 34 },
      }
    }

    # --- Final JSON Response ---
    json({
      agendaItems: agenda_items,
      activityStream: activity_stream,
      meetings: meetings,
      activityData: mock_activity_data
    })
  end
end