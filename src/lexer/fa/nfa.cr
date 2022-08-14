require "./dfa"
class NFA
  alias State = Int32
  alias TransTable =  Hash(State ,Hash(Char, Set(State))) 
  Eps  = '\0'
  @initial : State
  @transform : TransTable  ={0=>{Eps=>Set{1}}}
  #我们默认final只有一个,如果有多个,就在后面加一个节点,把原先的用Eps连过来
  @final : State
  SingleEmpty = {0=>{Eps=>Set{1} }}
  property :initial , :transform , :final
  #默认构造一个接受空字符串的NFA
  def initialize(transform : TransTable? = nil,@final=1,@initial=0)
    if transform.nil?
      @transform = TransTable.new
      @transform[0]={Eps=>Set(State){1}} 
    else
      @transform = transform
    end
  end
  #现在只支持三种
  #1: 基础字符
  #2: 连接
  #3: 或
  #4: 圆括号
  #5: 方括号
  def self.parse_string(string : String)
    res : NFA
    arr=[] of NFA
    pos=0;limit = string.size
    while(pos < limit)
      case string[pos]
      when '('
        back = string.rindex(')')
        raise "圆括号不匹配 : #{string}" if back.nil?
        substr = string[pos+1 ... back]
        sub_nfa = NFA.parse_string(substr)
        arr << sub_nfa
        pos = back + 1
      when '['
        back = string.rindex(']')
        raise "方括号不匹配 : #{string}" if back.nil?
        substr = string[pos+1 ... back]
        sub_nfa = NFA.from_union(substr)
        arr << sub_nfa
        pos = back + 1
      when '*'
        arr[-1] = arr[-1].closure
        pos +=1
      when '+'
        arr << arr[-1].closure
        pos +=1
      when '?'
        arr[-1] = (arr[-1]  | NFA.new )
        pos +=1
      when '|'
        pos +=1
        case string[pos]
        when '('
          back = string.rindex(')')
          raise "圆括号不匹配 : #{string}" if back.nil?
          substr = string[pos+1 ... back]
          sub_nfa = NFA.parse_string(substr)
          arr << sub_nfa
          pos = back + 1
        when '['
          back = string.rindex(']')
          raise "方括号不匹配 : #{string}" if back.nil?
          substr = string[pos+1 ... back]
          sub_nfa = NFA.from_union(substr)
          arr << sub_nfa
          pos = back + 1
        else #只是一个普通字符
          arr << NFA.from_single_char( string[pos])
          pos +=1
        end
        arr[-2] = arr[-2] | arr[-1]
        arr.pop
      else #只是一个普通字符
        arr << NFA.from_single_char( string[pos])
        pos +=1
      end
    end
    return arr.reduce{|a,b|a+b}
  end
  #从一些字符的或构建NFA
  def self.from_union(string) : NFA
    string = string.gsub(/(.)-(.)/){|m| (m[1]...m[2]).to_a.join}
    NFA.new(  {0 => string.chars.to_h{ |c| {c,Set{1}} }}  ,1,0)
  end
  #构造接受单个字符的nfa
  def self.from_single_char(char : Char) : NFA
    NFA.new({0 => {char => Set{1} }},1,0)
  end
  def initialize(regex : Regex)
    nfa =NFA.parse_string(regex.source)
    @transform = nfa.transform
    @initial = nfa.initial
    @final = nfa.final
  end
  #NFA的空转换
  def e_closure(state : State,enumerated = Set(State).new) : Set(State)
    res = Set(State){state}
    return res unless @transform.has_key?(state)
    
    @transform[state].select{ |char,_| char == Eps}.each do |char,next_states|
      if ! enumerated.includes?(next_states)
        res |= next_states.map{|s|self.e_closure(s,enumerated)}.reduce{|a,b| a|b }
      end
    end 
    return res
  end
  #返回自己所有的状态数
  def states
    res = Set(State).new
    @transform.each do |state_from , hash_c_ss|
      res << state_from
      res |= res + hash_c_ss.values.reduce {|a,b| a| b}
    end
    return res
  end
  #0仍然是开始,1表示结束,offset表示你需要用到的节点的截止数,因为a的节点在这里开始,b的节点接着A
  #返回nfa的状态到后来状态的映射
  def state_shift(offset)
    s=self.states 
    num = s.size
    return Hash.zip(s.to_a,(offset ... offset+num).to_a)
  end
  #合并两个NFA
  def |(b : NFA)
    puts "#{self.inspect} | #{b.inspect}"
    a_shift = self.state_shift(2)
    puts "a_shifter = #{a_shift}"
    b_shift = b.state_shift( a_shift.values.max() +1)
    ats = NFA.trans_shift(@transform,a_shift)
    bts = NFA.trans_shift(b.transform,b_shift)
    glue={
      0=>{Eps =>Set{a_shift[@initial],b_shift[b.initial]}}, 
      a_shift[@final]=>{Eps=>Set{1}},
      b_shift[b.final]=>{Eps=>Set{1}}
    }
    return NFA.new(glue.merge(ats).merge(bts), 1,0)
  end
  def self.trans_shift(trans,shifter)
    trans.map{|state,c_ss|{shifter[state],c_ss.map{|c,ss|{c,ss.map{|s| shifter[s]}.to_set }}.to_h}}.to_h
  end
  #连接两个NFA
  def +(right : NFA)
    res = self.dup
    shifter = right.state_shift(self.states.max+1)
    new_right_trans = NFA.trans_shift(right.transform , shifter)
    res.transform.merge!(new_right_trans)
    res.transform.merge!({ @final=> {Eps=> Set{shifter[right.initial]}}})
    res.final = shifter[right.final]
    return res
  end
  #把一个NFA转化成NFA的闭包
  def closure : NFA
    shifter = self.state_shift(2)
    new_trans = NFA.trans_shift(@transform,shifter)
    glue = {
      0 => {Eps => Set{1,shifter[@initial]}},
      shifter[@final] => {Eps => Set{0,1}}
    }
    new_trans.merge!(glue)
    return NFA.new(new_trans,1,0)
  end
  def to_dfa() : DFA
    adder = ->(h : Hash(Set(State), DFA::State),k : Set(State)){ h[k]=h.size}
    ndmap = Hash(Set(State), DFA::State).new( adder)
    create_empty = ->(h : DFA::TransTable,k: DFA::State){ h[k] = {} of Char => DFA::State }
    dfa_trans = DFA::TransTable.new(create_empty)
    nfa_initial = self.e_closure(@initial)
    #puts "nfa_initial = #{nfa_initial}"
    dfa_initial = ndmap[nfa_initial]
    #puts "initial #{nfa_initial} --> #{dfa_initial}"
    dfa_final = Set(State).new()
    traversed = Set(Set(State)).new()

    spread = -> (nfa_states : Set(State)){
      create_empty_set = ->(h : Hash(Char,Set(State)),k : Char){ h[k] = Set(State).new() }
      char_target = Hash(Char,Set(State)).new(create_empty_set)

      nfa_states.each do |state|
        next unless @transform.has_key?(state)
        @transform[state].each do |char,states_following|
          next if char == Eps
          #puts "  on rule #{state} => #{char} => #{states_following}"
          states_target = states_following.map{|state|self.e_closure(state)}.reduce{|a,b| a|b }
          char_target[char] |=states_target
        end
      end
      char_target.each do |char,targets|
        dfa_trans[ndmap[nfa_states]].merge!( {char => ndmap[targets]})
        if targets.includes?(@final)
          dfa_final << ndmap[targets]
        end
      end
      traversed << nfa_states
    }
    state_to_spread  = ndmap.find(){|nfa_states,dfa_state| ! traversed.includes?(nfa_states)}
    until state_to_spread.nil?
      spread.call(state_to_spread[0])
      state_to_spread = ndmap.find{|nfa_states,dfa_state| ! traversed.includes?(nfa_states)}
    end
    return DFA.new(dfa_trans,dfa_final,dfa_initial)
  end
end

  