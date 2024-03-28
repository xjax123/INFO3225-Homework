uniform mat4 transform;

uniform mat4 projection;
uniform mat4 modelview;
attribute vec4 position;
attribute vec4 color;
attribute vec4 normal;

out vec3 Normal;
out vec4 vertColor;
out vec3 FragPos;
void main() 
{
  gl_Position = transform * position;
  FragPos = vec3(transform*position);
  vertColor = color;
  Normal = vec3(normal);
}