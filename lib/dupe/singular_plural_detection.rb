module SingularPluralDetection #:nodoc:
  def singular?
    self.to_s.singularize == self.to_s
  end
  
  def plural?
    self.to_s.pluralize == self.to_s
  end
end