module MtGox
  # Custom error class for rescuing from all MtGox errors
  class Error < StandardError; end

  class MysqlError < Error; end
end

