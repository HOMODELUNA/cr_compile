class AST
end
class ASTNode < AST
  @id : Symbol
  @subs : Array(AST)
  def initialize(@subs = [] of AST, @id = :Default)
  end
end
class ASTLeaf(T) < AST
  @id : Symbol
  @data : T
  def initialize(@data = T.new , @id = :Default)
  end
end
