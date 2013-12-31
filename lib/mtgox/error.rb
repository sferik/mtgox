module MtGox
  # Custom error class for rescuing from all MtGox errors
  class Error < StandardError; end
  class MysqlError < Error; end
  class UnauthorizedError < Error; end
  class FilthyRichError < Error; end
  class OrderNotFoundError < Error; end
end
