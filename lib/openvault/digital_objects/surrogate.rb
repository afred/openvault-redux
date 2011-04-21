module Openvault::DigitalObjects
  module Surrogate
  def surrogate
    @surrogate ||= ::Surrogate.with_id pid
  end

  def save
    surrogate.save!
    @surrogate = ::Surrogate.with_id pid
    nil
  end
  end
end
