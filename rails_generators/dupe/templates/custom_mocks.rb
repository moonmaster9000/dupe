# Example:
# Get %r{/books/([\d\w-]+)\.xml} do |label|
#   Dupe.find(:book) {|b| b.label == label}
# end