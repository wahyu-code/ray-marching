#version 330 core
out vec4 f_color;
in vec3 vColor;
uniform float iTime;

float opUnion(float d1,float d2){
    return min(d1,d2);
}
float opSub(float d1,float d2){
    return max(-d1,d2);
}
float opInstersection(float d1,float d2){
    return max(d1,d2);
}
float opUnionSmooth(float d1,float d2,float k){
    float h= clamp(0.5+0.5*(d2-d1)/k,0,1);
    float r=mix(d2,d1,h)-k*h*(1-h);
    return r;
}
float opSubSmooth(float d1,float d2,float k){
    float h= clamp(0.5-0.5*(d2+d1)/k,0,1);
    float r=mix(d2,-d1,h)+k*h*(1-h);
    return r;
}
float opInstersectionSmooth(float d1,float d2,float k){
      float h= clamp(0.5-0.5*(d2-d1)/k,0,1);
    float r=mix(d2,d1,h)-k*h*(1-h);
    return r;
}

float sphere(vec3 p, vec3 c, float r){
    return length(p-c)-r;
}
float plane(vec3 p,vec3 n,float d){
    return dot(normalize(n),p)+d;
}
float box(vec3 p,vec3 size){
    vec3 q =abs(p)-(size);
    return length(max(q,0))+min(max(q.x,max(q.y,q.z)),0);
}
float roundBox(vec3 p,vec3 size,float r){
    vec3 q=abs(p)-size+r;
    return length(max(q,0))+min(max(q.x,max(q.y,q.z)),0)-r;

}
// float octahedrom(vec3 p,float s)

float cylinder(vec3 p,float h,float r){
    vec2 d=abs(vec2(length(p.xz),p.y))-vec2(r,h);
    return min(max(d.x,d.y),0)+length(max(d,0));
}
void rotate(inout vec3 v,float rx,float ry,float rz){
    float xsin=sin(rx);
    float xcos=cos(rx);

    float ysin=sin(ry);
    float ycos=cos(ry);

    float zsin=sin(rz);
    float zcos=cos(rz);
    
    mat3 mry=mat3(ycos,0,ysin,
                    0,1,0,
                    -ysin,0,ycos);
    mat3 mrx=mat3(1,0,0,
                0,xcos,xsin,
                0,-xsin,xcos);
    mat3 mrz=mat3(zcos,zsin,0,
            -zsin,zcos,0,
            0,0,1);
    
    v=(mrz*mry*mrx)*v;
}
vec3 rotatex(in vec3 v,float theta){
    float xsin=sin(theta);
    float xcos=cos(theta);
    mat3 mrx=mat3(1,0,0,
                0,xcos,xsin,
                0,-xsin,xcos);
   return mrx*v;
}
vec3 rotatey(in vec3 v,float theta){
    float ysin=sin(theta);
    float ycos=cos(theta);
    mat3 mry=mat3(ycos,0,ysin,
                    0,1,0,
                    -ysin,0,ycos);
    return mry*v;
}
vec3 rotatez(inout vec3 v,float theta){
    float zsin=sin(theta);
    float zcos=cos(theta);
    mat3 mrz=mat3(zcos,zsin,0,
            -zsin,zcos,0,
            0,0,1);
    return mrz*v;
}
float myShape(vec3 p,vec3 cord,float sqSize,float rx,float ry,float rz){
    float final;
    float deg=22/7;
    deg=deg/2;
    vec3 position=p-cord;
    position=rotatey(position,ry);
    position=rotatex(position,rx);
    position=rotatez(position,rz);
    vec3 box_rel_p=position;
    vec3 cylinder_rel=position;
    vec3 cylinder_rel2=position;
    vec3 cylinder_rel3=position;
    cylinder_rel2=rotatex(cylinder_rel2,deg);    
    cylinder_rel3=rotatez(cylinder_rel3,deg);

    float box1=roundBox(box_rel_p,vec3(1,1,1)*sqSize,0.3);
    float silinder =cylinder(cylinder_rel,1.5*sqSize,0.864*sqSize);
    float silinder2=cylinder(cylinder_rel2,1.5*sqSize,0.864*sqSize);
    float silinder3=cylinder(cylinder_rel3,1.5*sqSize,0.864*sqSize);
    final=opSub(silinder,box1);
    final=opSub(silinder2,final);
    final=opSub(silinder3,final);
   

    return final;
}
float much_sphere(vec3 p,vec3 cord,int count,float size,float rx,float ry,float rz){
    vec3 point=p-cord;
    point=rotatex(point,rx);
    point=rotatey(point,ry);
    point=rotatez(point,rz);
    float final=10000000.;
    float r=size/float(count);
    int range=count/2;
    for(int i=-range;i<range;i++){
        for(int j=-range;j<range;j++){
            for(int k=-range;k<range;k++){
                float x=float(i)*r;
                float y=float(j)*r;
                float z=float(k)*r;
                vec3 pos=vec3(x,y,z)+point;
                float sphere1=sphere(vec3(0),pos,r/2.);
                final=opUnionSmooth(final,sphere1,0.1);
            }    
        }
    }
    return final;
}
float map_world(in vec3 p){
    float displacement=sin(5*p.x)*sin(5*p.y)*sin(5*p.z)/4;
    float box1=myShape(p,vec3(0,0,0.5),1.5,iTime,iTime*2,0.);
    float box2=myShape(p,vec3(0,0,0.5),1,iTime*2,-iTime,0.);
    float ms=much_sphere(p,vec3(0,0,0.5),2,0.7,iTime,iTime*2,0.);
    float ms2=much_sphere(p,vec3(0,0,0.5),2,0.4,-iTime,-iTime*9,0.);
    float msf=opUnionSmooth(ms,ms2,0.2);
    float result=opUnion(box1,box2);
    result=opUnion(result,msf);

    return result;
}
vec3 calc_normal(in vec3 p){
    const vec3 small_step=vec3(0.001,0,0);

    float g_x=map_world(p+small_step.xyy)-map_world(p-small_step.xyy);
    float g_y=map_world(p+small_step.yxy)-map_world(p-small_step.yxy);
    float g_z=map_world(p+small_step.yyx)-map_world(p-small_step.yyx);
    vec3 normal= vec3(g_x,g_y,g_z);
    return normalize(normal);
}

vec3 ray_march(in vec3 ro,in vec3 rd){

    float traveled_dist=0;
    const float treshold=0.0001;
    const float max_dist=100.00;
    const int step_count=80;
    
    for(int i=0;i<step_count;i++){
        vec3 c_point=ro+rd*traveled_dist;

        float dist =map_world(c_point);

        if(dist<treshold){
            vec3 normal=calc_normal(c_point);
            vec3 light=vec3(0,3,-1);
            light=rotatez(light,iTime*3);
            vec3 direction_light=normalize(c_point-light);
            float dif_intensity=max(0.2,dot(-normal,direction_light));

            return vec3(1,0,1)*dif_intensity;
        }
        traveled_dist+=dist;
        if(traveled_dist>max_dist){
            break;
        }
    }
    return vec3(0.2,0.2,0.2)+vec3(0.5)*vColor.y;
}

void main(){
vec3 ro=vec3(0,0,-3);
vec3 uv=vColor;
uv.z=1;
vec3 rd=normalize(uv);

vec3 col=ray_march(ro,rd);


f_color=vec4(col,1);
}