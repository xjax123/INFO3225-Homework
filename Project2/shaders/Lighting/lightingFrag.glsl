uniform vec3 ambientColor;
uniform float ambientStrength;
uniform vec3 lightColor;
uniform vec3 lightDir;
uniform float specStrength;
uniform vec3 viewPos;

in vec4 vertColor;
in vec3 Normal;
in vec3 FragPos;

void main() 
{   vec3 viewDir = normalize(viewPos - FragPos);
    vec3 lcNorm = normalize(vec4(lightColor,255)).xyz;
    vec3 colorNorm = normalize(vec4(ambientColor,255)).xyz*ambientStrength;
    vec3 norm = normalize(Normal);
    vec3 lightDirNorm = normalize(lightDir);
    vec3 reflectDir = reflect(-lightDir, norm);
    float diff = max(dot(norm, lightDirNorm), 0.0);
    vec3 diffuse = diff * lcNorm;

    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
    vec3 specular = specStrength * spec * lcNorm;  

    vec4 result = vec4((colorNorm + diffuse),1) * vertColor;
    gl_FragColor = result;
}