



void insertPQ(uint2 node);
uint3 removePQ();
uint getGridIntegerCoordinate(uint x, uint y);
void addToOpenList(uint2 thisNode, uint2 pqCurrentNode, uint2 targetNode, uint G_COST);
void InsertIntoGridNodeList(uint x, uint y,  uint parentId, uint status  );

struct BufType
{
	uint f;
};

struct SubType
{
	uint f1;	
};

struct ParentType
{
	SubType sub[40];
};

struct Node
{
	uint2 coords;
	uint cost;
	uint id;
};

struct Agent
{
	uint id;
	uint2 sourceLoc;
	uint2 targetLoc;
};

struct SearchResult
{
	uint agentId;
	uint finalCost;
	uint2 targetLoc;
};

SamplerState samLinear
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};

// Input List with Agents data from CPU
StructuredBuffer<Agent> gAgentListInput : register(t0);

// World map 2D Texture from CPU
Texture2D<uint4> m_map : register(t2);

// Temp OpenList for A* executed by each Agent 
// x = ID of the Node
// y = Cost of the node
// z = G cost
RWStructuredBuffer<uint3> gOpenListOut ;

// Temp Grid List to maintain the status and target pointers
// x, y = 2D location on grid
// z = ID of the pointer node
// w = Status of Node Unread = 0; Open = 1; Closed = 2;
RWStructuredBuffer<uint4> gGridNodeListOut ;

// Final Result of A* for each Agent
RWStructuredBuffer<SearchResult> gBufferOut : register(u0);
//RWStructuredBuffer<ParentType> BufferOutClone : register(u1);
//

void insertPQ(uint3 node){

	uint currentSize = gOpenListOut[0].y;
	uint i = currentSize+1;

	[allow_uav_condition]
	while( i > 1 && gOpenListOut[i/2].y > node.y )
	{
		gOpenListOut[i] = gOpenListOut[i/2];
		i = i/2;
	}

	gOpenListOut[i] = node;
	gOpenListOut[0].y = gOpenListOut[0].y + 1;
	//gOpenListOut[i] = node;

}
const int _GRID_RESOLUTION_X_AXIS = 8;
[numthreads(1, 1, 1)]
void main( uint3 DTid : SV_DispatchThreadID )
{
	
	
	const int _NONE_UNREAD = 0;
	const int _NODE_OPEN = 1;
	const int _NODE_CLOSED = 2;
	const int _WALKABLE_NODE  = 0;
	const int _COLLISION_NODE = 1;
	Agent agent = gAgentListInput[0];

	// Get Source node to start the search with
	uint2 nodeFirstLoc;
	nodeFirstLoc = agent.sourceLoc;

	// Get Target node to check in the while loop if path found
	uint2 targetNode;
	targetNode = agent.targetLoc;
	uint targetNodeGridId = getGridIntegerCoordinate(targetNode.x, targetNode.y);

	uint3 pqFirsNode;
	pqFirsNode.x = getGridIntegerCoordinate(nodeFirstLoc.x,nodeFirstLoc.y);
	pqFirsNode.y = 10;
	pqFirsNode.z = 0;
	// Insert the first node into OpenList;
	insertPQ(pqFirsNode);


	// Insert into GridNodeList
	InsertIntoGridNodeList(nodeFirstLoc.x, nodeFirstLoc.y, 0, _NODE_OPEN);

	bool targetFound = false;

	uint3 pqCurrentNode;
	uint4 currentGridNode;
	uint4 currentNode;
	// Loop until path to target node found or no path found
	while(!targetFound)
	{

		pqCurrentNode = removePQ();

		//setStatusCloseGridNode(pqCurrentNode.x);
		gGridNodeListOut[pqCurrentNode.x].w = _NODE_CLOSED;	

		currentNode = gGridNodeListOut[pqCurrentNode.x];	

		// terminate if no path found or pathfound
		if(pqCurrentNode.y == 0 || pqCurrentNode.x == targetNodeGridId)
		{
			break;
		}
		else{
			//currentGridNode = gGridNodeListOut[pqTopNode.x];		

			if(_GRID_RESOLUTION_X_AXIS > currentNode.x+1) // To the immidiate right
			{
				
				uint2 thisNode = uint2(currentNode.x+1,currentNode.y);

				addToOpenList(thisNode,  pqCurrentNode,  targetNode, 10);

			}

			if(_GRID_RESOLUTION_X_AXIS > (currentNode.x+1) && 0 <= (currentNode.y-1)) // To the Right-Down
			{
				uint2 thisNode = uint2(currentNode.x+1,currentNode.y-1);

				 addToOpenList(thisNode,  pqCurrentNode,  targetNode, 14);
			}

			if(0 <= (currentNode.y-1)) // To Below/Down
			{
				uint2 thisNode = uint2(currentNode.x,currentNode.y-1);

				 addToOpenList(thisNode,  pqCurrentNode,  targetNode, 10);
			}

			if(0 <= (currentNode.x-1) && 0 <= (currentNode.y-1) ) //To Left-Down
			{
				uint2 thisNode = uint2(currentNode.x-1,currentNode.y-1);

				 addToOpenList(thisNode,  pqCurrentNode,  targetNode, 14);
			}

			if(0 <= (currentNode.x-1)) //To Left
			{
				uint2 thisNode = uint2(currentNode.x-1,currentNode.y);

				 addToOpenList(thisNode,  pqCurrentNode,  targetNode, 10);
			}

			if(0 <= (currentNode.x-1) && _GRID_RESOLUTION_X_AXIS >(currentNode.y+1) ) //To Left-Up
			{
				uint2 thisNode = uint2(currentNode.x-1,currentNode.y+1);

				 addToOpenList(thisNode,  pqCurrentNode,  targetNode, 14);
			}

			if(_GRID_RESOLUTION_X_AXIS >(currentNode.y+1) ) //To Up
			{
				uint2 thisNode = uint2(currentNode.x,currentNode.y+1);

				 addToOpenList(thisNode,  pqCurrentNode,  targetNode, 10);
			}

			if(0 <= (currentNode.x+1) && _GRID_RESOLUTION_X_AXIS >(currentNode.y+1) ) //To UP-RIGHT
			{
				uint2 thisNode = uint2(currentNode.x+1,currentNode.y+1);

				 addToOpenList(thisNode,  pqCurrentNode,  targetNode, 14);
			}
		}
	}

	SearchResult result;
	result.agentId = agent.id;
	result.finalCost = pqCurrentNode.y;
	result.targetLoc = uint2(currentNode.x,currentNode.y);

	gBufferOut[0] = result; 

}


