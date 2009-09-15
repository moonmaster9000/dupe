class String
  def plural?
    self.to_s == pluralize
  end

  def singular?
    self.to_s == singularize
  end
end
