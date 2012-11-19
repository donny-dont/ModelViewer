part of viewer;

/// Default value for the vertex shader source.
String _defaultVertexSource =
'''
precision highp float;

// Vertex attributes
attribute vec3 vPosition;
attribute vec2 vTexCoord;

// Uniform variables
uniform mat4 objectTransform;
uniform mat4 cameraTransform;

// Varying variables
// Allows communication between vertex and fragment stages
varying vec2 samplePoint;

void main() {
    vec4 vPosition4 = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    gl_Position = (cameraTransform*objectTransform)*vPosition4;
    samplePoint = vTexCoord;
}
''';

/// Default value for the fragment shader source.
String _defaultFragmentSource =
'''
precision mediump float;

varying vec2 samplePoint;
uniform sampler2D sampler;

void main() {
    gl_FragColor = texture2D(sampler, samplePoint);
}
''';


/// Fallback vertex shader
String _fallbackVertexShader =
'''
precision highp float;

// Vertex attributes
attribute vec3 vPosition;
attribute vec2 vTexCoord;

// Uniform variables
uniform mat4 objectTransform;
uniform mat4 cameraTransform;

// Varying variables
// Allows communication between vertex and fragment stages
varying vec2 samplePoint;

void main() {
    vec4 vPosition4 = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    gl_Position = (cameraTransform*objectTransform)*vPosition4;
    samplePoint = vTexCoord;
}
''';

/// Fallback fragment shader
String _fallbackFragmentShader =
'''
precision mediump float;

void main() {
    gl_FragColor = vec4(1.0, 0.0, 1.0, 1.0);
}
''';
