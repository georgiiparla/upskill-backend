require 'sinatra/base'
require 'sinatra/json'

class LeaderboardController < Sinatra::Base
  # In a real app, this data would come from a database, likely sorted by points.
  MOCK_LEADERBOARD = [
    { id: 1, name: 'Alex Rivera', points: 4250, badges: ['🚀', '🎯', '🔥'] },
    { id: 2, name: 'Casey Jordan', points: 3980, badges: ['💡', '🎯'] },
    { id: 3, name: 'Taylor Morgan', points: 3710, badges: ['🤝'] },
    { id: 4, name: 'Jordan Smith', points: 3500, badges: ['🚀'] },
    { id: 5, name: 'Jamie Lee', points: 3200, badges: ['💡', '🤝'] },
    { id: 6, name: 'Morgan Quinn', points: 2950, badges: ['🎯'] },
    { id: 7, name: 'Riley Chen', points: 2810, badges: ['🔥', '🤝'] },
    { id: 8, name: 'Devin Patel', points: 2650, badges: ['💡'] },
    { id: 9, name: 'Skyler Kim', points: 2400, badges: ['🚀', '🎯'] },
    { id: 10, name: 'Avery Garcia', points: 2230, badges: ['🤝'] },
    { id: 11, name: 'Parker Williams', points: 2100, badges: ['💡'] },
    { id: 12, name: 'Cameron Ito', points: 1980, badges: ['🔥'] },
    { id: 13, name: 'Rowan Davis', points: 1850, badges: ['🚀'] },
    { id: 14, name: 'Kai Martinez', points: 1720, badges: ['🎯', '🤝'] },
    { id: 15, name: 'Logan Rodriguez', points: 1600, badges: ['💡'] },
  ]

  # GET /leaderboard
  # Returns the entire leaderboard list as a JSON array.
  get '/' do
    json MOCK_LEADERBOARD
  end
end