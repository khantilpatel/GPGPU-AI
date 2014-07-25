
#ifndef _ComputeShaderHelperClass_H_
#define _ComputeShaderHelperClass_H_


//////////////
// INCLUDES //
//////////////
#include <d3d11.h>
#include <d3dx10math.h>
#include <d3dx11async.h>
#include <fstream>
using namespace std;


class ComputeShaderHelperClass{
	public:
	ComputeShaderHelperClass();
	~ComputeShaderHelperClass();
HRESULT CreateStructuredBuffer( ID3D11Device* pDevice, UINT uElementSize,
							   UINT uCount, void* pInitData, ID3D11Buffer** ppBufOut );


HRESULT CreateRawBuffer( ID3D11Device* pDevice, UINT uSize, void* pInitData, ID3D11Buffer** ppBufOut );


HRESULT CreateBufferSRV( ID3D11Device* pDevice, ID3D11Buffer* pBuffer, ID3D11ShaderResourceView** ppSRVOut );


HRESULT CreateBufferUAV( ID3D11Device* pDevice, ID3D11Buffer* pBuffer, ID3D11UnorderedAccessView** ppUAVOut );


ID3D11Buffer* CreateAndCopyToDebugBuf( ID3D11Device* pDevice, ID3D11DeviceContext* pd3dImmediateContext,
									  ID3D11Buffer* pBuffer );


};


#endif