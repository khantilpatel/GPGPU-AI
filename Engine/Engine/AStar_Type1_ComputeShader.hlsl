

#define MAP_SIZE 8
#define _GRID_RESOLUTION_X_AXIS 8
#define NUM_NODES_PER_THREAD (_GRID_RESOLUTION_X_AXIS * _GRID_RESOLUTION_X_AXIS)

#define NUM_THREAD_GROUP_X 2
#define NUM_THREAD_GROUP_Y 2

#define NUM_THREAD_X 32
#define NUM_THREAD_Y 32

#define NUM_THREAD_ON_GRID_X (NUM_THREAD_X * NUM_THREAD_GROUP_X)
#define NUM_THREAD_ON_GRID_Y (NUM_THREAD_Y * NUM_THREAD_GROUP_Y)

#define NUM_THREADS_PER_BLOCK (NUM_THREAD_X*NUM_THREAD_Y)
#define STRIDE_GRID_ACCESS ( NUM_THREADS_PER_BLOCK*NUM_NODES_PER_THREAD )
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

struct uint5{
	uint x;
	uint y;
	uint parentId;
	uint status;
	uint cost;
	uint G_cost;
	uint pqId;
};

SamplerState samLinear
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};


//static const uint _GRID_RESOLUTION_X_AXIS = 8;



// Input List with Agents data from CPU
StructuredBuffer<Agent> gAgentListInput : register(t0);

// World map 2D Texture from CPU
Texture2D<uint4> m_map : register(t2);

// Temp OpenList for A* executed by each Agent 
// x = ID of the Node
// y = Cost of the node
// z = G cost
RWStructuredBuffer<uint> gOpenListOut: register(u0);

// Temp Grid List to maintain the status and target pointers
// x, y = 2D location on grid
// z = ID of the parent pointer node
// w = Status of Node Unread = 0; Open = 1; Closed = 2; UnWalkable=3;
RWStructuredBuffer<uint5> gGridNodeListOut: register(u2);
// Final Result of A* for each Agent
RWStructuredBuffer<SearchResult> gBufferOut : register(u1);
//RWStructuredBuffer<ParentType> BufferOutClone : register(u1);
//

uint getGridOffset(uint dispatch_x, uint dispatch_y)
{
	uint gridId = NUM_THREAD_GROUP_X * dispatch_y + dispatch_x;
	return  gridId * STRIDE_GRID_ACCESS;
}

uint getThreadOffset(uint dispatch_x, uint dispatch_y)
{
	//uint gridId = NUM_THREAD_X * dispatch_y + dispatch_x;
	uint gridId = NUM_THREAD_ON_GRID_X * dispatch_y + dispatch_x;
	return  gridId * NUM_NODES_PER_THREAD;
	
}

uint getGridIntegerCoordinate(uint x, uint y)
{
	uint gridId = _GRID_RESOLUTION_X_AXIS * y + x;
	return gridId;
}

void insertPQ(uint offset, uint x, uint y, uint current_cost, uint G_cost, uint parentId, uint status){

	
	// 1.First get the Grid ID of the new node
	uint gridId =  getGridIntegerCoordinate(x, y);

	// 3. Insert the Grid ID into the PQ according to its current_cost. 
	uint currentSize = gOpenListOut[offset + 0];

	uint i = currentSize + 1;

	uint parent_cost = gGridNodeListOut[offset + gOpenListOut[offset + (i / 2)]].cost;
	[allow_uav_condition]
	while (i > 1 && parent_cost > current_cost)
	{
		gOpenListOut[offset + i] = gOpenListOut[offset + (i / 2)];
		gGridNodeListOut[offset + gOpenListOut[offset + i]].pqId = i;

		i = i / 2;
		parent_cost = gGridNodeListOut[offset + gOpenListOut[offset + i]].cost;
	}

	// 2. Insert into GridNodeList with cost
	uint5 GridNode;
	GridNode.x = x;
	GridNode.y = y;
	GridNode.cost = current_cost;
	GridNode.parentId = offset + parentId;
	GridNode.status = status;
	GridNode.G_cost = G_cost;
	GridNode.pqId = i;
	gGridNodeListOut[offset + gridId] = GridNode;

	//Insert into PQ;
	gOpenListOut[offset + i] = gridId;
	gOpenListOut[offset + 0] = gOpenListOut[offset + 0] + 1;
	//gOpenListOut[i] = node;

}

