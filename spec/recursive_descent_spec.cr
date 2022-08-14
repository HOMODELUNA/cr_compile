require "spec"
require "../src/grammar"
require "../src/lexer"
require "../src/token"
macro match_keyword(enum_)
  on {{enum_}}.to_regex  do
    Token.new({{enum_}}) 
  end
end
macro match_keywords(*enums)
  {%for _enum ,index in enums  %}
    match_keyword(  {{_enum}}  )
  {%end%}
end
alias ID=Token::ID

lexer = Lexer.new.learn_rules do
  on /[\n\t ]+/ do 
    nil
  end
  match_keywords(ID::Do,ID::Plus,ID::Minus,ID::Multiply,ID::Divide,ID::Mod,
    ID::If,ID::Else,ID::End,ID::While,
    ID::Def,ID::Return,ID::Break,ID::Class
  )
  #整数
  on /[+-]?[0-9]+/ do |s|
    num = s.to_i64
    Token.new(ID::Int_,num)
  end
  #标识符
  on %r([_a-zA-Z][_0-9a-zA-Z]*[\?!]?) do |name|
    Token.new(ID::Identifier,name)
  end
  #浮点数
  on %r<[+-]?[0-9]+\.[0-9]+([Ee][+-]?[0-9]+)?> do |s|
    Token.new(ID::Float_,s.to_f64)
  end
end
# E = :E1 | E1 '+' E
# E1 = Int_ | (E) | 
g = Grammar.new.config do 
  rule_for(:S) do
    on [ID::If,:A,ID::End] do |asts|
      ASTLeaf(Symbol).new(:Nothing)
    end
  end
  rule_for(:A) do 
    on [ID::Then,ID::Else] do |asts|
      ASTLeaf(Symbol).new(:Nothing)
    end
    on [ID::Then] do
      ASTLeaf(Symbol).new(:Nothing)
    end
  end
end
puts "Grammar is ",g.inspect

describe Grammar do 

  it "可以识别正确的结果" do
    ast ,rest = g.recursive_descent([ID::If,ID::Then,ID::End].map{|id|Token.new(id)},:S)
    puts "if then end",ast.inspect
  end

  
end