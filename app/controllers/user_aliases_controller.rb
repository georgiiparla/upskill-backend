class UserAliasesController < ApplicationController
  get '/' do
    protected!
    json current_user.email_aliases.order(created_at: :asc)
  end

  post '/' do
    protected!
    
    if current_user.email_aliases.any?
      halt 403, json({ error: 'Limit reached: You can only have one email alias.' })
    end

    email_to_add = @request_payload['email']&.strip&.downcase
    halt 400, json({ error: 'Email cannot be blank.' }) if email_to_add.blank?

    alias_entry = current_user.email_aliases.new(email: email_to_add)

    if alias_entry.save
      status 201
      json alias_entry
    else
      status 422
      json({ errors: alias_entry.errors.full_messages })
    end
  end

  delete '/:id' do
    protected!
    
    alias_entry = current_user.email_aliases.find_by(id: params['id'])
    halt 404, json({ error: 'Alias not found or you do not have permission to delete it.' }) unless alias_entry

    if alias_entry.destroy
      json({ message: 'Alias removed successfully.' })
    else
      status 500
      json({ error: 'Failed to remove alias.' })
    end
  end
end