struct VertexData{
    position: vec4f,
    normal: vec4f,
    color: vec4f,
}

struct VertexDataArray{
    vertexDataArray: array<VertexData>, 
}

struct ParametricSurfaceParams{
    resolution: u32,
    funcSelection: u32,
    colormapDirection: u32,
    colormapReverse: u32,
}

@group(0) @binding(0) var<storage, read_write> vda : VertexDataArray;
@group(0) @binding(1) var<storage, read_write> vda2 : VertexDataArray;
@group(0) @binding(2) var<storage> colormap: array<vec4f>;
@group(0) @binding(3) var<storage> colormap2: array<vec4f>;
@group(0) @binding(4) var<uniform> psp: ParametricSurfaceParams;

var<private> umin:f32; 
var<private> umax:f32; 
var<private> vmin:f32; 
var<private> vmax:f32;
var<private> xmin:f32;
var<private> xmax:f32;
var<private> ymin:f32; 
var<private> ymax:f32;
var<private> zmin:f32; 
var<private> zmax:f32;
var<private> range:f32 = 1.0;
var<private> du:f32;
var<private> dv:f32;

fn getUv(id: vec3u) -> vec2f {
    var dr = getDataRange(psp.funcSelection);
    umin = dr.uRange[0];
	umax = dr.uRange[1];
	vmin = dr.vRange[0];
	vmax = dr.vRange[1];
	xmin = dr.xRange[0];
	xmax = dr.xRange[1];
	ymin = dr.yRange[0];
	ymax = dr.yRange[1];
	zmin = dr.zRange[0];
	zmax = dr.zRange[1];	

    du = (umax - umin)/(f32(psp.resolution) - 1.0);
    dv = (vmax - vmin)/(f32(psp.resolution) - 1.0);
    var u = umin + f32(id.x) * du;
    var v = vmin + f32(id.y) * dv;
    return vec2(u, v);
}

fn normalizePoint(u:f32, v:f32) -> vec3f {
    var pos = parametricSurfaceFunc(u, v, psp.funcSelection);
    var distance = max(max(xmax - xmin, ymax - ymin), zmax - zmin);

    if(psp.colormapDirection == 0u){
        range = (xmax - xmin)/distance;
    } else if(psp.colormapDirection == 2u){
        range = (zmax - zmin)/distance;
    } else {
        range = (ymax - ymin)/distance;
    }

    pos.x = 2.0 * (pos.x - xmin)/(xmax - xmin) - 1.0;
    pos.y = 2.0 * (pos.y - ymin)/(ymax - ymin) - 1.0;
    pos.z = 2.0 * (pos.z - zmin)/(zmax - zmin) - 1.0;

    pos.x = pos.x * (xmax - xmin)/distance;
    pos.y = pos.y * (ymax - ymin)/distance;
    pos.z = pos.z * (zmax - zmin)/distance;
    
    return pos;
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
    var idx = i + j * psp.resolution;
    var uv = getUv(id);
    
    var p0 = normalizePoint(uv.x, uv.y);

    // calculate normals
    let epsu = 0.01 * du;
    let epsv = 0.01 * dv;

    let nu = normalizePoint(uv.x + epsu, uv.y) - normalizePoint(uv.x - epsu, uv.y);
    let nv = normalizePoint(uv.x, uv.y + epsv) - normalizePoint(uv.x, uv.y - epsv);
    let normal = normalize(cross(nu, nv));

    // colormap
    var color = colorLerp(true, -range, range, p0[psp.colormapDirection], psp.colormapReverse);
    var color2 = colorLerp(false, -range, range, p0[psp.colormapDirection], psp.colormapReverse);

    // for surface
    vda.vertexDataArray[idx].position = vec4(p0, 1.0);
    vda.vertexDataArray[idx].normal = vec4(normal, 1.0);
    vda.vertexDataArray[idx].color = color; 
    
    // for wireframe
    vda2.vertexDataArray[idx].position = vec4(p0, 1.0);
    vda2.vertexDataArray[idx].normal = vec4(normal, 1.0);
    vda2.vertexDataArray[idx].color = color2; 
}