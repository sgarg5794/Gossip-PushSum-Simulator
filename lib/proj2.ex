

defmodule Proj2.CLI do
  def main(args \\ []) do
    args
    |> parse_args
    |> handleInput
  end

  defp parse_args(args) do
    {_, args, _} =
      OptionParser.parse(args,strict: [:string])
      args
  end

  defp handleInput(args) do
    if(length(args)!==3 ) do
      IO.puts("Please provide correct arguments")
      System.halt(0)
    else
      numOfNodes=Enum.at(args,0)
      numOfNodes=String.to_integer(numOfNodes)
      topo=Enum.at(args,1)
      algo=Enum.at(args,2)
      begin(numOfNodes,algo,topo)
    end
  end

  def begin(numOfNodes,algorithm,topology) do
    pidList = cond do
      algorithm == "gossip"->
        cond do
          topology=="line" or topology=="full" or topology=="rand2D"->
            Enum.map(1..numOfNodes, fn i -> startNode(i) end)

          topology=="3Dtorus" ->
            numOfNodes=Proj2.Topology.nearestCubeNumber(numOfNodes)
            IO.inspect("Number of nodes changed to "<>Integer.to_string(numOfNodes))
            Enum.map(1..numOfNodes, fn i -> startNode(i) end)

          topology=="honeycomb" or topology=="randhoneycomb" ->
            finalNumNodes=Proj2.Topology.getNearestSquare(numOfNodes)
            n=Proj2.Topology.getNearestSquareRoot(finalNumNodes)
            n=trunc(n)
            n=cond do
              rem(n,2)==0->n
              true->n+1
            end
            finalNumNodes=:math.pow(n,2)
            numOfNodes=trunc(finalNumNodes)
            IO.inspect("Number of nodes changed to "<>Integer.to_string(numOfNodes))
            Enum.map(1..numOfNodes, fn i -> startNode(i) end)
          true ->
            IO.puts("Please provide appropriate topology")
            System.halt(0)
        end

      algorithm=="push-sum" ->
        cond do
          topology=="line" or topology=="full" or topology=="rand2D" ->
            Enum.map(1..numOfNodes, fn i -> startLinkPushSum(i) end)

            topology=="3Dtorus" ->
              numOfNodes=Proj2.Topology.nearestCubeNumber(numOfNodes)
              IO.inspect("Number of nodes changed to "<>Integer.to_string(numOfNodes))
              Enum.map(1..numOfNodes, fn i -> startLinkPushSum(i) end)

            topology=="honeycomb" or topology=="randhoneycomb" ->
              finalNumNodes=Proj2.Topology.getNearestSquare(numOfNodes)
              n=Proj2.Topology.getNearestSquareRoot(finalNumNodes)
              n=trunc(n)
              n=cond do
                rem(n,2)==0->n
                true->n+1
              end
              finalNumNodes=:math.pow(n,2)
              numOfNodes=trunc(finalNumNodes)
              IO.inspect("Number of nodes changed to "<>Integer.to_string(numOfNodes))
              Enum.map(1..numOfNodes, fn i -> startLinkPushSum(i) end)


          true ->
            IO.puts("Please provide appropriate topology")
            System.halt();
        end
      true ->
        IO.puts("Please provide appropriate algorithm")
        System.halt();

    end

    neighbourIndexList=Proj2.Topology.getNeighbours(numOfNodes,topology)
    neighbourPidList=Proj2.Topology.pIdMapping(pidList,neighbourIndexList)
    storeNeighbors(topology,numOfNodes,pidList,neighbourPidList)
    randomNodePID = selectRandomNode(pidList)
    startTime = System.system_time(:millisecond)

    if(algorithm=="gossip") do
      IO.puts("Gossip has begun")
      startGossip(randomNodePID)
    else
      IO.puts("PushSum has begun")
      startPushSum(randomNodePID)
    end

    ln=length(pidList)
      _fmk = Enum.map(pidList, fn i ->
       Process.monitor(i) end)
      if (algorithm == "gossip") do
        gossipConvergence(0,ln)
      else
        pushsumConvergence()
      end

    IO.puts("Convergence Time Calculated in milliseconds. Which is = ")

    IO.inspect(System.system_time(:millisecond) - startTime)

    if(algorithm=="gossip") do
      IO.puts("Gossip completed")
    else
      IO.puts("PushSum completed")
    end
  end


  def gossipConvergence(processesKilled,numOfNodes) do
    receive do
     {:DOWN, _ref, :process, _object, _reason} -> :ok
    end
    newProcessesKilled=processesKilled+1
    if (newProcessesKilled < numOfNodes ) do
      gossipConvergence(newProcessesKilled,numOfNodes)
    end
  end

  def pushsumConvergence() do
    receive do
      {:DOWN, _ref, :process, _object, _reason} ->
        :ok
     end
  end

  def startNode(actorNumber) do
#    set initial state of genserver by passing node number and initial count
    {:ok, pid} = GenServer.start_link(Proj2.Server1,[actorNumber,0])
    pid
  end

  def startLinkPushSum(actorNumber) do
    {:ok, pid} = GenServer.start_link(Proj2.PushSum,[actorNumber,1,0])
    pid
  end

  def storeNeighbors(topology,numNodes,pidList,neighbourPidList) do
    numOfNodes = cond do
      topology=="line" or topology=="full" or topology=="rand2D"  ->
        numNodes

      topology=="3Dtorus" ->
        Proj2.Topology.nearestCubeNumber(numNodes)

      topology=="honeycomb" or topology=="randhoneycomb" ->
        finalNumNodes=Proj2.Topology.getNearestSquare(numNodes)
        n=Proj2.Topology.getNearestSquareRoot(finalNumNodes)
        n=trunc(n)
        n=cond do
          rem(n,2)==0->n
          true->n+1
        end
        finalNumNodes=trunc(:math.pow(n,2))
        finalNumNodes
    end

    for i <- 1..numOfNodes do
      myPID=Enum.at(pidList,i-1)
      GenServer.cast(myPID,{:storeNeighbour,Enum.at(neighbourPidList,i-1)})
    end
  end

  def selectRandomNode(pidList) do
    randomPID=Enum.random(pidList)
    if(Process.alive?(randomPID)==true) do
      randomPID
    else
      pidList=pidList-[randomPID]
      selectRandomNode(pidList)
    end
  end


  def startGossip(randomNodePID) do
    GenServer.cast(randomNodePID,{:sendGossipMessage,"rumour"})
  end

  def startPushSum(randomNodePID) do
    GenServer.cast(randomNodePID,{:pushSum,[0,0]})
  end
end
