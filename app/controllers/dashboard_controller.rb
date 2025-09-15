class DashboardController < ApplicationController
  get '/' do
    protected!
    agenda_items = AgendaItem.order(due_date: :asc)
    activity_stream = ActivityStream.includes(:user).order(created_at: :desc).limit(5)
    meetings = Meeting.order(meeting_date: :desc)
    
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
        quests: { allTime: 0, thisWeek: 0 },
        feedback: { allTime: personal_feedback_all_time, thisWeek: personal_feedback_this_week }
      },
      team: {
        quests: { allTime: 0, thisWeek: 0 },
        feedback: { allTime: team_feedback_all_time, thisWeek: team_feedback_this_week }
      }
    }

    json({ agendaItems: agenda_items, activityStream: activity_json, meetings: meetings, activityData: activity_data })
  end
end