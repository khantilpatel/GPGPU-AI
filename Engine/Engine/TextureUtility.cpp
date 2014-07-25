#include "TextureUtility.h"

using namespace std;


ID3D11ShaderResourceView* TextureUtility::CreateRandomTexture1DSRV(ID3D11Device* device)
{
	HRESULT result;
	// 
	// Create the random data.
	//
	XMFLOAT4 randomValues[1024];

	for(int i = 0; i < 1024; ++i)
	{
		randomValues[i].x = MathUtility::RandF(-1.0f, 100.0f);
		randomValues[i].y = MathUtility::RandF(-1.0f, 100.0f);
		randomValues[i].z =  MathUtility::RandF(-1.0f, 9.0f);
		randomValues[i].w = MathUtility::RandF(-1.0f, 50.0f);
	}

    D3D11_SUBRESOURCE_DATA initData;
    initData.pSysMem = randomValues;
	initData.SysMemPitch = 1024*sizeof(XMFLOAT4);
    initData.SysMemSlicePitch = 0;

	//
	// Create the texture.
	//
    D3D11_TEXTURE1D_DESC texDesc;
    texDesc.Width = 1024;
    texDesc.MipLevels = 1;
    texDesc.Format = DXGI_FORMAT_R32G32B32A32_FLOAT;
    texDesc.Usage = D3D11_USAGE_IMMUTABLE;
    texDesc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
    texDesc.CPUAccessFlags = 0;
    texDesc.MiscFlags = 0;
    texDesc.ArraySize = 1;

	ID3D11Texture1D* randomTex = 0;
    device->CreateTexture1D(&texDesc, &initData, &randomTex);

	//
	// Create the resource view.
	//
    D3D11_SHADER_RESOURCE_VIEW_DESC viewDesc;
	viewDesc.Format = texDesc.Format;
    viewDesc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE1D;
    viewDesc.Texture1D.MipLevels = texDesc.MipLevels;
	viewDesc.Texture1D.MostDetailedMip = 0;
	
	ID3D11ShaderResourceView* randomTexSRV = 0;
	 device->CreateShaderResourceView(randomTex, &viewDesc, &randomTexSRV);


	randomTex->Release();

	return randomTexSRV;
}

ID3D11ShaderResourceView* TextureUtility::CreateRandomTexture2DSRV_New(ID3D11Device* device, ID3D11DeviceContext* deviceContext)
{
	HRESULT result;

	const int DATA_SIZE = 16384;
	const int DATA_SIZE_BLOCK = 128;
	// 
	// Create the random data.
	//
	XMFLOAT4 randomValues[DATA_SIZE];
	int counter=0;
	for(int i = 0; i < DATA_SIZE_BLOCK; i++)
	{
		for(int j = 0; j < DATA_SIZE_BLOCK; j++){

			randomValues[counter].x = j;	//MathUtility::RandF(-1.0f, 100.0f);
			randomValues[counter].y = i;	//MathUtility::RandF(-1.0f, 100.0f);
			randomValues[counter].z = counter;	//MathUtility::RandF(-1.0f, 9.0f);
			randomValues[counter].w = counter;	//MathUtility::RandF(-1.0f, 50.0f);
			counter = counter+1;
		}
	}

    D3D11_SUBRESOURCE_DATA initData;
    initData.pSysMem = randomValues;
	initData.SysMemPitch = DATA_SIZE*sizeof(XMFLOAT4);
    initData.SysMemSlicePitch = 0;

	//
	// Create the texture.
	//
		D3D11_TEXTURE2D_DESC desc;
		ZeroMemory( &desc, sizeof(desc) );
		desc.Width = DATA_SIZE_BLOCK;
		desc.Height = DATA_SIZE_BLOCK;
		desc.MipLevels = desc.ArraySize = 1;
		desc.Format = DXGI_FORMAT_R32G32B32A32_FLOAT;
		desc.SampleDesc.Count = 1;
		desc.Usage = D3D11_USAGE_DYNAMIC;
		desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
		desc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
		ID3D11Texture2D *pTexture = NULL;
		device->CreateTexture2D( &desc, NULL, &pTexture );

	D3D11_MAPPED_SUBRESOURCE mappedResource;

	deviceContext->Map(pTexture, 0, D3D11_MAP_WRITE_DISCARD, 0, &mappedResource);
	memcpy(mappedResource.pData, randomValues, sizeof(randomValues));
	deviceContext->Unmap(pTexture, 0);
	//
	// Create the resource view.
	//

	D3D11_SHADER_RESOURCE_VIEW_DESC srDesc;
	srDesc.Format = desc.Format;
	srDesc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2D;
	srDesc.Texture2D.MostDetailedMip = 0;
	srDesc.Texture2D.MipLevels = 1;

	ID3D11ShaderResourceView *pShaderResView = NULL;
	device->CreateShaderResourceView( pTexture, &srDesc, &pShaderResView );

	pTexture->Release();

	return pShaderResView;
}


