require 'sinatra/base'
require 'sinatra/json'

class QuestsController < Sinatra::Base
  # Hardcoded quest data that matches the frontend's expected structure.
  # In a real application, this would come from a database.
  MOCK_QUESTS = [
    { id: 1, title: 'Adaptability Ace', description: 'Complete the "Handling Change" module and score 90% on the quiz.', points: 150, progress: 100, completed: true },
    { id: 2, title: 'Communication Pro', description: 'Provide constructive feedback on 5 different project documents.', points: 200, progress: 60, completed: false },
    { id: 3, title: 'Leadership Leap', description: 'Lead a project planning session and submit the meeting notes.', points: 250, progress: 0, completed: false },
    { id: 4, title: 'Teamwork Titan', description: 'Successfully complete a paired programming challenge.', points: 100, progress: 100, completed: true },
  ]

  # GET /quests
  # Returns the list of all quests as a JSON array.
  get '/' do
    # The `json` helper method from sinatra-contrib automatically sets
    # the Content-Type header to application/json and serializes the data.
    json MOCK_QUESTS
  end
end