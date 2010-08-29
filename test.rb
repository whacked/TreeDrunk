require "treetop"

Treetop.load "orgmode"

load "writer.rb"
parser = OrgModeParser.new

text = File.read("syntax.org")

parsed = parser.parse(text)

writer = TreeTopWriter::Writer.new(parsed)

if TreeTopWriter::DEBUGMODE
  puts "NOW OUTPUT: ============================================================"
end

puts writer.to_html

