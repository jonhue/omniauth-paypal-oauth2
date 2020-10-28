# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class PaypalOauth2 < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'openid email profile'
      DEFAULT_RESPONSE_TYPE = 'code'
      SANDBOX_SITE = 'https://api.sandbox.paypal.com'
      SANDBOX_AUTHORIZE_URL = 'https://www.sandbox.paypal.com/signin/authorize'

      option :name, 'paypal_oauth2'

      option :client_options,
             site: 'https://api.paypal.com',
             authorize_url: 'https://www.paypal.com/signin/authorize',
             token_url: '/v1/identity/openidconnect/tokenservice',
             setup: true

      option :authorize_options, [:scope, :response_type]
      option :provider_ignores_state, true
      option :sandbox, false

      # https://www.paypal.com/webapps/auth/identity/user/
      #   baCNqjGvIxzlbvDCSsfhN3IrQDtQtsVr79AwAjMxekw =>
      #   baCNqjGvIxzlbvDCSsfhN3IrQDtQtsVr79AwAjMxekw
      uid { @parsed_uid ||= ((%r{\/([^\/]+)\z}.match raw_info['user_id']) || [])[1] }

      info do
        prune!(
          'name' => raw_info['name'],
          'email' => ((raw_info['emails'] || []).detect do |email|
            email['primary']
          end || {})['value'],
          'location' => (raw_info['address'] || {})['locality']
        )
      end

      extra do
        prune!(
          'account_type' => raw_info['account_type'],
          'user_id' => raw_info['user_id'],
          'address' => raw_info['address'],
          'verified_account' => (raw_info['verified_account'] == 'true'),
          'language' => raw_info['language'],
          'zoneinfo' => raw_info['zoneinfo'],
          'locale' => raw_info['locale'],
          'account_creation_date' => raw_info['account_creation_date']
        )
      end

      def callback_url
        full_host + script_name + callback_path
      end

      def setup_phase
        if options.sandbox
          options.client_options[:site] = SANDBOX_SITE
          options.client_options[:authorize_url] = SANDBOX_AUTHORIZE_URL
        end
        super
      end

      def raw_info
        @raw_info ||= load_identity
      end

      def authorize_params
        super.tap do |params|
          params[:scope] ||= DEFAULT_SCOPE
          params[:response_type] ||= DEFAULT_RESPONSE_TYPE
        end
      end

      private

      def load_identity
        access_token.options[:mode] = :header
        access_token.options[:param_name] = :access_token
        access_token.options[:grant_type] = :authorization_code
        access_token.get(
          '/v1/identity/oauth2/userinfo', params: { schema: 'paypalv1.1' }
        ).parsed || {}
      end

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end
    end
  end
end
