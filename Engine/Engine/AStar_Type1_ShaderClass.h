////////////////////////////////////////////////////////////////////////////////
// Filename: MatrixMultiplyShaderClass.h
////////////////////////////////////////////////////////////////////////////////
#ifndef _AStar_Type1_ShaderClass_H_
#define _AStar_Type1_ShaderClass_H_


//////////////
// INCLUDES //
//////////////
#include <d3d11.h>
#include <d3dx10math.h>
#include <d3dx11async.h>
#include <fstream>
#include "ComputeShaderHelperClass.h"
#include "TextureUtility.h"

using namespace std;


////////////////////////////////////////////////////////////////////////////////
// Class name: TextureShaderClass
////////////////////////////////////////////////////////////////////////////////
class AStar_Type1_ShaderClass
{

	struct VertexType
	{
		D3DXVECTOR4 position;
	    D3DXVECTOR2 texture;
	};

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
		
		//struct Node
		//{
		//	int cost;
		//	int id;
		//};
		struct int2
		{
			int x1;
			int y1;
		};

		struct int3
		{
			int x;
			int y;
			int z;
		};
		struct int4
		{
			int x;
			int y;
			int z;
			int w;
		};

		struct Agent
		{
			int id;
			int2 sourceLoc;
			int2 targetLoc;
		};

		struct SearchResult
		{
			int agentId;
			int finalCost;
			int2 targetLoc;
		};



public:
	AStar_Type1_ShaderClass();
	AStar_Type1_ShaderClass(const AStar_Type1_ShaderClass&);
	~AStar_Type1_ShaderClass();

	bool Initialize(ID3D11Device*,ID3D11DeviceContext*, HWND);
	void Shutdown();
	bool Render(ID3D11Device* , ID3D11DeviceContext*, int, int,ID3D11Buffer*, ID3D11ShaderResourceView*);

	static CONST int NUM_ELEMENTS = 9;

private:
	bool InitializeShader(ID3D11Device*,ID3D11DeviceContext*, HWND, WCHAR*);
	bool createConstantBuffer(ID3D11Device* device,ID3D11DeviceContext*);
	bool SetShaderParameters(ID3D11DeviceContext*,  ID3D11ShaderResourceView*);
	void ShutdownShader();
//	void OutputShaderErrorMessage(ID3D10Blob*, HWND, WCHAR*);


private:
	ComputeShaderHelperClass* m_computeshader_helper;

	ID3D11ComputeShader* m_computeShader;
	
	ID3D11Buffer* m_Buffer_AgentList;
	ID3D11Buffer* m_Buffer_OpenList;
	ID3D11Buffer* m_Buffer_SearchResult;
	ID3D11Buffer* m_Buffer_GridNodeListOut;

	ID3D11ShaderResourceView*   m_BufAgentList_SRV ;
	ID3D11ShaderResourceView*	m_WorldMap_SRV;

	ID3D11UnorderedAccessView*  m_BufOpenList_URV;
	ID3D11UnorderedAccessView*  m_BufGridNodeListOut_URV;
	ID3D11UnorderedAccessView*  m_BufSearchResult_URV ;
	

	ID3D11SamplerState* m_sampleState;


	//BufType g_vBuf0[NUM_ELEMENTS];
	//BufType g_vBuf1[NUM_ELEMENTS];
};
#endif