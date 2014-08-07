//--------------------------------------------------------------------------------------
// Create Structured Buffer
//--------------------------------------------------------------------------------------
#include "ComputeShaderHelperClass.h"


ComputeShaderHelperClass::ComputeShaderHelperClass()
{
}


ComputeShaderHelperClass::~ComputeShaderHelperClass()
{
}

HRESULT ComputeShaderHelperClass::CreateConstantBuffer(ID3D11Device* pDevice, UINT uElementSize, UINT uCount, void* pInitData, ID3D11Buffer** ppBufOut)
{
	*ppBufOut = nullptr;

	D3D11_BUFFER_DESC desc;
	ZeroMemory(&desc, sizeof(desc));
	desc.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
	desc.Usage = D3D11_USAGE_DYNAMIC;
	desc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
	desc.ByteWidth = uElementSize * uCount;
	desc.MiscFlags = 0;
	desc.StructureByteStride = 0;

	if (pInitData)
	{
		D3D11_SUBRESOURCE_DATA InitData;
		InitData.pSysMem = pInitData;
		return pDevice->CreateBuffer(&desc, &InitData, ppBufOut);
	}
	else
		return pDevice->CreateBuffer(&desc, nullptr, ppBufOut);
}
HRESULT ComputeShaderHelperClass::CreateStructuredBuffer( ID3D11Device* pDevice, UINT uElementSize, UINT uCount, void* pInitData, ID3D11Buffer** ppBufOut )
{
	*ppBufOut = nullptr;

	D3D11_BUFFER_DESC desc;
	ZeroMemory( &desc, sizeof(desc) );
	desc.BindFlags = D3D11_BIND_UNORDERED_ACCESS | D3D11_BIND_SHADER_RESOURCE;
	desc.ByteWidth = uElementSize * uCount;
	desc.MiscFlags = D3D11_RESOURCE_MISC_BUFFER_STRUCTURED;
	desc.StructureByteStride = uElementSize;

	if ( pInitData )
	{
		D3D11_SUBRESOURCE_DATA InitData;
		InitData.pSysMem = pInitData;
		return pDevice->CreateBuffer( &desc, &InitData, ppBufOut );
	} else
		return pDevice->CreateBuffer( &desc, nullptr, ppBufOut );
}


//--------------------------------------------------------------------------------------
// Create Raw Buffer
//--------------------------------------------------------------------------------------
HRESULT ComputeShaderHelperClass::CreateRawBuffer( ID3D11Device* pDevice, UINT uSize, void* pInitData, ID3D11Buffer** ppBufOut )
{
	*ppBufOut = nullptr;

	D3D11_BUFFER_DESC desc;
	ZeroMemory( &desc, sizeof(desc) );
	desc.BindFlags = D3D11_BIND_UNORDERED_ACCESS | D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_INDEX_BUFFER | D3D11_BIND_VERTEX_BUFFER;
	desc.ByteWidth = uSize;
	desc.MiscFlags = D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS;

	if ( pInitData )
	{
		D3D11_SUBRESOURCE_DATA InitData;
		InitData.pSysMem = pInitData;
		return pDevice->CreateBuffer( &desc, &InitData, ppBufOut );
	} else
		return pDevice->CreateBuffer( &desc, nullptr, ppBufOut );
}


//ID3D11ShaderResourceView* ComputeShaderHelperClass::CreateTexture2DSRV(ID3D11Device* device, ID3D11DeviceContext* deviceContext, UINT uSize,  void* pInitData, ID3D11Buffer** ppBufOut )
//{
//	HRESULT result;
//
//	const int WALKABLE_NODE  = 0;
//	const int COLLISION_NODE = 1;
//	// 
//	// Create the random data.
//	//
//	XMFLOAT4 randomValues[DATA_SIZE];
//	int counter=0;
//	for(int i = 0; i < DATA_SIZE_BLOCK; i++)
//	{
//		for(int j = 0; j < DATA_SIZE_BLOCK; j++){
//
//			randomValues[counter].x = j;	//MathUtility::RandF(-1.0f, 100.0f);
//			randomValues[counter].y = i;	//MathUtility::RandF(-1.0f, 100.0f);
//			randomValues[counter].z = 0;	//MathUtility::RandF(-1.0f, 9.0f);
//			randomValues[counter].w = counter;	//MathUtility::RandF(-1.0f, 50.0f);
//			counter = counter+1;
//		}
//	}
//
//	// Setup Collision Nodes 
//	randomValues[20].z = COLLISION_NODE;
//	randomValues[28].z = COLLISION_NODE;
//	randomValues[36].z = COLLISION_NODE;
//	randomValues[45].z = COLLISION_NODE;
//	randomValues[53].z = COLLISION_NODE;
//
//    D3D11_SUBRESOURCE_DATA initData;
//    initData.pSysMem = randomValues;
//	initData.SysMemPitch = DATA_SIZE*sizeof(XMFLOAT4);
//    initData.SysMemSlicePitch = 0;
//
//	//
//	// Create the texture.
//	//
//		D3D11_TEXTURE2D_DESC desc;
//		ZeroMemory( &desc, sizeof(desc) );
//		desc.Width = DATA_SIZE_BLOCK;
//		desc.Height = DATA_SIZE_BLOCK;
//		desc.MipLevels = desc.ArraySize = 1;
//		desc.Format = DXGI_FORMAT_R32G32B32A32_FLOAT;
//		desc.SampleDesc.Count = 1;
//		desc.Usage = D3D11_USAGE_DYNAMIC;
//		desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
//		desc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
//		ID3D11Texture2D *pTexture = NULL;
//		device->CreateTexture2D( &desc, NULL, &pTexture );
//
//	D3D11_MAPPED_SUBRESOURCE mappedResource;
//
//	deviceContext->Map(pTexture, 0, D3D11_MAP_WRITE_DISCARD, 0, &mappedResource);
//	memcpy(mappedResource.pData, randomValues, sizeof(randomValues));
//	deviceContext->Unmap(pTexture, 0);
//	//
//	// Create the resource view.
//	//
//
//	D3D11_SHADER_RESOURCE_VIEW_DESC srDesc;
//	srDesc.Format = desc.Format;
//	srDesc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2D;
//	srDesc.Texture2D.MostDetailedMip = 0;
//	srDesc.Texture2D.MipLevels = 1;
//
//	ID3D11ShaderResourceView *pShaderResView = NULL;
//	device->CreateShaderResourceView( pTexture, &srDesc, &pShaderResView );
//
//	pTexture->Release();
//
//	return pShaderResView;
//}