ID3D11ShaderResourceView* TextureUtility::CreateRandomTexture2DSRV(ID3D11Device* device, ID3D11DeviceContext* deviceContext)
{

	HRESULT result;

	//const int dimensions = 10;
	//// 
	//// Create the random data.
	////
	//XMFLOAT4 randomValues[dimensions][dimensions];

	//for(int i = 0; i < dimensions; i++)
	//{
	//	for(int j = 0; j < dimensions; j++){
	//		randomValues[i][j] =  XMFLOAT4(i,j, 3.0,0.0);	
	//	}
	//}

	//randomValues[0][0] =  XMFLOAT4(0.0,0.0,0.0,0.0);	

	//randomValues[1][1] =  XMFLOAT4(1.0,1.0,0.0,0.0);	
	//randomValues[2][2] =  XMFLOAT4(2.0,2.0,0.0,0.0);

	//int sizeTest = sizeof(randomValues);

	//D3D11_SUBRESOURCE_DATA initData;
	//initData.pSysMem = randomValues;
	//initData.SysMemPitch = (dimensions *dimensions)*sizeof(XMFLOAT4);
	//initData.SysMemSlicePitch = 0;

	////D3D11_SUBRESOURCE_DATA *sSubData = new D3D11_SUBRESOURCE_DATA[10];
	////for(int i=0; i<10; i++) {
	////	sSubData[i].pSysMem = randomValues;
	////	sSubData[i].SysMemPitch = (dimensions)*sizeof(XMFLOAT4);
	////	sSubData[i].SysMemSlicePitch = 0;
	////}

	////
	//// Create the texture.
	////
	//D3D11_TEXTURE2D_DESC texDesc;
	//ZeroMemory( &texDesc, sizeof( texDesc ) );
	//texDesc.Height = dimensions;
	//texDesc.Width = dimensions;
	//texDesc.SampleDesc.Count = 1;
	//texDesc.SampleDesc.Quality = 0;
	//texDesc.MipLevels = 1;
	//texDesc.Format = DXGI_FORMAT_R32G32B32A32_FLOAT;
	//texDesc.Usage = D3D11_USAGE_IMMUTABLE;
	//texDesc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
	//texDesc.CPUAccessFlags = 0;
	//texDesc.MiscFlags = 0;
	//texDesc.ArraySize = 1;
	////XMFLOAT4 randomValues[100] = 	randomValues[2];


	//ID3D11Texture2D* randomTex = 0;	
	//device->CreateTexture2D(&texDesc, &initData, &randomTex);

	//	//
	//// Create the resource view.
	////
	//D3D11_SHADER_RESOURCE_VIEW_DESC viewDesc;
	//viewDesc.Format = texDesc.Format;
	//viewDesc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2D;
	//viewDesc.Texture2D.MipLevels = texDesc.MipLevels;
	//viewDesc.Texture2D.MostDetailedMip = 0;

	//ID3D11ShaderResourceView* randomTexSRV = 0;
	//device->CreateShaderResourceView(randomTex, &viewDesc, &randomTexSRV);
	//randomTex->Release();

	///////////////////////////////////////////////////////////////////////////////////
	/// New stuff goes here

		D3D11_TEXTURE2D_DESC desc;
		ZeroMemory( &desc, sizeof(desc) );
		desc.Width = 256;
		desc.Height = 256;
		desc.MipLevels = desc.ArraySize = 1;
		desc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
		desc.SampleDesc.Count = 1;
		desc.Usage = D3D11_USAGE_DYNAMIC;
		desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
		desc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
		ID3D11Texture2D *pTexture = NULL;
		device->CreateTexture2D( &desc, NULL, &pTexture );

	D3D11_MAPPED_SUBRESOURCE mappedResource;

	deviceContext->Map(pTexture, 0, D3D11_MAP_WRITE_DISCARD, 0, &mappedResource);
	//	Update the vertex buffer here.
	//memcpy(mappedResource.pData, vertices, sizeof(vertices));
	//	Reenable GPU access to the vertex buffer data.

			UCHAR* pTexels = (UCHAR*)mappedResource.pData;
			for( UINT row = 0; row < desc.Height; row++ )
			{
				UINT rowStart = row * mappedResource.RowPitch;
				for( UINT col = 0; col < desc.Width; col++ )
				{
					UINT colStart = col * 4;
					pTexels[rowStart + colStart + 0] = 255; // Red
					pTexels[rowStart + colStart + 1] = 128; // Green
					pTexels[rowStart + colStart + 2] = 64;  // Blue
					pTexels[rowStart + colStart + 3] = 32;  // Alpha
				}
			}
	deviceContext->Unmap(pTexture, 0);

	
	D3D11_SHADER_RESOURCE_VIEW_DESC srDesc;
	srDesc.Format = desc.Format;
	srDesc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2D;
	srDesc.Texture2D.MostDetailedMip = 0;
	srDesc.Texture2D.MipLevels = 1;

	ID3D11ShaderResourceView *pShaderResView = NULL;
	device->CreateShaderResourceView( pTexture, &srDesc, &pShaderResView );

	pTexture->Release();

	return pShaderResView;
}

ID3D11ShaderResourceView* TextureUtility::CreateTextureFromFile(ID3D11Device* device, WCHAR* filename)
{
	HRESULT result;

	ID3D11ShaderResourceView* texture = 0;

	// Load the texture in.
	result = D3DX11CreateShaderResourceViewFromFile(device, filename, NULL, NULL, &texture, NULL);
	if(FAILED(result))
	{
		return false;
	}

	return texture;
}
