class String #:nodoc:
  include SingularPluralDetection
  
  def indent(spaces=2)
    split("\n").map {|l| (" " * spaces) + l }.join("\n")
  end
end