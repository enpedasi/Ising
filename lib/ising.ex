defmodule Ising do
  @moduledoc """
  Documentation for Ising.

  Iex > Ising.main()
  """
  defp get_state(agent_array, idx) do
    agent_array
    |> Map.get(idx)
    |> Agent.get(fn state -> state end)
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
    # IO.inspect iteration
    for iter <- 0..(iteration - 1 ) do
      for i <- 0..m , j <- 0..n do 
        agent_ary
           |> Map.get({i, j})
           |> Agent.get_and_update(
                fn s1 ->
                    {s1,
                      case :rand.uniform < 
                            Enum.at(prob, round(s1) * ising2d_sum_of_adjacent_spins(agent_ary, m, n, i , j) +4) do 
                        true -> - s1
                        _    ->   s1
                      end}
                end)
      end
    end
  end

  defp ok( {:ok, pid} = agent), do: pid

  def main do
    n = 100
    #  generate following map
    #
    #  %{ { {0, 0} , pid }, { {0, 1} , pid }, ...  }
    s = 0..n - 1
        |> Enum.flat_map( fn x -> 0..n - 1
        |> Enum.map( fn y -> { {x, y} ,
                                ok(Agent.start_link( fn -> if :rand.uniform < 0.5, do: -1, else: 1  end)) }
                      end ) end )
        |> Enum.into(%{})

    beta = :math.log(1 + :math.sqrt(2.0)) / 2
    :timer.tc(fn -> ising2d_sweep(s, beta, round(1.0e+08)) end)

    # stop the agents
    Enum.map(s, fn {_ , pid} -> Agent.stop(pid) end)
  end  
end

