require 'net/http'
require 'date'
require 'json'
require 'redis'
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::ERROR

current_date = Date.parse(Time.now.to_s)
formated_date = (current_date >> 1).strftime('%d/%m/%Y')

url = "http://api.bcb.gov.br/dados/serie/bcdata.sgs.1/dados?formato=json&dataInicial=#{formated_date}&dataFinal=#{formated_date}"

begin
  resp = Net::HTTP.get_response(URI.parse(url))
  json = JSON.parse(resp.body.to_s)
  currency = json.first()['valor']

  cache = Redis.new(:path => "/tmp/redis.sock")

  currency_value = cache.get("currency")

  if currency_value != currency
    puts cache.get("currency")
  else
    puts "It's updated!"
  end
rescue => err
  logger.error err.message
end
