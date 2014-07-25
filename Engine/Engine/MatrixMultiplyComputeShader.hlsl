
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
	float4 cost;
	int id;
};

SamplerState samLinear
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};

StructuredBuffer<BufType> MatrixA : register(t0);
StructuredBuffer<BufType> MatrixB : register(t1);
Texture2D<float4> gRandomTex : register(t2);

RWStructuredBuffer<Node> BufferOut : register(u0);
//RWStructuredBuffer<ParentType> BufferOutClone : register(u1);
//
//void insertPQ(Node node){
//
//	uint currentSize = BufferOut[0].cost;
//	uint i = currentSize+1;
//
//	[allow_uav_condition]
//	while( i > 1 && BufferOut[i/2].cost > node.cost )
//	{
//		BufferOut[i] = BufferOut[i/2];
//		i = i/2;
//	}
//
//	BufferOut[i] = node;
//	BufferOut[0].cost = BufferOut[0].cost + 1;
//	//BufferOut[i] = node;
//	
//}
//
//Node removePQ()
//{
//	uint currentSize = BufferOut[0].cost;
//
//		Node newTemp;
//		newTemp.id =0;
//		newTemp.cost = 0;
//	Node nodeReturn = newTemp;
//
//	if(currentSize >=1)
//	{
//		nodeReturn = BufferOut[1];
//
//		BufferOut[1] = BufferOut[currentSize];
//			
//		BufferOut[currentSize] = newTemp;
//
//		currentSize = currentSize -1;
//
//		BufferOut[1].cost = currentSize;
//
//		uint i = 1;
//
//		bool flag = false;
//		
//		if(currentSize >=1)
//		{
//			[allow_uav_condition]
//			while(true)
//			{
//				uint rightChild = (i*2)+1;
//				uint leftChild = i*2;
//				uint replaceId = 1;
//
//				if(rightChild >= currentSize)
//				{
//					if(leftChild >= currentSize)
//					{
//						break;
//					}
//					else
//						replaceId = leftChild;
//				}
//				else
//				{
//					if(BufferOut[leftChild].cost <= BufferOut[rightChild].cost)
//					{
//						replaceId = leftChild;
//					}
//					else
//					{
//						replaceId = rightChild;
//					}
//				}
//
//				if(BufferOut[i].cost > BufferOut[replaceId].cost)
//				{
//						Node temp = BufferOut[replaceId];
//
//						BufferOut[replaceId] = BufferOut[i]; 
//						BufferOut[i] = temp;
//						i = replaceId;
//				}
//				else{
//					break;
//				}
//				
//			}
//		}
//	}
//
//
//	return nodeReturn;
//
//}

[numthreads(1, 1, 1)]
void main( uint3 DTid : SV_DispatchThreadID )
{
	//uint i = 8;

	//BufferOut[0].cost = 0;
	BufferOut[0].cost = gRandomTex[uint2(127,0)];//gRandomTex.Load(int3(0,1,0));//gRandomTex[uint2(0,1)];//gRandomTex.SampleLevel(samLinear, 1, 0).xyzw;

	BufferOut[1].cost = gRandomTex[uint2(256,512)];//gRandomTex.Load(int3(0,2,0));//gRandomTex.SampleLevel(samLinear, 2, 0).xyzw;

	BufferOut[2].cost = gRandomTex[uint2(0,3)];//gRandomTex.Load(int3(0,3,0));//gRandomTex.SampleLevel(samLinear, 3, 0).xyzw;

	BufferOut[3].cost = gRandomTex[uint2(0,4)];//gRandomTex.Load(int3(0,4,0));

	BufferOut[4].cost =  gRandomTex[uint2(0,5)];// gRandomTex.Load(int3(0,5,0));

	BufferOut[5].cost = gRandomTex[uint2(0,6)];// gRandomTex.Load(int3(0,6,0));

	BufferOut[6].cost = gRandomTex[uint2(0,7)];//gRandomTex.Load(int3(0,7,0));
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



		
	//Node node1;
	//node1.cost = 2;
	//node1.id = 1;
	//insertPQ(node1);

	//Node node2;
	//node2.cost = 3;
	//node2.id = 1;
	//insertPQ(node2);

	//Node node3;
	//node3.cost = 5;
	//node3.id = 1;
	//insertPQ(node3);

	//Node node4;
	//node4.cost = 10;
	//node4.id = 1;
	//insertPQ(node4);

	//Node node5;
	//node5.cost = 6;
	//node5.id = 1;
	//insertPQ(node5);

	//Node node6;
	//node6.cost = 11;
	//node6.id = 1;
	//insertPQ(node6);

	//Node node7;
	//node7.cost = 5;
	//node7.id = 1;
	//insertPQ(node7);

	//Node node8;
	//node8.cost = 17;
	//node8.id = 1;
	//insertPQ(node8);

	//
	//Node node9;
	//node9.cost = 10;
	//node9.id = 1;
	//insertPQ(node9);

	//Node node10;
	//node10.cost = 7;
	//node10.id = 1;
	//insertPQ(node10);

	//Node node11;
	//node11.cost = 8;
	//node11.id = 1;
	//insertPQ(node11);

	//Node pop = removePQ();
	//BufferOut[0].id = pop.cost;
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
}

