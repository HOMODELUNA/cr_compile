require "spec"
require "../src/lexer"

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
alias ID = Token::ID 

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



describe Lexer do 
  it "可以由块构造" do 
    lexer_ = Lexer.new.learn_rules do
      on /[\n\t ]+/ do 
        nil
      end
      match_keywords(ID::Do,ID::Plus,ID::Minus,ID::Multiply,ID::Divide,ID::Mod,
        ID::If,ID::Else,ID::End,ID::While,
        ID::Def,ID::Return,ID::Break,ID::Class
      )
    end
    puts lexer_.rules.inspect
  end 

         

  describe "#scan" do
    it "识别关键词,去除空白符号" do 
      str = "+ - */% do         while end def return if else"
      tokens = lexer.scan(str)
      tokens.each do |tk|
        puts tk.inspect
      end
    end
    it "识别标识符" do 
      str = "a? +a?"
      tokens = lexer.scan(str)
      tokens.each do |tk|
        puts tk.inspect
      end
    end
    it "区分关键词和标识符" do 
      str = "while while?"
      tokens = lexer.scan(str)
      tokens.each do |tk|
        puts tk.inspect
      end
    end
    it "识别整数" do 
      str = "-114514 +1919 810"
      tokens = lexer.scan(str)
      tokens.each do |tk|
        puts tk.inspect
      end
    end
    it "区分符号和运算符" do 
      str = "-114514 +1919 - 810"
      tokens = lexer.scan(str)
      tokens.each do |tk|
        puts tk.inspect
      end
    end
    it "识别浮点数" do 
      str = "-114514.0e-3 +1919.810"
      tokens = lexer.scan(str)
      tokens.each do |tk|
        puts tk.inspect
      end
    end
  end
end