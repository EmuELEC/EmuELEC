#if defined(VERTEX)


attribute vec4 VertexCoord;
attribute vec4 TexCoord;
varying vec4 TEX0;
uniform mat4 MVPMatrix;

void main() {
  gl_Position = VertexCoord.x*MVPMatrix[0] + VertexCoord.y*MVPMatrix[1] + VertexCoord.z*MVPMatrix[2] + VertexCoord.w*MVPMatrix[3];
  TEX0.xy = TexCoord.xy;
} 


#elif defined(FRAGMENT)


precision mediump float;

uniform sampler2D Texture;
varying vec4 TEX0;
uniform vec2 TextureSize;

void main() {

  vec3 col;
  float x = TEX0.x * TextureSize.x;
  float y = floor(gl_FragCoord.y / 3.0) + 0.5;
  float ymod = mod(gl_FragCoord.y, 3.0);
  vec2 f0 = vec2(x, y);
  vec2 uv0 = f0 / TextureSize.xy;
  vec3 t0 = texture2D(Texture, uv0).xyz;
  if (ymod > 2.0) {
    vec2 f1 = vec2(x, y + 1.0);
    vec2 uv1 = f1 / TextureSize.xy;
    vec3 t1 = texture2D(Texture, uv1).xyz;
    col = (t0 + t1) / 2.0 * 0.6;
  } else {
    col = t0;
  } 

  gl_FragColor = vec4( col, 1.0 );

}


#endif
