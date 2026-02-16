require_relative '../middleware/quest_middleware'

class AgendaItemsController < ApplicationController

  VALID_ICONS = ['ClipboardList', 'BookOpen', 'FileText', 'MessageSquare', 'Star']

  patch '/:id' do
    protected!
    
    agenda_item = AgendaItem.find_by(id: params['id'])
    json_error("Agenda item not found.", 404) unless agenda_item
    json_error("System mantras cannot be edited.", 422) if agenda_item.is_system_mantra

    update_params = { editor: current_user } # Always set the current user as the editor

    if @request_payload.key?('title')
      new_title = @request_payload['title']
      max_length = 94
      json_error(["Title cannot be empty."], 422) if new_title.strip.empty?
      json_error(["Title is too long (maximum #{max_length} characters)."], 422) if new_title.length > max_length
      update_params[:title] = new_title
    end
    
    if @request_payload.key?('icon_name')
      new_icon = @request_payload['icon_name']
      json_error(["Invalid icon specified."], 422) unless VALID_ICONS.include?(new_icon)
      update_params[:icon_name] = new_icon
    end

    if @request_payload.key?('link')
      new_link = @request_payload['link'].to_s.strip
      
      # FIX: Allow empty links (to clear them), but strictly validate non-empty links
      if new_link.present? && !new_link.match?(/\Ahttps?:\/\//i)
        json_error(["Link must start with http:// or https://"], 422)
      end

      update_params[:link] = new_link
    end

    if agenda_item.update(update_params)
      ActivityStream.create(actor: current_user, event_type: 'agenda_updated', target: agenda_item)
      QuestMiddleware.trigger(current_user, 'AgendaItemsController#update')
      
      json agenda_item.as_json.merge(
        editor_username: agenda_item.editor&.username,
        is_system_mantra: agenda_item.is_system_mantra
      )
    else
      json_error(agenda_item.errors.full_messages, 422)
    end
  end
end