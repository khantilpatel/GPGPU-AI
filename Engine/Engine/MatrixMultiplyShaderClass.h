////////////////////////////////////////////////////////////////////////////////
// Filename: MatrixMultiplyShaderClass.h
////////////////////////////////////////////////////////////////////////////////
#ifndef _MatrixMultiplyShaderClass_H_
#define _MatrixMultiplyShaderClass_H_


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
class MatrixMultiplyShaderClass
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
		
		struct Node
		{
			int cost;
			int id;
		};
public:
	MatrixMultiplyShaderClass();
	MatrixMultiplyShaderClass(const MatrixMultiplyShaderClass&);
	~MatrixMultiplyShaderClass();

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
	
	ID3D11Buffer* m_matrixBuffer_A;
	ID3D11Buffer* m_matrixBuffer_B;
	ID3D11Buffer* m_matrixBuffer_result;



	ID3D11ShaderResourceView*   m_BufMatA_SRV ;
	ID3D11ShaderResourceView*   m_BufMatB_SRV ;
	ID3D11ShaderResourceView*	m_WorldMap_SRV;
	ID3D11SamplerState* m_sampleState;
	ID3D11UnorderedAccessView*  m_BufResult_SRV ;


	BufType g_vBuf0[NUM_ELEMENTS];
	BufType g_vBuf1[NUM_ELEMENTS];
};
#endif