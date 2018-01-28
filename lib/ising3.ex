defmodule Ising3 do
  @moduledoc """
  Documentation for Ising.
  map reduce version
  Iex > Ising.main()
  """
  defp get_state(spin_array, idx) do
     %{^idx => state} = spin_array
     state
  end

  def ising2d_sum_of_adjacent_spins(s, m, n, i, j) do
    i_bottom = if i + 1 < m ,do: i + 1, else: 0
    i_top    = if i - 1 >=0, do: i - 1, else: m - 1

    j_right  = if j + 1 < n, do: j + 1, else:  0
    j_left   = if j - 1 >= 0,do: j - 1, else: n - 1
    
    round( get_state(s, {i_bottom, j}) +
           get_state(s, {i_top, j})    +
           get_state(s, {i, j_right})  +
           get_state(s, {i, j_left}) )
  end

  def ising2d_sweep(agent_ary, beta, niter) do
    {{m, n}, _} = Enum.max_by(agent_ary, fn {{x, y}, _} -> x * y end )
    # IO.inspect [Integer.to_string(m), n]
    prob = [-2*beta*(-4), -2*beta*(-3), -2*beta*(-2), -2*beta*(-1),
                       1, -2*beta*  2 , -2*beta*  3 , -2*beta*4  ]
    iteration = round(niter/((m+1)*(n+1)))
    iteration = 1000
    # IO.inspect iteration
    Enum.reduce(0..iteration, agent_ary, fn _l, acc_map ->
      Enum.reduce(0..(m-1), acc_map,
        fn i, bcc_map -> 
          Enum.reduce(0..(n-1), bcc_map, 
            fn j, ccc_map -> 
               Map.update(ccc_map, {i, j}, 0, fn  s1 -> 
                       case :rand.uniform < 
                            Enum.at(prob, round(s1) * ising2d_sum_of_adjacent_spins(ccc_map, m, n, i , j) +4) do 
                        true -> - s1
                        _    ->   s1
                      end
               end) 
          end) 
       end)    
    end)
  end

  defp ok( {:ok, pid} = _agent), do: pid
  def main do
    n = 100
    #  generate following map
    #
    #  %{ { {0, 0} , pid }, { {0, 1} , pid }, ...  }
    s = 0..n - 1
        |> Enum.flat_map( fn x -> 0..n - 1
                             |> Enum.map( fn y -> {{x, y} , (if :rand.uniform < 0.5, do: -1, else: 1) } end )
           end )
        |> Enum.into(%{})

    beta    = :math.log(1 + :math.sqrt(2.0)) / 2
   
    {elapsed, result} = :timer.tc(fn -> ising2d_sweep(s, beta, round(1.0e+09)) end)
    
    # stop the agents
    {elapsed/1_000_000, result}
  end  
end

