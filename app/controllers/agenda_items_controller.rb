require_relative '../helpers/quest_updater'

class AgendaItemsController < ApplicationController
  
  VALID_ICONS = ['ClipboardList', 'BookOpen', 'FileText', 'MessageSquare', 'Lightbulb']

  patch '/:id' do
    protected!
    
    agenda_item = AgendaItem.find_by(id: params['id'])
    halt 404, json({ error: "Agenda item not found." }) unless agenda_item

    update_params = { editor: current_user } # Always set the current user as the editor

    if @request_payload.key?('title')
      new_title = @request_payload['title']
      max_length = 94
      halt 422, json({ errors: ["Title cannot be empty."] }) if new_title.strip.empty?
      halt 422, json({ errors: ["Title is too long (maximum #{max_length} characters)."] }) if new_title.length > max_length
      update_params[:title] = new_title
    end
    
    if @request_payload.key?('icon_name')
      new_icon = @request_payload['icon_name']
      halt 422, json({ errors: ["Invalid icon specified."] }) unless VALID_ICONS.include?(new_icon)
      update_params[:icon_name] = new_icon
    end

    if @request_payload.key?('link')
      update_params[:link] = @request_payload['link']
    end

    if agenda_item.update(update_params)
      ActivityStream.create(actor: current_user, event_type: 'agenda_updated', target: agenda_item)
      QuestUpdater.complete_for(current_user, 'update_agenda')
      
      json agenda_item.as_json.merge(
        editor_username: agenda_item.editor&.username
      )
    else
      status 422
      json({ errors: agenda_item.errors.full_messages })
    end
  end
end