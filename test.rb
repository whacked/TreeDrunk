system("tt orgmode.treetop")

require "treetop"

load "orgmode.rb"
load "writer.rb"


parser = OrgModeParser.new

text = <<HEREDOC
This file to demonstrate org markup

* heading
***** subsubsubsubheading

*bold* inline *bold* with text *bold*
inline _underline_ with text
inline /italic!/ with text
inline =code=  with text
inline ~verbatim~ with text

HR should appear below:
--------
HR should appear above:


---

hello

[[file:ruby.org][ruby]]


interspersed [[file:ruby.org][ruby]] link


HEREDOC

parsed = parser.parse(text)

writer = TreeTopWriter::Writer.new(parsed)

if TreeTopWriter::DEBUGMODE
  puts "NOW OUTPUT: ============================================================"
end

puts writer.to_html

