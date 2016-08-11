require 'telegram/bot'
require 'yaml'

Dir["./app/*.rb"].each {|file| require file }
require 'telegram/bot'

token = '221250387:AAEQ7dnfKBIr2_9FjIdr6wALbuxfEPCbUrc'

surprises = Array.new
requests = Array.new

File.open("data.csv", "r") do |f|
  f.each_line do |line|
    fields = line.split(",")
    surprises << Surprise.new(fields[1], fields[2])
  end
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    if message.text.upcase == "CANCELAR"
      requests.delete_if{ |r| r.chat.id == message.chat.id }

      bot.api.send_message(chat_id: message.chat.id, text: "Cancelado.")
      text = "Olá #{message.from.first_name}! Seu filho(a) preparou uma surpresa para você. Digite o código que você recebeu e siga as intruções."
      bot.api.send_message(chat_id: message.chat.id, text: text)
    elsif if message.text.upcase == "/start"
      text = "Olá #{message.from.first_name}! Seu filho(a) preparou uma surpresa para você. Digite o código que você recebeu e siga as intruções."
      bot.api.send_message(chat_id: message.chat.id, text: text)
    else
      request = requests.select{ |r| r.chat.id == message.chat.id }.first

      unless request
        surprise = surprises.select{ |s| s.code.downcase == message.text.downcase }.first
        if surprise
          requests << Request.new(message.chat, surprise)
          text = "Olá #{message.from.first_name}! Você está perto de ver a surpresa do seu filho(a), mas para isso precisa passar no teste ultra avançado do Espaço Criança. Digite OK para prosseguir."
        else
          text = "Ops, algo deu errado. Verifique o código e tente novamente."
        end
        bot.api.send_message(chat_id: message.chat.id, text: text) if text
      else
        case request.question
        when 1
          text = "Em que cidade está sendo realizada as Olimpíadas 2016?"
          request.next_question
        when 2
          text = "Muito bom! Vamos para a próxima pergunta.\nDas três bebidas qual não é saudável? Água, Coca-cola, Suco de Frutas."
          request.next_question
        when 3
          text = "Você está indo muito bem! Terceira e última pergunta.\nQual a comida saudável que seu filho(a) mais ama?"
          request.next_question
        when 4
          text = "Errado! Você tem mais uma chance.\nQual a comida saudável que seu filho(a) mais ama?"
          request.next_question
        when 5
          text = "Parabéns! Você passou em nosso teste ultra avançado!\nSeu filho(a) fez uma surpresa para demostrar todo amor que ele sente por você! Parabéns papai, você já é um campeão!\nClique no link e assista a surpresa.\n\n
          #{request.surprise.link}"
          request.next_question
        when 6
          text = "Já mandamos o link para você! Não temos mais nada para te enviar"
        end
        bot.api.send_message(chat_id: message.chat.id, text: text) if text
      end
    end

  end
end
