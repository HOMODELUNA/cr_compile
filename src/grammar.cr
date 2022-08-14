require "./ast"
require "./token"
class Grammar
  alias ID = Token::ID
  alias Pattern = Array(Token::ID | Symbol)
  alias Callback = Array(Token | AST) -> AST
  alias Rule = Tuple(Pattern,Callback)
  alias RuleArr = Array(Rule)
  #语法里面一个非终结符可以表示成一组展开式,其中包含终结符(Token)和非终结符
  @production : Hash(Symbol , RuleArr)
  # 空串
  Eps = [] of Token | Symbol
  property :production
  def initialize(@production = {} of Symbol => RuleArr)
  @being_ruled = :DONT_USE_THIS
  end
  def config(&block)
    with self yield
    return self
  end
  private def rule_for(non_terminal : Symbol , &block)
    @being_ruled = non_terminal
    with self yield
  end
  #不要手动调用这个函数,它应该在rule_for这个函数里面调用
  private def on( pattern : Pattern ,&callback : Callback)
    @production[@being_ruled] ||=RuleArr.new
    @production[@being_ruled] <<{pattern.map &.as(Token::ID | Symbol) ,callback}
  end
  #递归下降的语法分析
  #要求与法理没有左递归
  def recursive_descent(token_stream : Enumerable(Token),symbol = :S) : {AST?,Enumerable(Token)}
    @production[symbol].each do |rule|
      STDERR.puts "rule is ",rule.inspect
      ast,rest = rd_do_one_rule(token_stream,rule,symbol)
      if ast
        return {ast,rest}
      end
    end
    return {nil,token_stream}
  end

  private def rd_do_one_rule(token_stream : Enumerable(Token),rule : Rule , symbol = :S) : {AST?,Enumerable(Token)}
    pattern,callback= rule
    STDERR.puts "one rule:: rule is",pattern.inspect
    STDERR.puts "callback is",callback.inspect
    STDERR.puts "tokens is ",token_stream.inspect
    arr,rest_tokens = pattern.reduce({[]of Token| AST,token_stream}) do |arr_prev,entry|
      prev_arr,previous_stream = arr_prev
      STDERR.puts "stream is #{previous_stream}"
      case entry
      when ID
        if previous_stream.size >1 && entry === previous_stream.first
          {prev_arr.push(previous_stream.first),previous_stream.skip(1)}
        else
          return {nil,token_stream}
        end
      when Symbol
        ast,rest = recursive_descent(previous_stream,entry)
        if ast
          {prev_arr.push(ast),rest}
        else
          return {nil,token_stream}
        end
      else
        raise "你的语法规则里写了什么啊"
      end
    end
    ast = callback(arr)
    return {ast,rest_tokens}
  end
end


# :expr => [
#   [ID::IF,:expr ,ID::Then,:expr ID::Else :expr],
#   [ID::While, :expr ,ID::Do,:expr,ID::End]
# ]

# g = Grammar.new.config do 
#   rule_for :S  do 
#     on [ID::Int_,:A] do |tk_i,ast_a|
#       AST.new(tk_i,ast_a)
#     end
#   end
#   rule_for :A do 
#     on [ID::Float_] do |tk_f|
#       AST.new(tk_f)
#     end
#     on [ID::Identifier,:A] do |ident,a|
#       AST.new(ident,a)
#     end
#   end
# end