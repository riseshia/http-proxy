require 'net/http'
require 'json'
require 'time'

class SimpleProxy
  def call(env)
    if env['REQUEST_METHOD'] == 'GET' && env['REQUEST_PATH'] == '/hello'
      res_200(Time.now.iso8601)
    elsif env['REQUEST_METHOD'] == 'POST' && env['REQUEST_PATH'] == '/'
      request_to_remote(env)
    else
      res_400
    end
  end

  private

  def request_to_remote(env)
    request = Rack::Request.new(env)
    to = request.params['to']
    request_method = request.params['method']
    data = JSON.load(request.params['data'] || '')

    if to && request_method == 'post'
      res = Net::HTTP.post_form(URI.parse(to), data)
      res_200(res.body)
    else
      res_400
    end
  end

  def res_400
    [400, {}, []]
  end

  def res_200(body)
    [200, {"Content-Type" => "text/html"}, [body]]
  end
end

run SimpleProxy.new
