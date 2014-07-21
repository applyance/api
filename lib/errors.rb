class ApplyanceError < StandardError
  attr_reader :object
  def initialize(object)
    @object = object
  end
end

class InternalServerError < ApplyanceError
end

class BadRequestError < ApplyanceError
end

class ForbiddenError < ApplyanceError
end
