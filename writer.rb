module TreeTopWriter
  DEBUGMODE = false

  class HTMLRenderer
    def initialize
      @buffer = ""
      @ls_output = []
    end
    
    def tag tagobj, text = nil
      str_attr = ""
      tagobj.each do | key, val |
        next if key == :tag
        str_attr = %{#{str_attr} #{key}="#{val}"}
      end
      if text
        "<#{tagobj[:tag]}#{str_attr}>#{text}</#{tagobj[:tag]}>"
      else
        "<#{tagobj[:tag]}#{str_attr}/>"
      end
    end

    def flush_all
      flush_buffer
      return @ls_output.join
    end

    def flush_buffer
      if not @buffer.empty?
        @ls_output << tag({:tag => "p"}, @buffer) << "\n"
        @buffer = ""
      end
    end

    def add object
      type, content = object

      if DEBUGMODE
        puts " __________________________________ "
        puts "/__TYPE>___________ #{type} _______"
        puts content
        puts "\\__________________________________/"
      end
      
      case type
#      when :EOL
#      when :asterisk
#      when :nonasterisk
      when :headline
        flush_buffer
        match_star = content.match(/^\*+/)
        headline_level = match_star.to_s.length
        headline_text = match_star.post_match.lstrip
        if headline_level > 6
          @ls_output << tag({:tag => "span",
                              :class => "level-#{headline_level}-headline"},
                            headline_text)
        else
          @ls_output << tag({:tag => "h#{headline_level}"}, headline_text)
        end
        @ls_output << "\n"
#      when :line
      when :boldtext
        @buffer += tag({:tag => "b"}, content)
      when :codetext
        @buffer += tag({:tag => "code"}, content)
      when :underlinedtext
        @buffer += tag({:tag => "span",
                         :style => "text-decoration: underline"},
                       content)
      when :italicstext
        @buffer += tag({:tag => "i"}, content)
      when :verbatimtext
        @buffer += tag({:tag => "code"}, content)
#      when :plaintext
      when :horizontalrule
        flush_buffer
        @ls_output << tag({:tag => "hr"}) + "\n"
      when :hyperlink
        # strip the beginning and ending [[ ]]
        content = content[2...-2]
        spl = content.split("][")
        link_path = spl[0].gsub(/^file:/, "")
        link_desc = spl[-1]
        @buffer += tag({:tag => "a",
                         :href => link_path},
                       link_desc)
      when :paragraphbreak
        flush_buffer
      else
        @buffer += content
      end
    end
  end

  class Writer
    def initialize(ttobject)
      @treetop = ttobject
    end

    def to_html
      puts @treetop if DEBUGMODE

      renderer = HTMLRenderer.new

      @treetop.content.each { |entry|
        renderer.add(entry)
      }
      return renderer.flush_all
    end
  end
end



