module ModelUtils
  extend ActiveSupport::Concern

  def error_messages
    errors.full_messages.join(", ")
  end
end
