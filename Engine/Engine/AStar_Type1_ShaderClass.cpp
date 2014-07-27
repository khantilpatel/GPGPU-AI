////////////////////////////////////////////////////////////////////////////////
// Filename: MatrixMultiplyShaderClass.cpp
////////////////////////////////////////////////////////////////////////////////
#include "AStar_Type1_ShaderClass.h"


AStar_Type1_ShaderClass::AStar_Type1_ShaderClass()
{
	m_computeshader_helper = 0;
	m_computeShader = 0;

	m_Buffer_AgentList = 0;
	m_Buffer_SearchResult= 0;

	m_BufAgentList_SRV = 0;
	m_BufSearchResult_SRV= 0;

	m_computeshader_helper = new ComputeShaderHelperClass;
}

AStar_Type1_ShaderClass::AStar_Type1_ShaderClass(const AStar_Type1_ShaderClass& other)
{
}

AStar_Type1_ShaderClass::~AStar_Type1_ShaderClass()
{
}

bool AStar_Type1_ShaderClass::Initialize(ID3D11Device* device, ID3D11DeviceContext* deviceContext, HWND hwnd)
{
	bool result;


	// Initialize the vertex and pixel shaders.
	result = InitializeShader(device, deviceContext, hwnd, L"AStar_Type1_ComputeShader.hlsl");
	if(!result)
	{
		return false;
	}

	return true;
}

///////////////////////////////////////////////////////////////
///////TASKS//////////////////////////////////////////////////
// 1. Comple shader and create the shader instance
// 2. Define Input layout for the vertex shader, vertex buffer data.
// 3. Initiate the Constant shader variable buffer and texture buffers.
////////////////////////////////////////////////////////////////////
bool AStar_Type1_ShaderClass::InitializeShader(ID3D11Device* device,ID3D11DeviceContext* deviceContext, HWND hwnd, WCHAR* csFilename)
{
	HRESULT result;
	ID3D10Blob* errorMessage;
	ID3D10Blob* computeShaderBuffer;

	// Initialize the pointers this function will use to null.
	errorMessage = 0;
	computeShaderBuffer = 0;

	// Compile the vertex shader code.
	result = D3DX11CompileFromFile(csFilename, NULL, NULL, "main", "cs_5_0", D3D10_SHADER_ENABLE_STRICTNESS, 0, NULL, 
		&computeShaderBuffer, &errorMessage, NULL);
	if(FAILED(result))
	{
		// If the shader failed to compile it should have writen something to the error message.
		if(errorMessage)
		{
		//	OutputShaderErrorMessage(errorMessage, hwnd, csFilename);

					char* compileErrors;
			unsigned long bufferSize, i;
			ofstream fout;


			// Get a pointer to the error message text buffer.
			compileErrors = (char*)(errorMessage->GetBufferPointer());

			// Get the length of the message.
			bufferSize = errorMessage->GetBufferSize();

			// Open a file to write the error message to.
			fout.open("shader-error.txt");

			// Write out the error message.
			for(i=0; i<bufferSize; i++)
			{
				fout << compileErrors[i];
			}

			// Close the file.
			fout.close();

			// Release the error message.
			errorMessage->Release();
			errorMessage = 0;
		}
		// If there was nothing in the error message then it simply could not find the shader file itself.
		else
		{
			MessageBox(hwnd, csFilename, L"Missing Shader File", MB_OK);
		}
		return false;
	}

	// Create the vertex shader from the buffer.
	result = device->CreateComputeShader(computeShaderBuffer->GetBufferPointer(), computeShaderBuffer->GetBufferSize(),
		NULL, &m_computeShader);
	if(FAILED(result))
	{
		return false;
	}

	// Release the vertex shader buffer and pixel shader buffer since they are no longer needed.
	computeShaderBuffer->Release();
	computeShaderBuffer = 0;


	result = createConstantBuffer(device, deviceContext );
	if(FAILED(result))
	{
		return false;
	}

	return true;
}

bool AStar_Type1_ShaderClass::createConstantBuffer(ID3D11Device* device, ID3D11DeviceContext* deviceContext)
{

	//for ( int i = 0; i < NUM_ELEMENTS; ++i ) 
	//{
	//	// g_vBuf0[i] = i;
	//	g_vBuf0[i].f = (float)i;

	//	g_vBuf1[i].f = (float)i;
	//}
	Agent agentList[1];

	Agent a1;

	a1.id =1 ;
	a1.sourceLoc = XMFLOAT2(1,4);
	a1.targetLoc = XMFLOAT2(6,4);
	agentList[0] = a1 ;

	int NUM_AGENTS = 1;
	int NUM_SEARCH_RESULTS = 10;

	m_computeshader_helper->CreateStructuredBuffer( device, sizeof(Agent), NUM_AGENTS, &agentList, &m_Buffer_AgentList );
	//m_computeshader_helper->CreateStructuredBuffer( device, sizeof(BufType), NUM_ELEMENTS, &g_vBuf1[0], &m_matrixBuffer_B);
	m_computeshader_helper->CreateStructuredBuffer( device, sizeof(SearchResult), NUM_SEARCH_RESULTS, nullptr, &m_Buffer_SearchResult );


	m_computeshader_helper->CreateBufferSRV( device, m_Buffer_AgentList, &m_BufAgentList_SRV );
	//m_computeshader_helper->CreateBufferSRV( device, m_matrixBuffer_B, &m_BufMatB_SRV );
	m_computeshader_helper->CreateBufferUAV( device, m_Buffer_SearchResult, &m_BufSearchResult_SRV );

	TextureUtility* m_TextureUtility = new TextureUtility;

	m_WorldMap_SRV = m_TextureUtility->CreateRandomTexture2DSRV_New(device,deviceContext);//,deviceContext);


	D3D11_SAMPLER_DESC samplerDesc;
		// Create a texture sampler state description.
	samplerDesc.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
	samplerDesc.AddressU = D3D11_TEXTURE_ADDRESS_WRAP;
	samplerDesc.AddressV = D3D11_TEXTURE_ADDRESS_WRAP;
	samplerDesc.AddressW = D3D11_TEXTURE_ADDRESS_WRAP;
	samplerDesc.MipLODBias = 0.0f;
	samplerDesc.MaxAnisotropy = 1;
	samplerDesc.ComparisonFunc = D3D11_COMPARISON_ALWAYS;
	samplerDesc.BorderColor[0] = 0;
	samplerDesc.BorderColor[1] = 0;
	samplerDesc.BorderColor[2] = 0;
	samplerDesc.BorderColor[3] = 0;
	samplerDesc.MinLOD = 0;
	samplerDesc.MaxLOD = D3D11_FLOAT32_MAX;

	HRESULT result ;
	// Create the texture sampler state.
	result = device->CreateSamplerState(&samplerDesc, &m_sampleState);
	if(FAILED(result))
	{
		return false;
	}

	return true;

}


