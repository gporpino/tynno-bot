

class Request
  attr_accessor :chat, :question, :surprise

  def initialize chat, surprise
    @question = 1
    @chat = chat
    @surprise = surprise
  end

  def next_question
    @question += 1
  end
end
