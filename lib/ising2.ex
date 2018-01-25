defmodule IsingOld do
  @moduledoc """
  Documentation for Ising.
  """

  def ising2d_sum_of_adjacent_spins(agent_s, m, n, i, j) do
    i_bottom = if i + 1 < m ,do: i + 1, else: 0
    i_top    = if i - 1 > 0, do: i - 1, else: m - 1

    j_right  = if j + 1 < n, do: j + 1, else:  0
    j_left   = if j - 1 >= 0,do: j - 1, else: n - 1
    s = Agent.get(:ising_s, fn s -> s.array end)
    round( Numexy.get(s, {i_bottom+1, j+1}) +
           Numexy.get(s, {i_top+1, j+1})  +
           Numexy.get(s, {i+1, j_right+1}) + Numexy.get(s, {i+1, j_left+1}) )
  end
  
  
  def ising2d_sweep(agent_s, beta, niter) do
    {m, n} = Agent.get(:ising_s, fn s -> s.shape end)
    prob = [-2*beta*(-4), -2*beta*(-3), -2*beta*(-2), -2*beta*(-1),
                       1, -2*beta*  2 , -2*beta*  3 , -2*beta*4  ]
    iteration = round(niter/(m*n))
    IO.inspect iteration
    #for iter <- 0..(iteration - 1 ) do
      for i <- 0..(m - 1) , j <- 0..(n - 1) do 
      #   s1 = Agent.get(:ising_s, &Numexy.get(&1, {i+1,j+1}))
          s1 = Agent.get(:ising_s, &Numexy.get(&1, {i+1,j+1}))      
          k = round(s1) * ising2d_sum_of_adjacent_spins(agent_s, m, n, i , j)
      #    put_in( s.array[i][j], case :rand.uniform < Enum.at(prob, k + 4) do true-> -s1 _ -> s1 end) 
          Agent.update( :ising_s, 
            fn n -> ##  arrayにput_inが使えないので行き詰まり。
                 ary = n.array
                 Numexy.new( put_in( ary[i][j], case :rand.uniform < Enum.at(prob, k + 4) do
                                                     true-> -s1
                                                     _ -> s1 
                                               end) )
          end)
      end
     
    Agent.get( :ising_s, fn s -> s end)
  end
  
  def main do
    n = 100
    s = Numexy.new( 1..n
                    |> Enum.map( fn x -> 1..n
                                         |>  Enum.map( fn x -> if :rand.uniform < 0.5, do: -1, else: 1  end)
                        end ) )
    beta = :math.log(1 + :math.sqrt(2.0)) / 2

    agent_s = Agent.start_link(fn -> s end, name: :ising_s)
    :timer.tc(fn -> ising2d_sweep(agent_s, beta, round(1.0e+08)) end)
    Agent.stop :ising_s
  end
end