require "spec"
require "../src/lexer/fa/nfa.cr"

describe NFA do
  it "有空构造" do
    empty = NFA.new
  end
  
  it "可以由正则表达式构造" do
    nfa = NFA.new(/abcd/)
    puts "nfa from /abcd/ = #{nfa.inspect}"
  end
  it "可以制作或" do
    nfa = NFA.new(/a[bc]d/)
    puts "nfa from /a[bc]d/ = #{nfa.inspect}"
    nfa = NFA.new(/a|(bc)/)
    puts "nfa from /a|(bc)/ = #{nfa.inspect}"
  end
  it "可以制作闭包" do
    nfa = NFA.new(/a*/)
    puts "nfa from /a*/ = #{nfa.inspect}"
  end
  it "可以制作一个或多个" do
    nfa = NFA.new(/a+/)
    puts "nfa from /a+/ = #{nfa.inspect}"
  end
  it "可以制作一个或零个" do
    nfa = NFA.new(/a?/)
    puts "nfa from /a?/ = #{nfa.inspect}"
  end
  it "可以转换到dfa" do
    nfa = NFA.new(/(1|0)*1/)
    puts "nfa from /(1|0)*1/ = #{nfa.inspect}"
    dfa = nfa.to_dfa
    puts "corresponding dfa =#{dfa.inspect}"
  end
end