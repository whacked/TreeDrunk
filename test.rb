require "treetop"

Treetop.load "orgmode"

load "writer.rb"
parser = OrgModeParser.new

infile = ARGV.first and (File.exist? infile) or infile = "syntax.org"
text = File.read(infile)

parsed = parser.parse(text)

writer = TreeTopWriter::Writer.new(parsed)

if TreeTopWriter::DEBUGMODE
  puts "NOW OUTPUT: ============================================================"
end

puts writer.to_html