void addToOpenList(uint2 thisNode, uint3 pqCurrentNode, uint2 targetNode, uint G_COST)
{
		const int _COLLISION_NODE = 1;
		const int _STATUS_UNREAD = 0;
		const int _NODE_OPEN = 1;
	// 1. check if status is _STATUS_UNREAD
	if(m_map[thisNode].z != _COLLISION_NODE)
	{
		uint thisGridNodeID = getGridIntegerCoordinate(thisNode.x,thisNode.y);
		uint4 thisGridNode = gGridNodeListOut[thisGridNodeID];

			// 2. Check if not collision node on texture 2d
			if( thisGridNode.w == _STATUS_UNREAD)
			{									
				uint3 pqNode;
				// Set the Grid ID for the new node
				pqNode.x = thisGridNodeID;

				// 3. Calculate G cost (parent_G + current)
				pqNode.z = pqCurrentNode.z + G_COST;

				// 4. calculate H cost
				uint x_temp = abs(thisNode.x- targetNode.x);
				uint y_temp = abs(thisNode.y - targetNode.y);

				pqNode.y = pqNode.z + (x_temp+y_temp)*10; // F = G + H
				// 5. insert into PQ
				insertPQ(pqNode);

				// 6. set current node ID as parent
				// 7. set node status open;	
				// 8. Insert into GridNodeList
				InsertIntoGridNodeList(thisNode.x, thisNode.y, pqCurrentNode.x , _NODE_OPEN);
			}
	}
}
void InsertIntoGridNodeList(uint x, uint y,  uint parentId, uint status  )
{
	uint gridId = getGridIntegerCoordinate(x, y);
	gGridNodeListOut[gridId] = uint4(x, y, parentId, status );
}

//void setStatusCloseGridNode(uint gridId)
//{
//
//	if(GridNodeList[gridId].w == _NODE_OPEN) // TODO: We can remove this check  for performence
//	{
//		GridNodeList[gridId].w == _NODE_CLOSED;	
//	}
//
//
//}

uint getGridIntegerCoordinate(uint x, uint y)
{
	uint gridId = _GRID_RESOLUTION_X_AXIS * y + x;
	return gridId;
}


