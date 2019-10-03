
defmodule Proj2.PushSum do
  use GenServer

  def init(state) do
    {:ok,state}
  end

  def handle_cast({:storeNeighbour, neighbourList}, state) do
    {:noreply, state ++ [neighbourList]}
  end

  def handle_cast({:pushSum, swPair},state) do
    flag=Enum.at(state,2)
    threshold=:math.pow(10,-10)
    if(flag<3) do
      oS=Enum.at(state,0)
      oW=Enum.at(state,1)
      oRatio=oS/oW
      nS=Enum.at(state,0)+Enum.at(swPair,0)
      nW=Enum.at(state,1)+Enum.at(swPair,1)
      nRatio=nS/nW
      difference=abs(nRatio-oRatio)
      newflag = if(difference>threshold) do
        0
      else
        flag+1
      end

      newState=[nS/2,nW/2,newflag,Enum.at(state,3)]
      sendMsgPair(Enum.at(newState,3),nS/2,nW/2)
      {:noreply,newState}

    else
      Process.exit(self(),:normal)
      {:noreply,state}
    end
  end


  def sendMsgPair(neighbourList,s,w) do
    neighbourList = List.flatten(neighbourList)
    aliveNeighbourers=if(length(neighbourList)!==0)do
      aliveNeighbourers=Enum.map(neighbourList,fn neighbour->
        aliveNeighbour=if(Process.alive?(neighbour)==true)do
          neighbour
        end
        aliveNeighbour
      end)
      aliveNeighbourers
    end

    aliveNeighbourers=Enum.reject(aliveNeighbourers, &is_nil/1)

    if(length(aliveNeighbourers)!==0)do
      randomAliveNeighbour=Enum.random(aliveNeighbourers)
      swPair=[s,w]
      GenServer.cast(randomAliveNeighbour,{:pushSum,swPair})
    end

    aliveNeighbourers
  end

end
