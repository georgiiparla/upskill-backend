class DashboardController < ApplicationController
  get '/' do
    protected!
    
    # Ensure current system mantra exists and cycle if needed
    get_or_create_current_mantra_item
    
    agenda_items = AgendaItem.includes(:editor, :mantra).order(is_system_mantra: :desc, due_date: :asc)

    agenda_items_json = agenda_items.map do |item|
      item.as_json.merge(
        editor_username: item.editor&.username,
        is_system_mantra: item.is_system_mantra
      )
    end

    activity_stream = ActivityStream.includes(:actor, :target).order(created_at: :desc).limit(6)
    
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
        created_at: activity.created_at,
        formatted_date: activity.created_at.strftime('%d %b'),
        isNew: activity.created_at > current_user.last_viewed_activity_stream
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
      activityData: activity_data,
      hasUnviewedEvents: current_user.has_unviewed_activity_stream?
    })
  end

  post '/mark-activity-viewed' do
    protected!
    current_user.mark_activity_stream_viewed
    json({ success: true })
  end

  private

  def get_or_create_current_mantra_item
    mantra_item = AgendaItem.find_by(is_system_mantra: true)

    if mantra_item.nil?
      create_new_mantra_item
    elsif should_cycle_mantra?(mantra_item)
      create_new_mantra_item
    end
  end

  def should_cycle_mantra?(mantra_item)
    Time.now - mantra_item.updated_at >= AppConfig::MANTRA_CYCLE_INTERVAL
  end

  def create_new_mantra_item
    mantras = Mantra.all
    return nil if mantras.empty?

    last_mantra = AgendaItem.where(is_system_mantra: true).order(updated_at: :desc).limit(1).first&.mantra
    next_mantra = if last_mantra.nil?
                    mantras.first
                  else
                    current_index = mantras.pluck(:id).index(last_mantra.id)
                    next_index = (current_index + 1) % mantras.count
                    mantras[next_index]
                  end

    AgendaItem.where(is_system_mantra: true).destroy_all

    mantra_item = AgendaItem.create!(
      title: "Mantra of the week: #{next_mantra.text}",
      icon_name: 'Star',
      is_system_mantra: true,
      mantra_id: next_mantra.id,
      editor: nil,
      due_date: Date.new(2025, 1, 1)
    )

    ActivityStream.create(
      actor: nil,
      event_type: 'mantra_updated',
      target: mantra_item
    )

    mantra_item
  end
end