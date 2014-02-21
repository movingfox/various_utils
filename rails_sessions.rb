class RailsSession
  def self.get_session
    message = CGI.unescape(ARGV[0])
    puts ARGV[0]
    config = Rails.application.config

    key_generator = ActiveSupport::KeyGenerator.new(
      config.secret_key_base, iterations: 1000
    )
    secret = key_generator.generate_key(
      config.action_dispatch.encrypted_cookie_salt
    )
    sign_secret = key_generator.generate_key(
      config.action_dispatch.encrypted_signed_cookie_salt
    )
    encryptor = ActiveSupport::MessageEncryptor.new(
      secret, sign_secret
    )
    encryptor.decrypt_and_verify(message)
  end
end

puts RailsSession.get_session