uint3 removePQ()
{
	uint currentSize = gOpenListOut[0].y;

	uint3 newTemp;		
	newTemp.y = 0;
	uint3 nodeReturn ;

	if(currentSize >=1)
	{
		nodeReturn = gOpenListOut[1];

		gOpenListOut[1] = gOpenListOut[currentSize];

		gOpenListOut[currentSize] = newTemp;

		currentSize = currentSize -1;

		gOpenListOut[0].y = currentSize;

		uint i = 1;

		bool flag = false;

		if(currentSize >=1)
		{
			[allow_uav_condition]
			while(true)
			{
				uint rightChild = (i*2)+1;
				uint leftChild = i*2;
				uint replaceId = 1;

				if(rightChild >= currentSize)
				{
					if(leftChild >= currentSize)
					{
						break;
					}
					else
						replaceId = leftChild;
				}
				else
				{
					if(gOpenListOut[leftChild].y <= gOpenListOut[rightChild].y)
					{
						replaceId = leftChild;
					}
					else
					{
						replaceId = rightChild;
					}
				}

				if(gOpenListOut[i].y > gOpenListOut[replaceId].y)
				{
					uint3 temp ;

					temp = gOpenListOut[replaceId];

					gOpenListOut[replaceId] = gOpenListOut[i]; 
					gOpenListOut[i] = temp;
					i = replaceId;
				}
				else{
					break;
				}

			}
		}
	}


	return nodeReturn;

}


////////////////////////////////////////////////////////////////////////////
//// Experimental Code Commented here, make use of it when needed //////////
////////////////////////////////////////////////////////////////////////////
//DATE 2014-07-26
//Node nodeTemp;
//nodeTemp.coords = uint2(100,200);
//
//gOpenListOut[33] = nodeTemp;

//gOpenListOut[33].id = 12;

//gOpenListOut[33].cost = 1000;

//uint numNodes, stride;
//gOpenListOut.GetDimensions(numNodes, stride);

//gBufferOut[0].agentId = numNodes;

//gBufferOut[0].targetLoc = gOpenListOut[33].coords;

//gBufferOut[0].finalCost = gOpenListOut[33].cost;

//gBufferOut[1].agentId =  gAgentListInput[0].id;

//gBufferOut[1].targetLoc =  gAgentListInput[0].targetLoc;
//////////////////////////////////////////////////////////////////////////////
//uint i = 8;

//BufferOut[0].cost = 0;
//BufferOut[0].cost = gRandomTex[uint2(127,0)];//gRandomTex.Load(int3(0,1,0));//gRandomTex[uint2(0,1)];//gRandomTex.SampleLevel(samLinear, 1, 0).xyzw;

//BufferOut[1].cost = gRandomTex[uint2(256,512)];//gRandomTex.Load(int3(0,2,0));//gRandomTex.SampleLevel(samLinear, 2, 0).xyzw;

//BufferOut[2].cost = gRandomTex[uint2(0,3)];//gRandomTex.Load(int3(0,3,0));//gRandomTex.SampleLevel(samLinear, 3, 0).xyzw;

//BufferOut[3].cost = gRandomTex[uint2(0,4)];//gRandomTex.Load(int3(0,4,0));

//BufferOut[4].cost =  gRandomTex[uint2(0,5)];// gRandomTex.Load(int3(0,5,0));

//BufferOut[5].cost = gRandomTex[uint2(0,6)];// gRandomTex.Load(int3(0,6,0));

//BufferOut[6].cost = gRandomTex[uint2(0,7)];//gRandomTex.Load(int3(0,7,0));
//BufferOut[3].cost = gRandomTex.SampleLevel(samLinear, 4, 0).xyzw;

//uint2 uv = uint2(u,v);
//uint v = 2;
//BufferOut[0].cost = gRandomTex[int2(0, 0)]; //gRandomTex.SampleLevel(samLinear, 0.0f, 0).xyz;
//BufferOut[0].id = gRandomTex[int2(0, 0)].x;
//BufferOut[1].cost = gRandomTex[int2(1, 0)];//gRandomTex.SampleLevel(samLinear, 0.1f, 0).xyz;
//BufferOut[1].id = gRandomTex[int2(1, 0)].y;
//BufferOut[2].cost = gRandomTex[int2(2, 0)];//gRandomTex.SampleLevel(samLinear, 0.2f, 0).xyz;
//BufferOut[2].id = gRandomTex[int2(2, 0)].z;
//BufferOut[3].cost = gRandomTex[int2(3, 0)];//gRandomTex.SampleLevel(samLinear, 0.3f, 0).xyz;

