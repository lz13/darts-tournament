module AdminTokenVerifiable
  extend ActiveSupport::Concern

  private

  def valid_admin_token?(provided_token)
    expected_token = @tournament.admin_token
    return false unless expected_token.is_a?(String) && provided_token.is_a?(String)
    return false unless expected_token.bytesize == provided_token.bytesize

    ActiveSupport::SecurityUtils.secure_compare(expected_token, provided_token)
  end
end
