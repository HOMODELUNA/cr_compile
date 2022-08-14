require "../token"
#词法分析器会匹配最长的一个输入,如果有两个输入一样长,就返回之前的输入
#我自己做的NFA和DFA目前没有被使用
class Lexer 
  class TokenSequence
    alias ID = Token::ID
    include Iterator(Token)
    @src : String
    @rules : Array(Tuple(Regex,Callback))
    def initialize(@src,@rules)
    end
    # macro match_keyword(enum_)
    #   %str = {{enum_}}.to_s    
    #   if @src.starts_with?(%str)
    #     #get_rest_strings({{enum_}},%str)
    #     if {{enum_}}.need_space? 
    #       case  @src[%str.size]? 
    #       when nil ,'\t','\n',' '
    #         @src = @src.[ %str.size .. -1 ]
    #         return Token.new( {{enum_}} )
    #       end
    #     else
    #       @src = @src.[ %str.size .. -1 ]
    #       return Token.new( {{enum_}} )
    #     end
    #   end
    # end

    # macro match_keywords(*enums)
    #   {%for _enum ,index in enums  %}
    #     match_keyword(  {{_enum}}  )
    #   {%end%}
    # end

    def next      
      until @src.empty?
        pos : Int32?=nil; level : Int32=0#,temp_cb_res: Token? = nil
        #puts "src= #{@src}"
        @rules.each_with_index do |_pr,index|
          pattern,rule = _pr 
          case m = pattern.match(@src)
          in Regex::MatchData
            #temp_cb_res = match{}
            if pos.nil? || m[0].size > pos.as(Int32) 
              pos = m[0].size
              level = index
            end
          in Nil
            #什么都不做
          end
        end
        unless pos.nil?         
          matched = @src[0...pos]
          #puts "matched = #{matched.inspect},size = #{matched.size}"
          @src = @src[pos .. -1]
          res = @rules[level][1].call(matched)
          if res.nil? #你在前面写了空东西就是要被吃掉的
            next
          else
            return res.as(Token)
          end
        end
        puts "unknown symbol : #{@src[0]}"
        @src = @src[1..-1]     
      end
      stop
    end
  end
end

class Lexer
  alias Callback = String -> Token?
  @rules : Array(Tuple(Regex,Callback))
  property :rules
  def initialize()
    @rules = [] of Tuple(Regex,Callback) 
  end
  def learn_rules(&block)
    with self yield
    return self
  end
  def on(pattern : Regex,&callback : String -> Token?)
    #puts "rule add #{Regex.new("^"+pattern.source).source}  =>  callback"
    @rules << {Regex.new("^"+pattern.source),callback}
  end
  def scan(string : String) : TokenSequence
    return TokenSequence.new(string,@rules)
  end

end