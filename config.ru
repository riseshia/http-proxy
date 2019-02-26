require 'net/http'
require 'json'

class SimpleProxy
  def call(env)
    unless env['REQUEST_METHOD'] == 'POST'
      return res_400
    end

    request = Rack::Request.new(env)
    to = request.params['to']
    request_method = request.params['method']
    data = JSON.load(request.params['data'] || "")

    if request_method == 'post'
      res = Net::HTTP.post_form(URI.parse(to), data)
      return [200, {"Content-Type" => "text/html"}, [res.body]]
    end

    res_400
  end

  private

  def res_400
    [400, {}, []]
  end
end

run SimpleProxy.new
