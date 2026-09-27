# frozen_string_literal: true
# Lives in initializers rather than lib/ so Zeitwerk does not try to autoload
# it under the OmniAuth namespace; it loads before omniauth.rb by name order.

require 'omniauth'
require 'jwt'
require 'net/http'

module OmniAuth
  module Strategies
    # Signs in whoever Cloudflare Access already verified. Access puts a signed
    # JWT in the Cf-Access-Jwt-Assertion header on every request that passed
    # its policy; we verify the signature against the team's public keys and
    # the audience tag of our Access application, then use the email as the
    # user id. Nothing here trusts a plain header on its own.
    class CloudflareAccess
      include OmniAuth::Strategy

      option :name, 'cloudflare_access'
      option :team_domain, nil
      option :audience, nil

      def request_phase
        redirect callback_url
      end

      def callback_phase
        token = request.env['HTTP_CF_ACCESS_JWT_ASSERTION'] || request.cookies['CF_Authorization']
        if token.blank?
          Rails.logger.warn("cloudflare_access: no Cf-Access-Jwt-Assertion header on #{request.path}")
          return fail!(:missing_access_token)
        end

        payload = verify(token)
        @claims = payload
        super
      rescue JWT::DecodeError, JSON::ParserError, SocketError, Timeout::Error => e
        Rails.logger.error("cloudflare_access: #{e.class}: #{e.message}")
        fail!(:invalid_access_token, e)
      end

      uid { @claims['email'].to_s.downcase }

      info do
        { email: @claims['email'], name: @claims['email'] }
      end

      extra do
        { raw_info: @claims }
      end

      private

      def verify(token)
        payload, = JWT.decode(
          token, nil, true,
          algorithms: ['RS256'],
          jwks: jwks,
          aud: options.audience, verify_aud: true,
          iss: "https://#{options.team_domain}", verify_iss: true
        )
        payload
      end

      def jwks
        @jwks ||= begin
          uri = URI("https://#{options.team_domain}/cdn-cgi/access/certs")
          body = Net::HTTP.get(uri)
          JSON.parse(body).symbolize_keys
        end
      end
    end
  end
end
