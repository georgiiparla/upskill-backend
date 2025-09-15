class DashboardController < ApplicationController
  get '/' do
    protected!
    agenda_items = AgendaItem.includes(:editor).order(due_date: :asc)
    activity_stream = ActivityStream.includes(:user).order(created_at: :desc).limit(5)
    meetings = Meeting.order(meeting_date: :desc)

    agenda_items_json = agenda_items.map do |item|
      item.as_json.merge(editor_username: item.editor&.username)
    end
    
    activity_json = activity_stream.map do |activity|
      { id: activity.id, user_name: activity.user.username, action: activity.action, created_at: activity.created_at }
    end
    
    
    start_of_week = Time.now.beginning_of_week

    personal_feedback_all_time = current_user.feedback_submissions.count
    personal_feedback_this_week = current_user.feedback_submissions.where('created_at >= ?', start_of_week).count

    team_feedback_all_time = FeedbackSubmission.count
    team_feedback_this_week = FeedbackSubmission.where('created_at >= ?', start_of_week).count

    activity_data = {
      personal: {
        quests: { allTime: "-", thisWeek: "-" },
        feedback: { allTime: personal_feedback_all_time, thisWeek: personal_feedback_this_week }
      },
      team: {
        quests: { allTime: "-", thisWeek: "-" },
        feedback: { allTime: team_feedback_all_time, thisWeek: team_feedback_this_week }
      }
    }

    json({ 
      agendaItems: agenda_items_json, 
      activityStream: activity_json, 
      meetings: meetings, 
      activityData: activity_data 
    })
  end
end