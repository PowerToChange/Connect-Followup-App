class ConnectionsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @connections = current_user.connections
  end
end
