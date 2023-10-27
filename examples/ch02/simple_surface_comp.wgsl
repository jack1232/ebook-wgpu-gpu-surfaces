struct VertexData{
    position: vec4f,
    normal: vec4f,
    color: vec4f,
}
struct VertexDataArray{
    vertexDataArray: array<VertexData>,
}

struct SimpleSurfaceParams {
    resolution: f32,
    funcSelection: f32,
    colormapDirection: f32,
    colormapReverse: f32,
    animationTime: f32,
}

@group(0) @binding(0) var<storage, read_write> vda : VertexDataArray;
@group(0) @binding(1) var<storage, read_write> vda2 : VertexDataArray;
@group(0) @binding(2) var<storage> colormap: array<vec4f>;
@group(0) @binding(3) var<storage> colormap2: array<vec4f>;
@group(0) @binding(4) var<uniform> ssp: SimpleSurfaceParams;

var<private> xmin:f32;
var<private> xmax:f32;
var<private> ymin:f32; 
var<private> ymax:f32;
var<private> zmin:f32; 
var<private> zmax:f32;
var<private> dx:f32;
var<private> dz:f32;
var<private> aspect:f32;

fn getUv(i:u32, j:u32) -> vec2f {
    var dr = getDataRange(u32(ssp.funcSelection));
	xmin = dr.xRange[0];
	xmax = dr.xRange[1];
	ymin = dr.yRange[0];
	ymax = dr.yRange[1];
	zmin = dr.zRange[0];
	zmax = dr.zRange[1];
    aspect = dr.aspectRatio;

    dx = (xmax - xmin)/(ssp.resolution - 1.0);
    dz = (zmax - zmin)/(ssp.resolution - 1.0);
    var x = xmin + f32(i) * dx;
    var z = zmin + f32(j) * dz;
    return vec2(x, z);
}

fn normalizePoint(u:f32, v:f32) -> vec3f {
    var pos = simpleSurfaceFunc(u, v, ssp.animationTime, u32(ssp.funcSelection));
    pos.x = 2.0 * (pos.x - xmin)/(xmax - xmin) - 1.0;
    pos.y = 2.0 * (pos.y - ymin)/(ymax - ymin) - 1.0;
    pos.z = 2.0 * (pos.z - zmin)/(zmax - zmin) - 1.0;
    pos.y = pos.y * aspect;
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
    let i = id.x;
    let j = id.y;   
    var uv = getUv(i, j);
    var p0 = normalizePoint(uv.x, uv.y);

    // calculate normals
    let epsx = 0.01 * dx;
    let epsz = 0.01 * dz;

    let nx = normalizePoint(uv.x + epsx, uv.y) - normalizePoint(uv.x - epsx, uv.y);
    let nz = normalizePoint(uv.x, uv.y + epsz) - normalizePoint(uv.x, uv.y - epsz);
    let normal = normalize(cross(nx, nz));

    // colormap
    var range = 1.0;
    if(u32(ssp.colormapDirection) == 1u){
        range = aspect;
    }

    let color = colorLerp(true, -range, range, p0[u32(ssp.colormapDirection)], u32(ssp.colormapReverse));
    let color2 = colorLerp(false, -range, range, p0[u32(ssp.colormapDirection)], u32(ssp.colormapReverse));
    
    var idx = i + j * u32(ssp.resolution);

    // for surface
    vda.vertexDataArray[idx].position = vec4(p0, 1.0);
    vda.vertexDataArray[idx].normal = vec4(normal, 1.0);
    vda.vertexDataArray[idx].color = color;
       
    // for wireframe
    vda2.vertexDataArray[idx].position = vec4(p0, 1.0);
    vda2.vertexDataArray[idx].normal = vec4(normal, 1.0);
    vda2.vertexDataArray[idx].color = color2;
}