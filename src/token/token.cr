class Token
  enum ID
    Int_; String_;Float_;Identifier
    Plus
    Minus
    Multiply
    Divide
    Mod
    If
    Then
    Else
    End
    While
    Do
    Def
    Return
    Break
    Class
    LParen
    RParen
    def to_s
      case self
      in Plus then "+"
      in Minus then "-"
      in Multiply then "*"
      in Divide then "/"
      in Mod then "%"
      in LParen then "("
      in RParen then ")"
      in If then "if"
      in Then then "then"
      in Else then "else"
      in End then "end"
      in While then "while"
      in Do then "do"
      in Def then "def"
      in Return then "return"
      in Break then "break"
      in Class then "class"
      in Int_ then "integer"
      in String_ then "string"
      in Float_ then "float"
      in Identifier then "identifier"
      end
    end
    def to_regex
      case self
      in Plus then /\+/
      in Minus then /-/
      in Multiply then /\*/
      in Divide then /\//
      in Mod then /%/
      in LParen then %r(\()
      in RParen then %r(\))
      in If then /if/
      in Then then /then/
      in Else then /else/
      in End then /end/
      in While then /while/
      in Do then /do/
      in Def then /def/
      in Return then /return/
      in Break then /break/
      in Class then /class/
      in Int_ then /integer/
      in String_ then /string/
      in Float_ then /float/
      in Identifier then /identifier/
      end
    end
    #表示这个枚举是否需要后面有一个空格以和其他的分开
    #一般运算符不需要
    def need_space?
      case self
      when Plus,Minus,Multiply,Divide,Mod then false
      else 
        true
      end
    end
    def ===(right : Token)
      return right.id == self
    end
  end
end

class Token
  @id : ID
  @data : Int64 | String | Float64 | Nil
  property :id
 def initialize(@id , @data=nil)
 end
end