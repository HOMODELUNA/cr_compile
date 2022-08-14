class DFA
  alias State = Int32
  alias TransTable = Hash(State ,Hash(Char,State))
  @initial : State
  @transform : TransTable
  @final : Set(State)
  def initialize(@transform,@final,@initial)
  end
end