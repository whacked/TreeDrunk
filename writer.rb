module TreeTopWriter
  DEBUGMODE = !true

  class HTMLRenderer
    def initialize
      @buffer = ""
      @ls_output = []
      @current_mode = nil
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

    def mode_of type
      # tell what "mode" we are in given the type of tag
      case type
      when :headline, :listunordered, :listordered,
           :specialblocksource, :specialblockquote, :specialblockcatchall
        type
      else
        :normal
      end
    end

    def flush_all
      flush_buffer
      return @ls_output.join
    end

    def flush_buffer
      DEBUGMODE and puts "FLUSHING BUFFER " + ">" * 80

      if not @buffer.empty?
        case @current_mode
        when :listunordered
          @ls_output << tag({:tag => "ul"}, @buffer) << "\n"
        when :listordered
          @ls_output << tag({:tag => "ol"}, @buffer) << "\n"
        when :specialblocksource
          @ls_output << tag({:tag => "code"}, @buffer) << "\n"
        when :specialblockquote
          @ls_output << tag({:tag => "blockquote"}, @buffer) << "\n"
        when :specialblockcatchall
          @ls_output << tag({:tag => "div"}, @buffer) << "\n"
        else
          @ls_output << tag({:tag => "p"}, @buffer) << "\n"
        end
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
      
      if mode_of(type) != @current_mode
        puts "FLUSHING SINCE CHANGE MODE from #{@current_mode} ----> #{mode_of type}" + "+"*80 if DEBUGMODE
        flush_buffer
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
      when :comment
        # output the actual comment?
        # @buffer += "<!-- #{content} -->\n"
      when :listunordered
        @buffer += tag({:tag => "li"}, content.lstrip.split(/\s/, 2)[-1])
      when :listordered
        @buffer += tag({:tag => "li"}, content.lstrip.split(/\s/, 2)[-1])
      when :specialblocksource, :specialblockquote, :specialblockcatchall
        flush_buffer
        content.split(/\r?\n/).each do |line|
          if not line.start_with? "#" then
            @buffer += line + "\n"
          end
        end
      when :paragraphbreak
        flush_buffer
      else
        @buffer += content
      end
      @current_mode = mode_of type
      
      DEBUGMODE and puts ("<" * 100) + "CURRENT MODE: #{@current_mode}"
    end
  end

  class Writer
    def initialize(ttobject)
      @treetop = ttobject
    end

    def to_html
      DEBUGMODE and puts @treetop

      renderer = HTMLRenderer.new

      @treetop.content.each { |entry|
        renderer.add(entry)
      }
      return renderer.flush_all
    end
  end
end