//BufferOut[4].cost = gRandomTex[int2(0, 1)] ; //gRandomTex.SampleLevel(samLinear, 0.0f, 0).xyz;
//BufferOut[5].cost = gRandomTex[int2(1, 1)] ;//gRandomTex.SampleLevel(samLinear, 0.1f, 0).xyz;
//BufferOut[6].cost = gRandomTex[int2(2, 1)] ;//gRandomTex.SampleLevel(samLinear, 0.2f, 0).xyz;
//BufferOut[7].cost = gRandomTex[int2(3, 1)] ;//gRandomTex.SampleLevel(samLinear, 0.3f, 0).xyz;

//BufferOut[8].cost = gRandomTex.SampleLevel(samLinear, uint2(1.0, 0.0), 0);
//BufferOut[8].id = gRandomTex.SampleLevel(samLinear, uint2(1.0, 0.0), 0).x;
//BufferOut[9].cost = gRandomTex.SampleLevel(samLinear, uint2(1.0, 0.0), 0);
//BufferOut[10].cost = gRandomTex.SampleLevel(samLinear, uint2(1.0, 0.0), 0);
//BufferOut[11].cost = gRandomTex.SampleLevel(samLinear, uint2(1.0 , 0.0), 0);
//
//BufferOut[8].cost = gRandomTex[int2(0, 2)] ; //gRandomTex.SampleLevel(samLinear, 0.0f, 0).xyz;
//BufferOut[9].cost = gRandomTex[int2(1, 2)] ;//gRandomTex.SampleLevel(samLinear, 0.1f, 0).xyz;
//BufferOut[10].cost = gRandomTex[int2(2, 2)] ;//gRandomTex.SampleLevel(samLinear, 0.2f, 0).xyz;
//BufferOut[11].cost = gRandomTex[int2(3, 2)] ;//gRandomTex.SampleLevel(samLinear, 0.3f, 0).xyz;


/*BufferOut[1].cost = SampleLevel(samLinear, uint2(1, 0));
BufferOut[2].cost = SampleLevel(samLinear, uint2(2, 0));
BufferOut[3].cost = SampleLevel(samLinear, uint2(3, 0);*/



/*	
Node node1;
node1.cost = 2;
node1.id = 1;
insertPQ(node1);

Node node2;
node2.cost = 3;
node2.id = 1;
insertPQ(node2);

Node node3;
node3.cost = 5;
node3.id = 1;
insertPQ(node3);

Node node4;
node4.cost = 10;
node4.id = 1;
insertPQ(node4);

Node node5;
node5.cost = 6;
node5.id = 1;
insertPQ(node5);

Node node6;
node6.cost = 11;
node6.id = 1;
insertPQ(node6);

Node node7;
node7.cost = 5;
node7.id = 1;
insertPQ(node7);

Node node8;
node8.cost = 17;
node8.id = 1;
insertPQ(node8);


Node node9;
node9.cost = 10;
node9.id = 1;
insertPQ(node9);

Node node10;
node10.cost = 7;
node10.id = 1;
insertPQ(node10);

Node node11;
node11.cost = 8;
node11.id = 1;
insertPQ(node11);

Node pop = removePQ();
BufferOut[0].id = pop.cost;

Node pop1 = removePQ();
BufferOut[0].id = pop1.cost;*/
/***************************************************************/
/*Node node11;
node11.cost = 2;
node11.id = 1;
insertPQ(node11);*/
/*if(DTid.x < 3 && DTid.y < 3)
{
uint sum = 0 ;
for(uint i = 0; i < 3 ; i++)
{
uint addrA = DTid.y * 3 +i ;
uint addrB = DTid.x + i * 3 ;

sum += MatrixA[addrA].f * MatrixB[addrB].f;
}

SubType subTemp;

subTemp.f1 = sum;
BufferOut[DTid.y * 3 + DTid.x].sub = subTemp;
}*/

//	MatrixA[0].f = 100;
/*for(uint i=0; i<=20; i++){
Node node;
node.cost = 12;
node.id = i;
insertPQ(node, i );
}*/

//	BufferOut = BufferOutClone;