void updatePQ(uint offset, uint pqId, uint current_cost)
{

	// 1.First get the Grid ID of the new node
	
	// 3. Insert the Grid ID into the PQ according to its current_cost. 
	//uint currentSize = gOpenListOut[0];

	uint i = pqId; // currentSize + 1;

	uint orignal_value = gOpenListOut[offset + i];
	uint parent_cost = gGridNodeListOut[offset + gOpenListOut[offset + (i / 2)]].cost;

	[allow_uav_condition]
	while (i > 1 && parent_cost > current_cost)
	{
		gOpenListOut[offset + i] = gOpenListOut[offset + (i / 2)];
		gGridNodeListOut[offset+ gOpenListOut[offset + i]].pqId = i;

		i = i / 2;
		parent_cost = gGridNodeListOut[offset + gOpenListOut[offset + (i / 2)]].cost;
	}

	gOpenListOut[offset + i] = orignal_value;
	gGridNodeListOut[offset + gOpenListOut[offset + i]].pqId = i;

}

uint removePQ(uint offset)
{
	
	uint currentSize = gOpenListOut[offset + 0];

	uint newTemp = 0;


	uint nodeReturn = newTemp;

	if (currentSize >= 1)
	{
		nodeReturn = gOpenListOut[offset + 1];

		gOpenListOut[offset + 1] = gOpenListOut[offset + currentSize];

		gGridNodeListOut[offset + gOpenListOut[offset + 1]].pqId = 1;

		gOpenListOut[offset + currentSize] = newTemp;

		currentSize = currentSize - 1;

		gOpenListOut[offset + 0] = currentSize;

		uint i = 1;

		bool flag = false;

		if (currentSize >= 1)
		{
			[allow_uav_condition]
			while (true)
			{
				uint rightChild = (i * 2) + 1;
				uint leftChild = i * 2;
				uint replaceId = 1;
				uint currentNodeCost;
				uint replaceableChildCost = 0;
				if (rightChild >= currentSize)
				{
					if (leftChild >= currentSize)
					{
						break;
					}
					else
						replaceId = leftChild;
					replaceableChildCost = gGridNodeListOut[offset + gOpenListOut[offset + replaceId]].cost;;
				}
				else
				{
					uint leftChildCost = gGridNodeListOut[offset + gOpenListOut[offset + leftChild]].cost;
					uint rightChildCost = gGridNodeListOut[offset + gOpenListOut[offset + rightChild]].cost;

					if (leftChildCost <= rightChildCost)
					{
						replaceId = leftChild;
						replaceableChildCost = leftChildCost;
					}
					else
					{
						replaceId = rightChild;
						replaceableChildCost = rightChildCost;
					}
				}
				currentNodeCost = gGridNodeListOut[offset + gOpenListOut[offset + i]].cost;
				if (currentNodeCost > replaceableChildCost)
				{
					uint temp;

					temp = gOpenListOut[offset + replaceId];
					gOpenListOut[offset + replaceId] = gOpenListOut[offset + i];
					gOpenListOut[offset + i] = temp;

					gGridNodeListOut[offset + gOpenListOut[offset + replaceId]].pqId = replaceId;
					gGridNodeListOut[offset + gOpenListOut[i]].pqId = i;

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

//void InsertIntoGridNodeList(uint x, uint y, uint parentId, uint status)
//{
//	uint gridId = getGridIntegerCoordinate(x, y);
//	gGridNodeListOut[gridId] = uint4(x, y, parentId, status);
//}

void addToOpenList(uint offset, uint2 thisNode, uint5 parentGridNodeObject, uint parentGridId, uint2 targetNode, uint G_COST)
{
	
	const uint _COLLISION_NODE = 1;
	const uint _STATUS_UNREAD = 0;
	const uint _NODE_OPEN = 1;
	// 1. check if status is _STATUS_UNREAD
	//if(m_map[thisNode].z != _COLLISION_NODE)
	//{
	uint thisGridNodeID = getGridIntegerCoordinate(thisNode.x, thisNode.y);
	uint5 thisGridNode = gGridNodeListOut[offset + thisGridNodeID];

	// 2. Check if not collision node on texture 2d
	if (thisGridNode.status == _STATUS_UNREAD)
	{
		// 3. Calculate G cost (parent_G + current)
		uint current_G_cost = parentGridNodeObject.G_cost + G_COST;

		int x1 = int(thisNode.x);
		int x2 = int(targetNode.x);
		// 4. calculate H cost
		int x_temp = abs(x1 - x2);
		int y_temp = abs(asfloat(thisNode.y) - asfloat(targetNode.y));

		int temp = max(x_temp, y_temp);
		uint H = uint(temp);
		uint current_cost = current_G_cost + H * 10; // F = G + H

		// 5. insert into PQ
		// 6. set current node ID as parent
		// 7. set node status open;	
		// 8. Insert into GridNodeList
		insertPQ(offset, thisNode.x, thisNode.y, current_cost, current_G_cost, parentGridId, _NODE_OPEN);

	}
	else if (thisGridNode.status == _NODE_OPEN)
	{
		uint current_G_cost = parentGridNodeObject.G_cost + G_COST;

		// 5. insert into PQ
		//insertPQ(pqNode, );
		if (current_G_cost < thisGridNode.G_cost)
		{
			int x1 = int(thisNode.x);
			int x2 = int(targetNode.x);
			// 4. calculate H cost
			int x_temp = abs(x1 - x2);
			int y_temp = abs(asfloat(thisNode.y) - asfloat(targetNode.y));

			int temp = x_temp + y_temp;
			uint H = uint(temp);
			uint F = current_G_cost + H * 10; // F = G + H
			gGridNodeListOut[offset + thisGridNodeID].cost = F;
			uint pqId = thisGridNode.pqId;
			updatePQ(offset, pqId, F);
		}
	}
}

[numthreads(NUM_THREAD_X, NUM_THREAD_Y, 1)] //NUM_THREAD_X
void main(uint3 DTid : SV_DispatchThreadID, uint3 GTid :SV_GroupID)
{
	uint2 DTid1 = uint2(63,63);
	//uint grid_offset = getGridOffset(1, 1);
	uint offset = getThreadOffset(DTid.x, DTid.y); //getThreadOffset(2, 0);
	uint threadId = (64 * DTid.y) + DTid.x;//(NUM_THREAD_X * DTid.y) + DTid.x;

	uint5 node;
	node.x = 4;
	node.y = 2;
	node.cost = 0;
	node.G_cost = 0;
	node.parentId = 0;
	node.status = 3;
	node.pqId = 0;
	gGridNodeListOut[offset + 20] = node;

	node.x = 4;
	node.y = 3;
	node.cost = 0;
	node.G_cost = 0;
	node.status = 3;
	gGridNodeListOut[offset + 28] = node;

	node.x = 4;
	node.y = 4;
	node.cost = 0;
	node.G_cost = 0;
	node.status = 3;
	gGridNodeListOut[offset + 36] = node;

	node.x = 4;
	node.y = 5;
	node.cost = 0;
	node.G_cost = 0;
	node.status = 3;
	gGridNodeListOut[offset + 44] = node;

	node.x = 4;
	node.y = 6;
	node.cost = 0;
	node.G_cost = 0;
	node.status = 3;
	gGridNodeListOut[offset + 52] = node;

	gOpenListOut[offset + 0] = 0;
	const int _NONE_UNREAD = 0;
	const int _NODE_OPEN = 1;
	const int _NODE_CLOSED = 2;
	const int _WALKABLE_NODE = 0;
	const int _COLLISION_NODE = 1;
	Agent agent = gAgentListInput[threadId];

	// Get Source node to start the search with
	uint2 nodeFirstLoc;
	nodeFirstLoc = agent.sourceLoc;

	// Get Target node to check in the while loop if path found
	uint2 targetNode;
	targetNode = agent.targetLoc;
	uint targetNodeGridId = getGridIntegerCoordinate(targetNode.x, targetNode.y);
	
	// Insert the first node into OpenList;
	// &
	// Insert into GridNodeList
	insertPQ(offset, nodeFirstLoc.x, nodeFirstLoc.y, 10, 0, 0, _NODE_OPEN);

	bool targetFound = false;
	int loopCounter = 0;
	uint4 currentGridNode;
	uint5 currentNode;
	// Loop until path to target node found or no path found
	[allow_uav_condition]
	while (!targetFound)
	{
		uint m_GridId = removePQ(offset);

		gGridNodeListOut[offset + m_GridId].status = _NODE_CLOSED;
		currentNode = gGridNodeListOut[offset + m_GridId];

		// terminate if no path found or pathfound
		if (currentNode.cost == 0 || m_GridId == targetNodeGridId)
		{
			targetFound = true;
			break;
		}
		else{
			loopCounter = loopCounter + 1;
			//currentGridNode = gGridNodeListOut[pqTopNode.x];		
			float tempx = float(currentNode.x);
			float tempy = float(currentNode.y);
			if (_GRID_RESOLUTION_X_AXIS > tempx + 1) // To the immidiate right
			{
				uint2 thisNode = uint2(currentNode.x + 1, currentNode.y);
					addToOpenList(offset, thisNode, currentNode, m_GridId, targetNode, 10);
			}

			if (_GRID_RESOLUTION_X_AXIS > (tempx + 1) && 0 <= (tempy - 1)) // To the Right-Down
			{
				uint2 thisNode = uint2(currentNode.x + 1, currentNode.y - 1);
					addToOpenList(offset, thisNode, currentNode, m_GridId, targetNode, 14);
			}

			if (0 <= (tempy - 1)) // To Below/Down
			{
				uint2 thisNode = uint2(currentNode.x, currentNode.y - 1);
					addToOpenList(offset, thisNode, currentNode, m_GridId, targetNode, 10);
			}

			if (0 <= (tempx - 1) && 0 <= (tempy - 1)) //To Left-Down
			{
				uint2 thisNode = uint2(currentNode.x - 1, currentNode.y - 1);
					addToOpenList(offset, thisNode, currentNode, m_GridId, targetNode, 14);
			}

			if (0 <= (tempx - 1)) //To Left
			{
				uint2 thisNode = uint2(currentNode.x - 1, currentNode.y);
					addToOpenList(offset, thisNode, currentNode, m_GridId, targetNode, 10);
			}

			if (0 <= (tempx - 1) && _GRID_RESOLUTION_X_AXIS > (tempy + 1)) //To Left-Up
			{
				uint2 thisNode = uint2(currentNode.x - 1, currentNode.y + 1);
					addToOpenList(offset, thisNode, currentNode, m_GridId, targetNode, 14);
			}

			if (_GRID_RESOLUTION_X_AXIS > (tempy + 1)) //To Up
			{
				uint2 thisNode = uint2(currentNode.x, currentNode.y + 1);
					addToOpenList(offset, thisNode, currentNode, m_GridId, targetNode, 10);
			}

			if (0 <= (tempx + 1) && _GRID_RESOLUTION_X_AXIS > (tempy + 1)) //To UP-RIGHT
			{
				uint2 thisNode = uint2(currentNode.x + 1, currentNode.y + 1);
					addToOpenList(offset, thisNode, currentNode, m_GridId, targetNode, 14);
			}
		}

		//if (loopCounter==42) //8
		//	break;
	}

	SearchResult result;
	result.agentId = agent.id;//agent.id;
	result.finalCost = currentNode.cost;//pqCurrentNode.y;
	float2 target = float2(currentNode.x, currentNode.y);// float2(DTid.x, DTid.y); 
	result.targetLoc = target;

	gBufferOut[threadId] = result;
}


//gOpenListOut[0] = uint3(10, 15, 20);

//gOpenListOut[0].y = gOpenListOut[0].y + 10;





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

//uint3 node1;
//node1.y = 2;
//node1.x = 1;
//node1.z = 0;
//insertPQ(node1);
//
//uint3 node2;
//node2.y = 3;
//node2.x = 1;
//node2.z = 0;
//insertPQ(node2);
//
//uint3 node3;
//node3.y = 5;
//node3.x = 1;
//node3.z = 0;
//insertPQ(node3);
//
//
//uint3 node4;
//node4.y = 10;
//node4.x = 1;
//node4.z = 0;
//insertPQ(node4);
//
//uint3 node5;
//node5.y = 6;
//node5.x = 1;
//node5.z = 0;
//insertPQ(node5);
//
//uint3 node6;
//node6.y = 11;
//node6.x = 1;
//node6.z = 0;
//insertPQ(node6);
//
//uint3 node7;
//node7.y = 5;
//node7.x = 1;
//node7.z = 0;
//insertPQ(node7);
//
//uint3 node8;
//node8.y = 17;
//node8.x = 1;
//node8.z = 0;
//insertPQ(node8);
//
//
//uint3 node9;
//node9.y = 10;
//node9.x = 1;
//node9.z = 0;
//insertPQ(node9);
//
//uint3 node10;
//node10.y = 7;
//node10.x = 1;
//node10.z = 0;
//insertPQ(node10);
//
//uint3 node11;
//node11.y = 8;
//node11.x = 1;
//node11.z = 0;
//insertPQ(node11);
//
//removePQ();
//removePQ();