//--------------------------------------------------------------------------------------
// Create Shader Resource View for Structured or Raw Buffers
//--------------------------------------------------------------------------------------
HRESULT ComputeShaderHelperClass::CreateBufferSRV( ID3D11Device* pDevice, ID3D11Buffer* pBuffer, ID3D11ShaderResourceView** ppSRVOut )
{
	D3D11_BUFFER_DESC descBuf;
	ZeroMemory( &descBuf, sizeof(descBuf) );
	pBuffer->GetDesc( &descBuf );

	D3D11_SHADER_RESOURCE_VIEW_DESC desc;
	ZeroMemory( &desc, sizeof(desc) );
	desc.ViewDimension = D3D11_SRV_DIMENSION_BUFFEREX;
	desc.BufferEx.FirstElement = 0;

	if ( descBuf.MiscFlags & D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS )
	{
		// This is a Raw Buffer

		desc.Format = DXGI_FORMAT_R32_TYPELESS;
		desc.BufferEx.Flags = D3D11_BUFFEREX_SRV_FLAG_RAW;
		desc.BufferEx.NumElements = descBuf.ByteWidth / 4;
	} else
		if ( descBuf.MiscFlags & D3D11_RESOURCE_MISC_BUFFER_STRUCTURED )
		{
			// This is a Structured Buffer

			desc.Format = DXGI_FORMAT_UNKNOWN;
			desc.BufferEx.NumElements = descBuf.ByteWidth / descBuf.StructureByteStride;
		} else
		{
			return E_INVALIDARG;
		}

		return pDevice->CreateShaderResourceView( pBuffer, &desc, ppSRVOut );
}

//--------------------------------------------------------------------------------------
// Create Unordered Access View for Structured or Raw Buffers
//-------------------------------------------------------------------------------------- 
HRESULT ComputeShaderHelperClass::CreateBufferUAV( ID3D11Device* pDevice, ID3D11Buffer* pBuffer, ID3D11UnorderedAccessView** ppUAVOut )
{
	D3D11_BUFFER_DESC descBuf;
	ZeroMemory( &descBuf, sizeof(descBuf) );
	pBuffer->GetDesc( &descBuf );

	D3D11_UNORDERED_ACCESS_VIEW_DESC desc;
	ZeroMemory( &desc, sizeof(desc) );
	desc.ViewDimension = D3D11_UAV_DIMENSION_BUFFER;
	desc.Buffer.FirstElement = 0;

	if ( descBuf.MiscFlags & D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS )
	{
		// This is a Raw Buffer

		desc.Format = DXGI_FORMAT_R32_TYPELESS; // Format must be DXGI_FORMAT_R32_TYPELESS, when creating Raw Unordered Access View
		desc.Buffer.Flags = D3D11_BUFFER_UAV_FLAG_RAW;
		desc.Buffer.NumElements = descBuf.ByteWidth / 4; 
	} else
		if ( descBuf.MiscFlags & D3D11_RESOURCE_MISC_BUFFER_STRUCTURED )
		{
			// This is a Structured Buffer

			desc.Format = DXGI_FORMAT_UNKNOWN;      // Format must be must be DXGI_FORMAT_UNKNOWN, when creating a View of a Structured Buffer
			desc.Buffer.NumElements = descBuf.ByteWidth / descBuf.StructureByteStride; 
		} else
		{
			return E_INVALIDARG;
		}

		return pDevice->CreateUnorderedAccessView( pBuffer, &desc, ppUAVOut );
}



//--------------------------------------------------------------------------------------
// Create a CPU accessible buffer and download the content of a GPU buffer into it
// This function is very useful for debugging CS programs
//-------------------------------------------------------------------------------------- 
ID3D11Buffer* ComputeShaderHelperClass::CreateAndCopyToDebugBuf( ID3D11Device* pDevice, ID3D11DeviceContext* pd3dImmediateContext, ID3D11Buffer* pBuffer )
{
	ID3D11Buffer* debugbuf = nullptr;

	D3D11_BUFFER_DESC desc;
	ZeroMemory( &desc, sizeof(desc) );
	pBuffer->GetDesc( &desc );
	desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
	desc.Usage = D3D11_USAGE_STAGING;
	desc.BindFlags = 0;
	desc.MiscFlags = 0;
	if ( SUCCEEDED(pDevice->CreateBuffer(&desc, nullptr, &debugbuf)) )
	{
#if defined(DEBUG) || defined(PROFILE)
		debugbuf->SetPrivateData( WKPDID_D3DDebugObjectName, sizeof( "Debug" ) - 1, "Debug" );
#endif

		pd3dImmediateContext->CopyResource( debugbuf, pBuffer );
	}

	return debugbuf;
}