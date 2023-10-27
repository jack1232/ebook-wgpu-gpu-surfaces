const pi:f32 = 3.14159265359;

struct VertexData{
    position: vec4f,
    normal: vec4f,
    color: vec4f,
}

struct VertexDataArray{
    vertexDataArray: array<VertexData>,
}

struct SuperShapeParams {
    n1:vec4f,
    n2:vec4f,
    a1:vec2f,
    a2:vec2f,
    resolution: f32,
    colormapDirection: f32,
    colormapReverse: f32,
    animationTime: f32,
    scaling:f32,
    aspectRatio: f32,   
}

@group(0) @binding(0) var<storage, read_write> vda : VertexDataArray;
@group(0) @binding(1) var<storage, read_write> vda2 : VertexDataArray;
@group(0) @binding(2) var<storage> colormap: array<vec4f>;
@group(0) @binding(3) var<storage> colormap2: array<vec4f>;
@group(0) @binding(4) var<uniform> ssp: SuperShapeParams;

var<private> umin:f32; 
var<private> umax:f32; 
var<private> vmin:f32; 
var<private> vmax:f32;
var<private> du:f32;
var<private> dv:f32;

fn superShape3D(u:f32, v:f32, t:f32, n1:vec4f, n2:vec4f, a1:vec2f, a2:vec2f) -> vec3f {
    var raux1 = pow(abs(1.0 / a1.x * cos(n1.x * u /4.0)), n1.z) + pow(abs(1.0 / a1.y * sin(n1.x * u /4.0)), n1.w);
    var r1 = pow(abs(raux1), -1.0 / n1.y);
    var raux2 = pow(abs(1.0 / a2.x * cos(n2.x * v /4.0)), n2.z) + pow(abs(1.0 / a2.y * sin(n2.x * v /4.0)), n2.w);
    var r2 = pow(abs(raux2), -1.0 / n2.y);

    var a = 0.334*(2.0 + sin(t)); 
    var v1 = v*a;
    var x = r1 * cos(u) * r2 * cos(v1);
    var y = r2 * sin(v1);
    var z = r1 * sin(u) * r2 * cos(v1);
    return vec3(x, y, z);
}

fn getUv(id: vec3u) -> vec2f {
    umin = -pi;
    umax = pi;
    vmin = -0.5*pi;
    vmax = 0.5*pi;

    du = (umax - umin)/(f32(ssp.resolution) - 1.0);
    dv = (vmax - vmin)/(f32(ssp.resolution) - 1.0);
    var u = umin + f32(id.x) * du;
    var v = vmin + f32(id.y) * dv;
    return vec2(u, v);
}

fn normalizePoint(u:f32, v:f32) -> vec3f {
    var t = ssp.animationTime;
    var pos = superShape3D(u, v, t, ssp.n1, ssp.n2, ssp.a1, ssp.a2);
    pos.y = pos.y*ssp.aspectRatio;
    return pos*ssp.scaling;
}

fn colorLerp(is_surface:bool, tmin:f32, tmax:f32, t:f32, colormapReverse:u32) -> vec4f{
    var t1 = t;
    if (t1 < tmin) {t1 = tmin;}
    if (t1 > tmax) {t1 = tmax;}
    var tn = (t1-tmin)/(tmax-tmin);

    if(colormapReverse >= 1u) {tn = 1.0 - tn;}

    var idx = u32(floor(10.0*tn));
    var color = vec4(0.0,0.0,0.0, 1.0);

    if(is_surface){
        if(f32(idx) == 10.0*tn) {
            color = colormap[idx];
        } else {
            var tn1 = (tn - 0.1*f32(idx))*10.0;
            var a = colormap[idx];
            var b = colormap[idx+1u];
            color.x = a.x + (b.x - a.x)*tn1;
            color.y = a.y + (b.y - a.y)*tn1;
            color.z = a.z + (b.z - a.z)*tn1;
        }
    } else {
        if(f32(idx) == 10.0*tn) {
            color = colormap2[idx];
        } else {
            var tn1 = (tn - 0.1*f32(idx))*10.0;
            var a = colormap2[idx];
            var b = colormap2[idx+1u];
            color.x = a.x + (b.x - a.x)*tn1;
            color.y = a.y + (b.y - a.y)*tn1;
            color.z = a.z + (b.z - a.z)*tn1;
        }
    }
    return color;
}

@compute @workgroup_size(8, 8, 1)
fn cs_main(@builtin(global_invocation_id) id : vec3u) {
    var i = id.x;
    var j = id.y;
    var idx = i + j * u32(ssp.resolution);
    var uv = getUv(id);
    
    var p0 = normalizePoint(uv.x, uv.y);

    // calculate normals
    /*var p1:vec3f;
    var p2:vec3f; 
    var p3:vec3f;*/
    let epsu = 0.01 * du;
    let epsv = 0.01 * dv;

    /*if (uv.x - epsu >= 0.0) {
        p1 = normalizePoint(uv.x - epsu, uv.y);
        p2 = p0 - p1;
    }
    else {
        p1 = normalizePoint(uv.x + epsu, uv.y);
        p2 = p1 - p0;
    }
    if (uv.y - epsv >= 0.0) {
        p1 = normalizePoint(uv.x, uv.y - epsv);
        p3 = p0 - p1;
    }
    else {
        p1 = normalizePoint(uv.x, uv.y + epsv);
        p3 = p1 - p0;
    }
    var normal = normalize(cross(p2, p3));*/

    let nx = normalizePoint(uv.x + epsu, uv.y) - normalizePoint(uv.x - epsu, uv.y);
    let nz = normalizePoint(uv.x, uv.y + epsv) - normalizePoint(uv.x, uv.y - epsv);
    let normal = normalize(cross(nx, nz));

    // colormap
    var range = 1.0;
    if(ssp.colormapDirection == 1.0){
        range = ssp.aspectRatio;
    }
    let color = colorLerp(true, -range, range, p0[u32(ssp.colormapDirection)], u32(ssp.colormapReverse));
    let color2 = colorLerp(false, -range, range, p0[u32(ssp.colormapDirection)], u32(ssp.colormapReverse));

    // for surface
    vda.vertexDataArray[idx].position = vec4(p0, 1.0);
    vda.vertexDataArray[idx].normal = vec4(normal, 1.0);
    vda.vertexDataArray[idx].color = color;

    // for wireframe
    vda2.vertexDataArray[idx].position = vec4(p0, 1.0);
    vda2.vertexDataArray[idx].normal = vec4(normal, 1.0);
    vda2.vertexDataArray[idx].color = color2;
}