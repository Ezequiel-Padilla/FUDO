require_relative './app'

use Rack::Deflater
use Rack::Static,
    urls: %w[/openapi.yaml /AUTHORS],
    root: File.expand_path('./'),
    header_rules: [
      [%r{^/openapi\.yaml$}, { 'Cache-Control' => 'no-store' }],
      [%r{^/AUTHORS$}, { 'Cache-Control' => 'public, max-age=86400' }]
    ]

run App.new
