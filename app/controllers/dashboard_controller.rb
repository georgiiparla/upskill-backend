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

  # Thread-safe mantra rotation with self-healing
  def get_or_create_current_mantra_item
    key = 'mantra_rotation_lock'
    
    SystemSetting.transaction do
      # 1. Acquire Lock using existing ApplicationController helper
      # This ensures only one process checks/updates mantras at a time
      lock_record = find_or_create_system_setting_safely(key)
      lock_record.lock! 

      # 2. Re-fetch inside the lock to get the true latest state
      mantra_item = AgendaItem.where(is_system_mantra: true).order(created_at: :desc).first

      if mantra_item.nil?
        create_new_mantra_item
      elsif should_cycle_mantra?(mantra_item)
        create_new_mantra_item
      else
        # 3. Self-healing: If we are here, a valid mantra exists.
        # Check for and remove any accidental duplicates created before this patch.
        cleanup_duplicates(mantra_item)
      end
    end
  end

  def cleanup_duplicates(correct_item)
    # Destroy all system mantras that are NOT the current correct one
    duplicates = AgendaItem.where(is_system_mantra: true).where.not(id: correct_item.id)
    if duplicates.exists?
      count = duplicates.count
      duplicates.destroy_all
      settings.logger.info "Self-healing: Removed #{count} duplicate mantra(s)."
    end
  end

  def should_cycle_mantra?(mantra_item)
    Time.now - mantra_item.updated_at >= AppConfig::MANTRA_CYCLE_INTERVAL
  end

  def create_new_mantra_item
    mantras = Mantra.all
    return nil if mantras.empty?

    # Find the last used mantra to determine the next one
    last_mantra_item = AgendaItem.where(is_system_mantra: true).order(updated_at: :desc).first
    last_mantra = last_mantra_item&.mantra

    next_mantra = if last_mantra.nil?
                    mantras.first
                  else
                    current_index = mantras.pluck(:id).index(last_mantra.id) || 0
                    next_index = (current_index + 1) % mantras.count
                    mantras[next_index]
                  end

    # Explicitly remove old ones before creating new one (safety)
    AgendaItem.where(is_system_mantra: true).destroy_all

    mantra_item = AgendaItem.create!(
      title: "Mantra of the week: #{next_mantra.text}",
      icon_name: 'Star',
      is_system_mantra: true,
      mantra_id: next_mantra.id,
      editor: nil,
      due_date: Date.new(2025, 1, 1) # Placeholder date
    )

    ActivityStream.create(
      actor: nil,
      event_type: 'mantra_updated',
      target: mantra_item
    )
    
    mantra_item
  end
end