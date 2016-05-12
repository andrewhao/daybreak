require 'trello'
require 'awesome_print'

include Trello

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_KEY']
  config.member_token         = ENV['TRELLO_TOKEN']
end

boards = {
  "personal" => ENV['TRELLO_BOARD_1_ID']
}

class MyTrello

  attr_accessor :widget_id, :board_id

  def initialize(widget_id, board_id)
    @widget_id = widget_id
    @board_id = board_id
  end

  def status_list
    status = Array.new

    board = Board.find(@board_id)
    board.lists.each do |list|
      status.push({label: list.name, value: list.cards.size})
    end
    status
  end
end

@MyTrello = []
boards.each do |widget_id, board_id|
  begin
    @MyTrello.push(MyTrello.new(widget_id, board_id))
  rescue Exception => e
    puts e.to_s
  end
end

SCHEDULER.every '5m', :first_in => 0 do |job|
  @MyTrello.each do |board|
    status = board.status_list
    send_event(board.widget_id, { :items => status })
  end
end
