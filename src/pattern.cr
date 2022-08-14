# class Pattern(Token)
#   #alias Rule =  Array(Array(Token|Pattern(Token)))
#   getter rules : Rule
#   def initialize(@rules = [] of Rule)
#   end
#   def =(other : Pattern(Token))
#     @rules = other.rules
#   end

#   def + (other : Pattern)
#     ConsPattern.new(self , other)
#   end
#   def | (other : Pattern)
#     VariantPattern.new(self , other)
#   end
#   macro fail(src)
#     return {  {{src}} ,nil}
#   end
#   # 递归向下匹配字符串
#   def recurse_down(src : Enumerable(Token)) : {Enumerable(Token) , AST::Node?}
#     #@rules.each do | rule |     
#   end
  
# end


# class ConsPattern(Token) < Pattern(Token)
#   getter car : Pattern , cdr : Pattern
#   def initialize(@car,@cdr)
#   end

#   # 递归向下匹配字符串
#   def recurse_down(src : Enumerable(Token)) : {Enumerable(Token) , AST::Node?}
#     src1,node1 = @car.recurse_down(src)
#     fail(src) unless node1
#     src2,node2 = @cdr.recurse_down(src1)
#     fail(src) unless node2
#     return {src2,AST::Node{node1,node2}}
#   end
# end

# class SequencialPattern(Token) < Pattern(Token)
#   getter arr : Array(Pattern)
#   def initialize(@arr)
#   end
#   # 递归向下匹配字符串
#   def recurse_down(src : Enumerable(Token)) : {Enumerable(Token) , AST::Node?}
#     rest,nodes = arr.reduce({src,[] of AST::Node}) do |old,pattern|
#       src0,already = old
#       src1,node = pattern.recurse_down(src0)
#       fail(src) unless node
#       already << node
#       {src1,already}
#     end
#     return {rest,AST::Node(nodes)}
#   end
# end


# class VariantPattern(Token) < Pattern(Token)
#   getter primary : Pattern , secondary : Pattern
  
#   def initialize(@primary,@secondary)
#   end

#   # 递归向下匹配字符串
#   def recurse_down(src : Enumerable(Token)) : {Enumerable(Token) , AST::Node?}
#     src1,node = @primary.recurse_down(src)
#     return {src1,node} if node
#     src1,node = @secondary.recurse_down(src)
#     return {src1,node} if node
#     fail(src)
#   end
# end
