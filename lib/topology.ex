

defmodule Proj2.Topology do
    def getNeighbours(numNodes,topology) do
        neighbourList = cond do
            topology=="full" ->
               IO.inspect("Full network topology")
                for i <- 1..numNodes do
                    myList =
                    for j <- 1..numNodes  do
                        if (j !== i) do
                          j
                        end
                    end
                    Enum.reject(myList, &is_nil/1)
                end

            topology=="line" ->
                IO.inspect("Line Topology")
                for i <- 1..numNodes do
                    eachList = cond do
                        i===1 ->
                            [i+1]
                        i===numNodes ->
                            [i-1]
                        i>1 && i<numNodes ->
                            [i-1,i+1]
                    end
                end
          topology=="rand2D" ->
            IO.inspect("Random-2D-grid topology")
            positionList_for_everyNode = for i <- 1..numNodes do
              randGenerate()
            end

            for i <- 1..numNodes do
              myList = for j <- 1..numNodes  do
                if (j !== i) do
                  if (calculateDistanceBetweenNodes(i, j, positionList_for_everyNode) < 0.1) do
                    j
                  end
                end
              end
              Enum.reject(myList, &is_nil/1)
            end

            topology=="3Dtorus"->
                  IO.inspect("3D Torus")
                  finalNumNodes=nearestCubeNumber(numNodes)
                  n = cube_root(finalNumNodes)
                  n=trunc(n)
                  myList=Enum.map(1..finalNumNodes,fn i ->
                    a=cond do
                      rem(i,n)==1->
                        neighbour1 = i+1
                        neighbour2 = i+ (n-1)
                        Enum.uniq([neighbour1,neighbour2])
                      rem(i,n)==0->
                        neighbour1 = i-1
                        neighbour2 = i - (n-1)
                        Enum.uniq([neighbour1,neighbour2])
                      rem(i,n)!=0 && rem(i,n)!=1->
                        neighbour1 = i-1
                        neighbour2 = i+1
                        Enum.uniq([neighbour1,neighbour2])
                    end
                    b=cond do
                      div(rem(i-1,n*n),n) == 0->
                        neighbour3 = i+n
                        neighbour4 = i + n*(n-1)
                        Enum.uniq([neighbour3,neighbour4])
                      div(rem(i-1,n*n),n) == (n-1)->
                        neighbour3 = i-n
                        neighbour4 = i - n*(n-1)
                        Enum.uniq([neighbour3,neighbour4])
                      div(rem(i-1,n*n),n)>0 && div(rem(i-1,n*n),n)<(n-1) ->
                        neighbour3 = i-n
                        neighbour4 = i+n
                        Enum.uniq([neighbour3,neighbour4])
                    end

                   c= cond do
                     div(i-1,(n*n)) == 0->
                       neighbour5 = i + n*n
                       neighbour6 = i + n*n*(n-1)
                       Enum.uniq([neighbour5,neighbour6])
                     div(i-1,(n*n)) == (n-1)->
                       neighbour5 = i- n*n
                       neighbour6 = i - n*n*(n-1)
                       Enum.uniq([neighbour5,neighbour6])
                     div(i-1,(n*n))>0 && div(i-1,(n*n))<(n-1)->
                       neighbour5 = i-n*n
                       neighbour6 = i+n*n
                       Enum.uniq([neighbour5,neighbour6])
                   end
                    a++b++c
                  end)
                  topology=="honeycomb"->
                    finalNumNodes=getNearestSquare(numNodes)
                    n=getNearestSquareRoot(finalNumNodes)
                    n=trunc(n)
                    n=cond do
                      rem(n,2)==0->n
                      true->n+1
                      end
                    finalNumNodes=:math.pow(n,2)
                    finalNumNodes=trunc(finalNumNodes)
                    Enum.map(1..finalNumNodes,fn i->
                      myList=cond do
                        i<n and i>1 and rem(i,2)==0->
                          [i+1,i-1]
                       i<n and  i>1 and rem(i,2)!=0->
                          [i+1,i-1,i+n]
                        finalNumNodes-(n+1)<i and i<finalNumNodes and rem(i,2)==0 ->
                          [i+1,i-1]
                        finalNumNodes-(n+1)<i and i<finalNumNodes and rem(i,2)!=0 ->
                          [i+1,i-1,i-n]
                        rem(i,n)==1 and rem(div(i,n),2)==0 ->
                          [i+n,i+1]
                        rem(i,n)==1 and rem(div(i,n),2)!=0 ->
                          [i-n,i+1]
                        rem(i,n)==0 and rem(div(i,n),2)==0 and i != n and i != (n*n) ->
                          [i-1,i+n]
                        rem(i,n)==0 and rem(div(i,n),2) != 0 and i != n and i != (n*n) ->
                          [i-1,i-n]
                        i==n or i==(n*n)->
                          [i-1]
                        n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==1 and rem(i,2)==0->
                          [i+1,i-1,i+n]
                        n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==1 and rem(i,2)==1->
                          [i+1,i-1,i-n]
                        n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==0 and rem(i,2)==0->
                          [i+1,i-1,i-n]
                        n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==0 and rem(i,2)==1->
                          [i+1,i-1,i+n]
                      end
                      myList
                    end)
          topology=="randhoneycomb"->
            finalNumNodes=getNearestSquare(numNodes)
            n=getNearestSquareRoot(finalNumNodes)
            n=trunc(n)
            n=cond do
              rem(n,2)==0->n
              true->n+1
            end
            finalNumNodes=:math.pow(n,2)
            finalNumNodes=trunc(finalNumNodes)
            Enum.map(1..finalNumNodes,fn i->
              myList=cond do
                i<n and i>1 and rem(i,2)==0->
                  [i+1,i-1]
                i<n and  i>1 and rem(i,2)!=0->
                  [i+1,i-1,i+n]
                finalNumNodes-(n+1)<i and i<finalNumNodes and rem(i,2)==0 ->
                  [i+1,i-1]
                finalNumNodes-(n+1)<i and i<finalNumNodes and rem(i,2)!=0 ->
                  [i+1,i-1,i-n]
                rem(i,n)==1 and rem(div(i,n),2)==0 ->
                  [i+n,i+1]
                rem(i,n)==1 and rem(div(i,n),2)!=0 ->
                  [i-n,i+1]
                rem(i,n)==0 and rem(div(i,n),2)==0 and i != n and i != (n*n) ->
                  [i-1,i+n]
                rem(i,n)==0 and rem(div(i,n),2) != 0 and i != n and i != (n*n) ->
                  [i-1,i-n]
                i==n or i==(n*n)->
                  [i-1]
                n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==1 and rem(i,2)==0->
                  [i+1,i-1,i+n]
                n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==1 and rem(i,2)==1->
                  [i+1,i-1,i-n]
                n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==0 and rem(i,2)==0->
                  [i+1,i-1,i-n]
                n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==0 and rem(i,2)==1->
                  [i+1,i-1,i+n]
              end
              if(i<=div(finalNumNodes,2))do
                  myList++[i+div(finalNumNodes,2)]
              else
                  myList++[i-div(finalNumNodes,2)]
                end

            end)
        end
        neighbourList
    end


    def calculateDistanceBetweenNodes(index1, index2, corList) do
        x1=Enum.at(Enum.at(corList, index1-1), 0)
        x2=Enum.at(Enum.at(corList, index2-1), 0)
        y1=Enum.at(Enum.at(corList, index1-1), 1)
        y2=Enum.at(Enum.at(corList, index2-1), 1)
        dx=x1-x2
        dy=y1-y2
        :math.sqrt(:math.pow(dx,2)+:math.pow(dy,2))
    end

    def nearestCubeNumber(numNodes) do
      cr = Float.ceil(cube_root(numNodes))
      trunc(:math.pow(cr,3))
    end

    def cube_root(x, precision \\ 1.0e-12) do
      f = fn(prev) -> (2 * prev + x / :math.pow(prev, 2)) / 3 end
      fixed_point(f, x, precision, f.(x))
    end

    def getNearestSquareRoot(numNodes) do
      trunc(Float.ceil(:math.sqrt(numNodes)))
    end

    def getNearestSquare(numNodes) do
      trunc(:math.pow(Float.ceil(:math.sqrt(numNodes)),2))
    end

    def randGenerate( ) do
      x=Float.ceil(:rand.uniform(), 3)
      y=Float.ceil(:rand.uniform(), 3)
      myCoordinates = [x, y]
    end

    def fixed_point(_, guess, tolerance, next) when abs(guess - next) < tolerance, do: next

    def fixed_point(f, _, tolerance, next), do: fixed_point(f, next, tolerance, f.(next))

    def pIdMapping(pidList,neighbourIndexList) do
      resultList=[]
      l1=length(neighbourIndexList)
      resultList = for i <- 1..l1 do
        l2=length(Enum.at(neighbourIndexList,i-1))
        if(l2 !=0) do
          innerList = for j <- 1..l2 do
            listOfneighbors=Enum.at(neighbourIndexList,i-1)
            neighbourIndex=Enum.at(listOfneighbors,j-1)
            pID=Enum.at(pidList,neighbourIndex-1)
            pID
          end
          [innerList]
        else
          System.halt(0)
        end
      end
      resultList
    end

end
