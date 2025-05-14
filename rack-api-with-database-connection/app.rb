require 'rack'
require 'json'
require 'jwt'
require 'concurrent'
require 'sequel'
require 'bcrypt'
require 'dotenv/load'

class App
  SECRET = ENV.fetch('JWT_SECRET')
  DB = Sequel.connect(ENV.fetch('DATABASE_URL'))
  Users = DB[:users]
  Products = DB[:products]
  @@queue = Queue.new

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

  # Autenticación contra tabla users
  def auth(req)
    data = JSON.parse(req.body.read) rescue {}
    user = Users.where(username: data['user']).first
    if user && BCrypt::Password.new(user[:password]) == data['password']
      token = JWT.encode({ user: data['user'], exp: Time.now.to_i + 3600 }, SECRET, 'HS256')
      json(200, token: token)
    else
      json(401, error: 'Invalid credentials')
    end
  end

  # Middleware de autorización: comprueba JWT y que el usuario exista
  def with_auth(req)
    auth_header = req.get_header('HTTP_AUTHORIZATION').to_s
    token = auth_header[/^Bearer (.+)$/, 1]
    begin
      payload, = JWT.decode(token, SECRET, true, algorithm: 'HS256')
      # validar que el usuario aún existe en la base
      return json(401, error: 'Invalid user') unless Users.where(username: payload['user']).count.positive?

      yield
    rescue JWT::ExpiredSignature
      json(401, error: 'Expired token')
    rescue StandardError
      json(401, error: 'Unauthorized')
    end
  end

  # Resto de métodos igual que antes...
  def enqueue_product(req)
    data = JSON.parse(req.body.read) rescue {}
    name = data['name'].to_s.strip
    return json(400, error: 'Name is required') if name.empty?

    @@queue << name
    json(202, status: 'accepted', message: 'Product will be created asynchronously')
  end

  def list_products
    products = Products.all.map { |r| { 'id' => r[:id], 'name' => r[:name] } }
    json(200, products: products)
  end

  def start_worker
    Thread.new do
      loop do
        name = @@queue.pop
        sleep 5
        Products.insert(name: name)
      end
    end
  end

  def json(status, body)
    [status, { 'Content-Type' => 'application/json' }, [body.to_json]]
  end

  def not_found
    [404, { 'Content-Type' => 'application/json' }, [{ error: 'Not Found' }.to_json]]
  end
end
