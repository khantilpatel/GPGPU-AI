////////////////////////////////////////////////////////////////////////////////
// Filename: cameraclass.h
////////////////////////////////////////////////////////////////////////////////
#ifndef _TextureUtility_H_
#define _TextureUtility_H_



//////////////
// INCLUDES //
//////////////
#include <d3d11.h>
#include <d3dx10math.h>
#include <d3dx11async.h>
#include <fstream>
#include <xnamath.h>
#include "MathUtility.h"


////////////////////////////////////////////////////////////////////////////////
// Class name: CameraClass
////////////////////////////////////////////////////////////////////////////////
class TextureUtility
{
public:
	
	ID3D11ShaderResourceView* CreateRandomTexture1DSRV(ID3D11Device* device);

	ID3D11ShaderResourceView* CreateRandomTexture2DSRV(ID3D11Device* device, ID3D11DeviceContext* deviceContext);

	ID3D11ShaderResourceView* CreateRandomTexture2DSRV_New(ID3D11Device* device, ID3D11DeviceContext* deviceContext);

	ID3D11ShaderResourceView* CreateTextureFromFile(ID3D11Device* device, WCHAR* filename);

};


#endif