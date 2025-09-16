#if defined(VERTEX)


attribute vec4 VertexCoord;
attribute vec4 TexCoord;
varying vec4 TEX0;
uniform mat4 MVPMatrix;

void main() {
  gl_Position = MVPMatrix * VertexCoord;
  TEX0.xy = TexCoord.xy;
}


#elif defined(FRAGMENT)


precision mediump float;

uniform sampler2D Texture;
varying vec4 TEX0;
uniform vec2 TextureSize;
uniform vec2 InputSize;

void main() {
  vec3 col;
  if (InputSize.y > 220.0 && InputSize.y < 242.0) {
    float x = TEX0.x;
    float y = TEX0.y + (0.25 / TextureSize.y);
    col = texture2D(Texture, vec2(x, y)).xyz;
      float texel_y = TEX0.y * TextureSize.y * 3.0;
    float ymod = mod(texel_y, 3.0);
    if (ymod >= 1.5) {
      col = col * 0.6;
    }
  } else {
    col = texture2D(Texture, TEX0.xy).xyz;
  }

  gl_FragColor = vec4( col, 1.0 );

}


#endif
