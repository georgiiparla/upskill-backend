class QuestsController < ApplicationController
  get '/' do
    protected!
    json Quest.order(id: :asc)
  end
end