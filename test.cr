class A

  private def in_block
    puts "执行了私有函数"
  end
  
  def use (&block)
    with self yield
  end
end


A.new.use do
  in_block
end

