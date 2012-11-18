part of viewer;

String _newFileState =
'''
{
  "blendState": {
    "blendAlphaOp": "BlendOpAdd",
    "writeRenderTargetRed": true,
    "writeRenderTargetBlue": true,
    "writeRenderTargetGreen": true,
    "blendSourceAlphaFunc": "BlendSourceShaderAlpha",
    "blendDestColorFunc": "BlendSourceShaderInverseAlpha",
    "writeRenderTargetAlpha": true,
    "blendEnable": true,
    "blendSourceColorFunc": "BlendSourceShaderAlpha",
    "blendDestAlphaFunc": "BlendSourceShaderInverseAlpha",
    "blendColorOp": "BlendOpAdd"
  },
  "rasterizerState": {
    "cullEnabled": true,
    "cullMode": "CullBack",
    "cullFrontFace": "FrontCCW"
  },
  "depthState": {
    "depthWriteEnabled": false,
    "depthTestEnabled": true,
    "depthComparisonOp": "DepthComparisonOpLess"
  }
}
''';
