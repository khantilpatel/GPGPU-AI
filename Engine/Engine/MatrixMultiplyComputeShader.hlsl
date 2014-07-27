
struct BufType
{
    float f;
};

struct SubType
{
	float f1;	
};

struct ParentType
{
	SubType sub[40];
};

struct Node
{
	float2 coords;
	uint cost;
	int id;
};

struct Agent
{
	int id;
	float2 sourceLoc;
	float2 targetLoc;
};

struct SearchResult
{
	int agentId;
	int finalCost;
	float2 targetLoc;
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
Texture2D<float4> gWorldMapTextureInput : register(t2);

// Temp OpenList for A* executed by each Agent 
RWStructuredBuffer<Node> gOpenListOut ;

// Final Result of A* for each Agent
RWStructuredBuffer<SearchResult> gBufferOut : register(u0);
//RWStructuredBuffer<ParentType> BufferOutClone : register(u1);
//

void insertPQ(Node node){

	uint currentSize = gOpenListOut[0].cost;
	uint i = currentSize+1;

	[allow_uav_condition]
	while( i > 1 && gOpenListOut[i/2].cost > node.cost )
	{
		gOpenListOut[i] = gOpenListOut[i/2];
		i = i/2;
	}

	gOpenListOut[i] = node;
	gOpenListOut[0].cost = gOpenListOut[0].cost + 1;
	//gOpenListOut[i] = node;
	
}

Node removePQ()
{
	uint currentSize = gOpenListOut[0].cost;

		Node newTemp;
		newTemp.id =0;
		newTemp.cost = 0;
	Node nodeReturn = newTemp;

	if(currentSize >=1)
	{
		nodeReturn = gOpenListOut[1];

		gOpenListOut[1] = gOpenListOut[currentSize];
			
		gOpenListOut[currentSize] = newTemp;

		currentSize = currentSize -1;

		gOpenListOut[0].cost = currentSize;

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
					if(gOpenListOut[leftChild].cost <= gOpenListOut[rightChild].cost)
					{
						replaceId = leftChild;
					}
					else
					{
						replaceId = rightChild;
					}
				}

				if(gOpenListOut[i].cost > gOpenListOut[replaceId].cost)
				{
						Node temp ;
						
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

[numthreads(1, 1, 1)]
void main( uint3 DTid : SV_DispatchThreadID )
{

	Node nodeTemp;
	nodeTemp.coords = float2(100,200);
	
	gOpenListOut[0] = nodeTemp;

	gOpenListOut[0].id = 12;

	gOpenListOut[0].cost = 1000;

	gBufferOut[0].targetLoc = gOpenListOut[0].coords;

	gBufferOut[0].finalCost = gOpenListOut[0].cost;

	//uint _GRID_RESOLUTION_X_AXIS = 8;
	//Agent agent = gAgentListInput[0];

	//Node nodeFirst;
	//nodeFirst.coords = agent.sourceLoc;

	//insertPQ(nodeFirst);

	//bool targetFound = false;
	//
	//while(!targetFound)
	//{
	//	Node currentNode = removePQ();

	//	int current_x = Node.x;
	//	int current_y = Node.y;

	//	if(_GRID_RESOLUTION_X_AXIS > (current_x+1)) // To the immidiate right
	//	{

	//	}

	//	if(_GRID_RESOLUTION_X_AXIS > (current_x+1) && 0 <= (current_y-1)) // To the Right-Down
	//	{
	//			
	//	}

	//	if(0 <= (current_y-1)) // To Below/Down
	//	{

	//	}

	//	if(0 <= (current_x-1) && 0 <= (current_y-1) ) //To Left-Down
	//	{

	//	}

	//	if(0 <= (current_x-1)) //To Left
	//	{
	//	
	//	}

	//	if(0 <= (current_x-1) && _GRID_RESOLUTION_Y_AXIS >(current_y+1) ) //To Left-Up
	//	{

	//	}

	//	if(_GRID_RESOLUTION_Y_AXIS >(current_y+1) ) //To Up
	//	{

	//	}

	//	if(0 <= (current_x+1) && _GRID_RESOLUTION_Y_AXIS >(current_y+1) ) //To UP-RIGHT
	//	{

	//	}
	//}

}



////////////////////////////////////////////////////////////////////////////
//// Experimental Code Commented here, make use of it when needed //////////
////////////////////////////////////////////////////////////////////////////
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

	//float2 uv = float2(u,v);
	//float v = 2;
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

	//BufferOut[8].cost = gRandomTex.SampleLevel(samLinear, float2(1.0, 0.0), 0);
	//BufferOut[8].id = gRandomTex.SampleLevel(samLinear, float2(1.0, 0.0), 0).x;
	//BufferOut[9].cost = gRandomTex.SampleLevel(samLinear, float2(1.0, 0.0), 0);
	//BufferOut[10].cost = gRandomTex.SampleLevel(samLinear, float2(1.0, 0.0), 0);
	//BufferOut[11].cost = gRandomTex.SampleLevel(samLinear, float2(1.0 , 0.0), 0);
	//
	//BufferOut[8].cost = gRandomTex[int2(0, 2)] ; //gRandomTex.SampleLevel(samLinear, 0.0f, 0).xyz;
	//BufferOut[9].cost = gRandomTex[int2(1, 2)] ;//gRandomTex.SampleLevel(samLinear, 0.1f, 0).xyz;
	//BufferOut[10].cost = gRandomTex[int2(2, 2)] ;//gRandomTex.SampleLevel(samLinear, 0.2f, 0).xyz;
	//BufferOut[11].cost = gRandomTex[int2(3, 2)] ;//gRandomTex.SampleLevel(samLinear, 0.3f, 0).xyz;

	
	/*BufferOut[1].cost = SampleLevel(samLinear, float2(1, 0));
	BufferOut[2].cost = SampleLevel(samLinear, float2(2, 0));
	BufferOut[3].cost = SampleLevel(samLinear, float2(3, 0);*/



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
		float sum = 0 ;
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