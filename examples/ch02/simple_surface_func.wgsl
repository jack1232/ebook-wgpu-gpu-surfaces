struct DataRange {
    xRange: vec2f,
    yRange: vec2f,
    zRange: vec2f,
	aspectRatio: f32,
}

fn sinc(x:f32, z:f32, t:f32) -> vec3f{
    let a = 1.01 + sin(t);   

	let r = a * sqrt(x*x + z*z);
    var y = 1.0;
    if(r != 0.0){
        y = sin(r)/r;
    }
	return vec3(x, y, z);
}

fn peaks(x:f32, z:f32, t:f32) -> vec3f{   
    let a = 1.0 + 0.2*sin(t);
    let b = 1.0 + 0.2*sin(1.5*t);
    let c = 1.0 + 0.2*sin(2.0*t);    

    let y = 3.0 * (1.0 - z) * (1.0 - z) * exp(-a* (z * z) - a * (x + 1.0) * (x + 1.0)) -
		10.0 * (z / 5.0 - z * z * z - x * x * x * x * x) * exp(-b * z * z - b * x * x) 
        - 1.0 / 3.0 * exp(- c * (z + 1.0) * (z + 1.0) - c * x * x);

    return vec3(z, y, x);
}

fn poles(x:f32, z:f32, t:f32) -> vec3f{
    let a = 1.5*(sin(t));   
	let y = x*z/(abs((x-a)*(x-a)*(x-a)) + (z- 2.0*a)*(z- 2.0*a) + 2.0);

	return vec3(x, y, z);
}

fn getDataRange(funcSelection:u32) -> DataRange{
	var dr:DataRange;

	if (funcSelection == 0u) { // sinc
		dr.xRange = vec2(-8.0, 8.0);
		dr.yRange = vec2(-0.3, 1.0);
		dr.zRange = vec2(-8.0, 8.0);
		dr.aspectRatio = 0.5;
	} else if (funcSelection == 1u) { // peaks
		dr.xRange = vec2(-3.0, 3.0);
		dr.yRange = vec2(-6.5, 8.1);
		dr.zRange = vec2(-3.0, 3.0);
		dr.aspectRatio = 0.9;
	} else { // poles
		dr.xRange = vec2(-8.0, 8.0);
		dr.yRange = vec2(-0.4, 3.3);
		dr.zRange = vec2(-8.0, 8.0);
		dr.aspectRatio = 1.0;
	}

	return dr;
}

fn simpleSurfaceFunc(x:f32, z:f32, t:f32, funcSelection:u32) -> vec3f{
	var pos = vec3(0.0, 0.0, 0.0);

	if (funcSelection == 0u) { // sinc
		pos = sinc(x, z, t);
	}
	else if (funcSelection == 1u) { // peaks
		pos = peaks(x, z, t);
	}
	else if (funcSelection == 2u) { // poles
		pos = poles(x, z, t);
	}
	
	return pos;
}