require 'rack'
require 'json'
require 'jwt'
require 'concurrent'

class App
  SECRET = 'secret'
  @@products = {}
  @@next_id = Concurrent::AtomicFixnum.new(0)
  @@queue   = Queue.new

  def initialize
    start_worker
  end

  def call(env)
    req = Rack::Request.new(env)
    case [req.request_method, req.path_info]
    when %w[POST /auth]
      auth(req)
    when %w[POST /products]
      with_auth(req) { enqueue_product(req) }
    when %w[GET /products]
      with_auth(req) { list_products }
    else
      not_found
    end
  end

  private

  def auth(req)
    data = JSON.parse(req.body.read) rescue {}
    if data['user'] && data['password']
      token = JWT.encode({ user: data['user'], exp: Time.now.to_i + 3600 }, SECRET, 'HS256')
      json(200, token: token)
    else
      json(401, error: 'Invalid credentials')
    end
  end

  def with_auth(req)
    auth_header = req.get_header('HTTP_AUTHORIZATION').to_s
    token = auth_header[/^Bearer (.+)$/, 1]
    begin
      payload = JWT.decode(token, SECRET, true, algorithm: 'HS256')
      user = payload[0]['user']
      return json(401, error: 'Invalid token') unless user

      yield
    rescue
      json(401, error: 'Unauthorized')
    end
  end

  def enqueue_product(req)
    data = JSON.parse(req.body.read) rescue {}
    name = data['name'].to_s.strip
    return json(400, error: 'Name is required') if name.empty?

    @@queue << name
    json(202, status: 'accepted', message: 'Product will be created asynchronously')
  end

  def list_products
    list = @@products.values
    json(200, products: list)
  end

  def start_worker
    Thread.new do
      loop do
        name = @@queue.pop
        sleep 5
        id = @@next_id.increment
        @@products[id] = { 'id' => id, 'name' => name }
      end
    end
  end

  def json(status, body)
    [
      status,
      { 'Content-Type' => 'application/json' },
      [body.to_json]
    ]
  end

  def not_found
    [404, { 'Content-Type' => 'application/json' }, [{ error: 'Not Found' }.to_json]]
  end
end
