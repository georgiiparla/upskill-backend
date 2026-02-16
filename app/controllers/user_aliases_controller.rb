class UserAliasesController < ApplicationController
  get '/' do
    protected!
    json current_user.email_aliases.order(created_at: :asc)
  end

  post '/' do
    protected!
    
    if current_user.email_aliases.any?
      json_error('Limit reached: You can only have one email alias.', 403)
    end

    email_to_add = @request_payload['email']&.strip&.downcase
    json_error('Email cannot be blank.', 400) if email_to_add.blank?

    alias_entry = current_user.email_aliases.new(email: email_to_add)

    if alias_entry.save
      status 201
      json alias_entry
    else
      json_error(alias_entry.errors.full_messages, 422)
    end
  end

  delete '/:id' do
    protected!
    
    alias_entry = current_user.email_aliases.find_by(id: params['id'])
    json_error('Alias not found or you do not have permission to delete it.', 404) unless alias_entry

    if alias_entry.destroy
      json({ message: 'Alias removed successfully.' })
    else
      json_error('Failed to remove alias.', 500)
    end
  end
end