bool AStar_Type1_ShaderClass::Render(ID3D11Device* device, ID3D11DeviceContext* deviceContext, int vertexCount, int instanceCount,	
									   ID3D11Buffer* m_StreamOutBuffer, ID3D11ShaderResourceView* texture)
{
	bool result;
	UINT X =1;
	UINT Y =1;
	UINT Z =1;

	// Set the shader parameters that it will use for rendering.
	//result = SetShaderParameters(deviceContext, texture);
	//if(!result)
	//{
	//	return false;
	//}
	ID3D11ShaderResourceView* aRViews[2] = { m_BufAgentList_SRV, m_WorldMap_SRV };
	// Now render the prepared buffers with the shader.
	deviceContext->CSSetShader( m_computeShader, nullptr, 0 );
	deviceContext->CSSetShaderResources( 0, 2, aRViews );
	deviceContext->CSSetUnorderedAccessViews( 0, 1, &m_BufSearchResult_SRV, nullptr );
	//if ( pCBCS && pCSData )
	//{
	//    D3D11_MAPPED_SUBRESOURCE MappedResource;
	//    deviceContext->Map( pCBCS, 0, D3D11_MAP_WRITE_DISCARD, 0, &MappedResource );
	//    memcpy( MappedResource.pData, pCSData, dwNumDataBytes );
	//    deviceContext->Unmap( pCBCS, 0 );
	//    ID3D11Buffer* ppCB[1] = { pCBCS };
	//    deviceContext->CSSetConstantBuffers( 0, 1, ppCB );
	//}
	
	//deviceContext->CSSetSamplers(0,1, &m_sampleState);
	deviceContext->Dispatch( X, Y, Z );

	deviceContext->CSSetShader( nullptr, nullptr, 0 );

	ID3D11UnorderedAccessView* ppUAViewnullptr[1] = { nullptr };
	deviceContext->CSSetUnorderedAccessViews( 0, 1, ppUAViewnullptr, nullptr );

	ID3D11ShaderResourceView* ppSRVnullptr[2] = { nullptr, nullptr };
	deviceContext->CSSetShaderResources( 0, 2, ppSRVnullptr );

	ID3D11Buffer* ppCBnullptr[1] = { nullptr };
	deviceContext->CSSetConstantBuffers( 0, 1, ppCBnullptr );

	ID3D11Buffer* debugbuf = m_computeshader_helper->CreateAndCopyToDebugBuf( device, deviceContext, m_Buffer_SearchResult );
	D3D11_MAPPED_SUBRESOURCE MappedResource; 
	SearchResult *p;
	deviceContext->Map( debugbuf, 0, D3D11_MAP_READ, 0, &MappedResource );

	// Set a break point here and put down the expression "p, 1024" in your watch window to see what has been written out by our CS
	// This is also a common trick to debug CS programs.
	p = (SearchResult*)MappedResource.pData;

	SearchResult nodes[20];
	for (int i = 0; i <=20; i++)

	{
		nodes[i] = p[i];		
	}

//	 Verify that if Compute Shader has done right
	printf( "Verifying against CPU result..." );
	//bool bSuccess = true;
	//for ( int i = 0; i < NUM_ELEMENTS; ++i )
	//{
	//	//std::cout<< p[i].f;
	//}

	//	deviceContext->Unmap( debugbuf, 0 );

	//	debugbuf->Release();
	//	debugbuf = 0;
		return true;
}

bool AStar_Type1_ShaderClass::SetShaderParameters(ID3D11DeviceContext* deviceContext,  ID3D11ShaderResourceView* texture)
{
	return true;
}

void AStar_Type1_ShaderClass::Shutdown()
{
	// Shutdown the vertex and pixel shaders as well as the related objects.
	ShutdownShader();

	return;
}

void AStar_Type1_ShaderClass::ShutdownShader()
{
	// Release the sampler state.
	if(m_Buffer_AgentList)
	{
		m_Buffer_AgentList->Release();
		m_Buffer_AgentList = 0;
	}

	if(m_Buffer_SearchResult)
	{
		m_Buffer_SearchResult->Release();
		m_Buffer_SearchResult = 0;
	}

	// Release the layout.
	if(m_computeShader)
	{
		m_computeShader->Release();
		m_computeShader = 0;
	}

	// Release the pixel shader.
	if(m_BufAgentList_SRV)
	{
		m_BufAgentList_SRV->Release();
		m_BufAgentList_SRV = 0;
	}

	// Release the vertex shader.
	if(m_BufSearchResult_SRV)
	{
		m_BufSearchResult_SRV->Release();
		m_BufSearchResult_SRV = 0;
	}


	return;
}