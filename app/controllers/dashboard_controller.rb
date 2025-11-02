class DashboardController < ApplicationController
  get '/' do
    protected!
    agenda_items = AgendaItem.includes(:editor).order(due_date: :asc)

    agenda_items_json = agenda_items.map do |item|
      item.as_json.merge(editor_username: item.editor&.username)
    end

    activity_stream = ActivityStream.includes(:actor, :target).order(created_at: :desc).limit(10)
    
    activity_json = activity_stream.select { |a| a.target.present? }.map do |activity|
      target_info = case activity.target_type
                    when 'FeedbackRequest'
                      { type: 'feedback_request', title: activity.target.topic, tag: activity.target.tag }
                    when 'AgendaItem'
                      { type: 'agenda_item', title: activity.target.title }
                    else
                      nil
                    end

      { 
        id: activity.id, 
        user_name: activity.actor&.username || 'System', 
        event_type: activity.event_type,
        target_info: target_info,
        created_at: activity.created_at
      }
    end
    
    start_of_week = Time.now.beginning_of_week

    personal_feedback_all_time = current_user.feedback_submissions.count
    personal_feedback_this_week = current_user.feedback_submissions.where('created_at >= ?', start_of_week).count
    team_feedback_all_time = FeedbackSubmission.count
    team_feedback_this_week = FeedbackSubmission.where('created_at >= ?', start_of_week).count

    personal_requests_all_time = current_user.feedback_requests.count
    personal_requests_this_week = current_user.feedback_requests.where('created_at >= ?', start_of_week).count
    team_requests_all_time = FeedbackRequest.count
    team_requests_this_week = FeedbackRequest.where('created_at >= ?', start_of_week).count

    activity_data = {
      personal: {
        requests: { allTime: personal_requests_all_time, thisWeek: personal_requests_this_week },
        feedback: { allTime: personal_feedback_all_time, thisWeek: personal_feedback_this_week }
      },
      team: {
        requests: { allTime: team_requests_all_time, thisWeek: team_requests_this_week },
        feedback: { allTime: team_feedback_all_time, thisWeek: team_feedback_this_week }
      }
    }

    json({ 
      agendaItems: agenda_items_json, 
      activityStream: activity_json, 
      activityData: activity_data 
    })
  end
end