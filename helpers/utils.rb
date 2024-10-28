module Utils
  def valid_float?(value)
    true if Float(value) rescue false
  end
end
