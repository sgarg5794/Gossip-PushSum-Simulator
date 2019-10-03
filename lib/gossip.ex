

defmodule Proj2.Server1 do
    use GenServer

    def init(initialState) do
        {:ok,initialState}
    end

    def handle_cast({:storeNeighbour, neighbourList}, initialState) do
        {:noreply, initialState ++ neighbourList}
    end

    def handle_cast({:sendGossipMessage,_rumor},initialState) do
        rumorCount=Enum.at(initialState,1)
        rumorCount=rumorCount+1
        if(rumorCount>9) do
            Process.exit(self(),:normal)
        else
            GenServer.cast(self(),{:sendGossipToNeighbourers,_rumor})
        end
        myList = [Enum.at(initialState,0),rumorCount,Enum.at(initialState,2)]
        {:noreply,myList}
    end

    def handle_cast({:sendGossipToNeighbourers,_rumor},initalState) do
        neighbourers=Enum.at(initalState,2)
        neighbourList=if(length(neighbourers)!==0)do
          neighbourList = sendGossipRandomlyToNeighbour(Enum.at(initalState,2),_rumor)
          neighbourList
        end
        if(length(neighbourList)!==0) do
            Process.sleep(10)
            GenServer.cast(self(),{:sendGossipToNeighbourers,_rumor})
        else
            Process.sleep(10)
            Process.exit(self(),:normal)
        end
        {:noreply,initalState}
    end

    def sendGossipRandomlyToNeighbour(neighbourList,rumor) do
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
        GenServer.cast(randomAliveNeighbour,{:sendGossipMessage,rumor})
      end
      aliveNeighbourers
    end

end
