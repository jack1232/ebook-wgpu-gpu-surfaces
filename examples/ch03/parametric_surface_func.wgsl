const pi:f32 = 3.14159265359;

struct DataRange {
    uRange: vec2f,
    vRange: vec2f,
    xRange: vec2f,
    yRange: vec2f,
    zRange: vec2f,
};

fn p2(x:f32) -> f32 {
    return pow(x, 2.0);
}

fn p3(x:f32) -> f32 {
    if(x >= 0.0){
        return pow(x,3.0);
    } else{
        return -pow(abs(x), 3.0);
    }
}

fn p4(x:f32) -> f32 {
    return pow(x, 4.0);
}

fn p5(x:f32) -> f32{
    if(x >= 0.0){
        return pow(x,5.0);
    } else{
        return -pow(abs(x), 5.0);
    }
}

fn p6(x:f32) -> f32 {
    return pow(x, 6.0);
}

fn p7(x:f32) -> f32 {
    if(x >= 0.0){
        return pow(x,7.0);
    } else{
        return -pow(abs(x), 7.0);
    }
}

fn p8(x:f32) -> f32 {
    return pow(x, 8.0);
}

fn astroid(u:f32, v:f32) -> vec3f {
	var x = p3(cos(u)) * p3(cos(v));
	var y = p3(sin(v));
	var z = p3(sin(u)) * p3(cos(v));
	return vec3(z, y, x);
}

fn astroid2(u:f32, v:f32) -> vec3f {
	var x = p3(sin(u)) * cos(v);
	var y = p3(cos(u));
	var z = p3(sin(u)) * sin(v);
	return vec3(x, y, z);
}

fn astroidal_torus(u:f32, v:f32) -> vec3f {
	let a = 2.0;
	let b = 1.0;
	let c = 0.7854;
	var x = (a + b * pow(cos(u), 3.0) * cos(c) - b * pow(sin(u), 3.0) * sin(c)) * cos(v);
	var y = b * pow(cos(u), 3.0) * sin(c) + b * pow(sin(u), 3.0) * cos(c);
	var z = (a + b * pow(cos(u), 3.0) * cos(c) - b * pow(sin(u), 3.0) * sin(c)) * sin(v);
	return vec3(z, y, x);
}

fn bohemian_dome(u:f32, v:f32) -> vec3f {
	let a = 0.7;
	let b = 1.0;
	var x = a * cos(u);
	var y = b * cos(v);
	var z = a * sin(u) + b * sin(v);
	return vec3(x, y, z);
}

fn boy_shape(u:f32, v:f32) -> vec3f {
	var x = cos(u) * (1.0 / 3.0 * sqrt(2.0) * cos(u) * cos(2.0 * v) + 2.0 / 3.0 * sin(u) * cos(v)) / (1.0 - sqrt(2.0) * sin(u) * cos(u) * sin(3.0 * v));
	var y = cos(u) * cos(u) / (1.0 - sqrt(2.0) * sin(u) * cos(u) * sin(3.0 * v)) - 1.0;
	var z = cos(u) * (1.0 / 3.0 * sqrt(2.0) * cos(u) * sin(2.0 * v) - 2.0 / 3.0 * sin(u) * sin(v)) / (1.0 - sqrt(2.0) * sin(u) * cos(u) * sin(3.0 * v));
	return vec3(z, y, x);
}

fn breather(u:f32, v:f32) -> vec3f {
	let a = 0.4;
	let ch = cosh(a * u);
	let sh = sinh(a * u);

	var x = -u + (2.0 * (1.0 - a * a) * ch * sh) / (a * ((1.0 - a * a) * p2(ch) + a * a * p2(sin(sqrt(1.0 - a * a) * v))));
	var y = (2.0 * sqrt(1.0 - a * a) * ch * (-(sqrt(1.0 - a * a) * cos(v) * cos(sqrt(1.0 - a * a) * v)) -
		sin(v) * sin(sqrt(1.0 - a * a) * v))) / (a * ((1.0 - a * a) * p2(ch) + a * a * p2(sin(sqrt(1.0 - a * a) * v))));
	var z = (2.0 * sqrt(1.0 - a * a) * ch * (-(sqrt(1.0 - a * a) * sin(v) * cos(sqrt(1.0 - a * a) * v)) +
		cos(v) * sin(sqrt(1.0 - a * a) * v))) / (a * ((1.0 - a * a) * p2(ch) + a * a * p2(sin(sqrt(1.0 - a * a) * v))));
	return vec3(x, y, z);
}

fn enneper(u:f32, v:f32) -> vec3f {
	var x = u * (1.0 - u * u / 3.0 + v * v);
	var y = u * u - v * v;
	var z = v * (1.0 - v * v / 3.0 + u * u);
	return vec3(x, y, z);
}

fn figure8(u:f32, v:f32) -> vec3f {
	let a = 2.5;
	var x = (a + cos(0.5 * u) * sin(v) - sin(0.5 * u) * sin(2.0 * v)) * cos(u);
	var y = (a + cos(0.5 * u) * sin(v) - sin(0.5 * u) * sin(2.0 * v)) * sin(u);
	var z = sin(0.5 * u) * sin(v) + cos(0.5 * u) * sin(2.0 * v);
	return vec3(x, z, y);
}

fn henneberg(u:f32, v:f32) -> vec3f {
	var x = (sinh(u) * cos(v) - sinh(3.0 * u) * cos(3.0 * v) / 3.0);
	var y = cosh(2.0 * u) * cos(2.0 * v);
	var z = (sinh(u) * sin(v) - sinh(3.0 * u) * sin(3.0 * v) / 3.0);
	return vec3(x, y, z);
}

fn kiss(u:f32, v:f32) -> vec3f {
	var x = u * u * sqrt(1.0 - u) * cos(v);
	var y = u;
	var z = u * u * sqrt(1.0 - u) * sin(v);
	return vec3(z, y, x);
}

fn klein_bottle(u:f32, v:f32) -> vec3f {
	var x = 2.0 / 15.0 * (3.0 + 5.0 * cos(u) * sin(u)) * sin(v);

	var y = -1.0 / 15.0 * sin(u) * (3.0 * cos(v) - 3.0 * p2(cos(u)) * cos(v) - 48.0 * p4(cos(u)) * cos(v) + 48.0 * p6(cos(u)) * cos(v) -
		60.0 * sin(u) + 5.0 * cos(u) * cos(v) * sin(u) - 5.0 * p3(cos(u)) * cos(v) * sin(u) -
		80.0 * p5(cos(u)) * cos(v) * sin(u) + 80.0 * p7(cos(u)) * cos(v) * sin(u));

	var z = -2.0 / 15.0 * cos(u) * (3.0 * cos(v) - 30.0 * sin(u) + 90.0 * p4(cos(u)) * sin(u) - 60.0 * p6(cos(u)) * sin(u) +
		5.0 * cos(u) * cos(v) * sin(u));

	return vec3(x, y, z);
}

fn klein_bottle2(u:f32, v:f32) -> vec3f {
	var x = 0.0;
    var z = 0.0;
	var r = 4.0 * (1.0 - 0.5 * cos(u));

	if (u >= 0.0 && u <= pi)
	{
		x = 6.0 * cos(u) * (1.0 + sin(u)) + r * cos(u) * cos(v);
		z = 16.0 * sin(u) + r * sin(u) * cos(v);
	}
	else if (u > pi && u <= 2.0 * pi)
	{
		x = 6.0 * cos(u) * (1.0 + sin(u)) + r * cos(v + pi);
		z = 16.0 * sin(u);
	}
	var y = r * sin(v);

	return vec3(x, z, y);
}

fn klein_bottle3(u:f32, v:f32) -> vec3f {
	let a = 8.0;
	let n = 3.0;
	let m = 1.0;
	var x = (a + cos(0.5 * u * n) * sin(v) - sin(0.5 * u * n) * sin(2.0 * v)) * cos(0.5 * u * m);
	var y = sin(0.5 * u * n) * sin(v) + cos(0.5 * u * n) * sin(2.0 * v);
	var z = (a + cos(0.5 * u * n) * sin(v) - sin(0.5 * u * n) * sin(2.0 * v)) * sin(0.5 * u * m);
	return vec3(x, y, z);
}

fn kuen(u:f32, v:f32) -> vec3f {
	var x = 2.0 * cosh(v) * (cos(u) + u * sin(u)) / (p2(cosh(v)) + u * u);
	var y = v - (2.0 * sinh(v) * cosh(v)) / (p2(cosh(v)) + u * u);
	var z = 2.0 * cosh(v) * (-u * cos(u) + sin(u)) / (p2(cosh(v)) + u * u);
	return vec3(x, y, z);
}

fn minimal(u:f32, v:f32) -> vec3f {
	let a = 1.0;
	let b = -4.0;
	let c = 1.0;
	var x = a * (u - sin(u) * cosh(v));
	var y = b * sin(u / 2.0) * sinh(v / 2.0);
	var z = c * (1.0 - cos(u) * cosh(v));	
	return vec3(x, y, z);
}

fn parabolic_cyclide(u:f32, v:f32) -> vec3f {
	let a = 1.0;
	let b = 0.5;
	var x = a * u * (v * v + b) / (1.0 + u * u + v * v);
	var y = (a / 2.0) * (2.0 * v * v + b * (1.0 - u * u - v * v)) / (1.0 + u * u + v * v);
	var z = a * v * (1.0 + u * u - b) / (1.0 + u * u + v * v);
	return vec3(z, y, x);
}

fn pear(u:f32, v:f32) -> vec3f {
	var x = u * sqrt(u * (1.0 - u)) * cos(v);
	var y = -u;
	var z = u * sqrt(u * (1.0 - u)) * sin(v);
	return vec3(x, y, z);
}

fn plucker_conoid(u:f32, v:f32) -> vec3f {
	let a = 2.0;
	let b = 3.0;
	var x = a * u * cos(v);
	var y = a * cos(b * v);
	var z = a * u * sin(v);
	return vec3(x, y, z);
}

fn seashell(u:f32, v:f32) -> vec3f {
	var x = 2.0 * (-1.0 + exp(u / (6.0 * pi))) * sin(u) * p2(cos(v / 2.0));
	var y = 1.0 - exp(u / (3.0 * pi)) - sin(v) + exp(u / (6.0 * pi)) * sin(v);
	var z = 2.0 * (1.0 - exp(u / (6.0 * pi))) * cos(u) * p2(cos(v / 2.0));
	return vec3(x, y, z);
}

fn sievert_enneper(u:f32, v:f32) -> vec3f {
	let a = 1.0;
	var x = log(tan(v / 2.0)) / sqrt(a) + 2.0 * (1.0 + a) * cos(v) / (1.0 + a - a * sin(v) * sin(v) * cos(u) * cos(u)) / sqrt(a);

	var y = (2.0 * sin(v) * sqrt((1.0 + 1.0 / a) * (1.0 + a * sin(u) * sin(u)))) / (1.0 + a - a * sin(v) * sin(v) * cos(u) *
		cos(u)) * sin(atan(sqrt(1.0 + a) * tan(u)) - u / sqrt(1.0 + a));

	var z = (2.0 * sin(v) * sqrt((1.0 + 1.0 / a) * (1.0 + a * sin(u) * sin(u)))) / (1.0 + a - a * sin(v) * sin(v) * cos(u) *
		cos(u)) * cos(atan(sqrt(1.0 + a) * tan(u)) - u / sqrt(1.0 + a));

	return vec3(z, y, x);
}

fn steiner(u:f32, v:f32) -> vec3f {
	var x = cos(u) * cos(v) * sin(v);
	var y = cos(u) * sin(u) * p2(cos(v));
	var z = sin(u) * cos(v) * sin(v);
	return vec3(x, y, z);
}

fn torus(u:f32, v:f32) -> vec3f {
	let r1 = 1.0;
	let r2 = 0.3;
	var x = (r1 + r2 * cos(v)) * cos(u);
	var y = r2 * sin(v);
	var z = (r1 + r2 * cos(v)) * sin(u);
	return vec3(x, y, z);
}


fn wellenkugel(u:f32, v:f32) -> vec3f {
	var x = u * cos(cos(u)) * cos(v);	
	var y = u * sin(cos(u));
	var z = u * cos(cos(u)) * sin(v);
	
	return vec3(x, y, z);
}

fn getDataRange(funcSelection:u32) -> DataRange {
	var dr:DataRange;
	if (funcSelection == 0u) { // klein-bottle
		dr.uRange = vec2<f32>(0.0, pi);
		dr.vRange = vec2<f32>(0.0, 2.0 * pi);
		dr.xRange = vec2<f32>(-0.734, 0.734);
		dr.yRange = vec2<f32>(0.0, 4.21);
		dr.zRange = vec2<f32>(-1.517, 1.824);
	} else if (funcSelection == 1u) { // astroid
		dr.uRange = vec2(0.0, 2.0 * pi);
		dr.vRange = vec2(0.0, 2.0 * pi);
		dr.xRange = vec2(-1.0, 1.0);
		dr.yRange = vec2(-1.0, 1.0);
		dr.zRange = vec2(-1.0, 1.0);
	} else if (funcSelection == 2u) { // astroid 2
		dr.uRange = vec2(0.0, 2.0 * pi);
		dr.vRange = vec2(0.0, 2.0 * pi);
		dr.xRange = vec2(-1.0, 1.0);
		dr.yRange = vec2(-1.0, 1.0);
		dr.zRange = vec2(-1.0, 1.0);
	} else if (funcSelection == 3u) { // astroidal torus
		dr.uRange = vec2<f32>(-pi, pi);
		dr.vRange = vec2<f32>(0.0, 5.0);
		dr.xRange = vec2<f32>(-2.71, 2.71);
		dr.yRange = vec2<f32>(-0.7071,0.7071);
		dr.zRange = vec2<f32>(-2.707, 2.707);
	} else if (funcSelection == 4u) { // bohemian dome
		dr.uRange = vec2<f32>(0.0, 2.0*pi);
		dr.vRange = vec2<f32>(0.0, 2.0*pi);
		dr.xRange = vec2<f32>(-0.7, 0.7);
		dr.yRange = vec2<f32>(-1.0, 1.0);
		dr.zRange = vec2<f32>(-1.7, 1.7);
	} else if (funcSelection == 5u) { // boy shape
		dr.uRange = vec2<f32>(0.0, pi);
		dr.vRange = vec2<f32>(0.0, pi);
		dr.xRange = vec2<f32>(-1.383, 1.187);
		dr.yRange = vec2<f32>(-1.0, 1.0);
		dr.zRange = vec2<f32>(-0.964, 1.469);
	} else if (funcSelection == 6u) { // breather
		dr.uRange = vec2<f32>(-14.0, 14.0);
		dr.vRange = vec2<f32>(-12.0*pi, 12.0*pi);
		dr.xRange = vec2<f32>(-9.0, 9.0);
		dr.yRange = vec2<f32>(-4.984, 4.998);
		dr.zRange = vec2<f32>(-4.946, 4.946);
	} else if (funcSelection == 7u) { // enneper
		dr.uRange = vec2<f32>(-3.3, 3.3);
		dr.vRange = vec2<f32>(-3.3, 3.3);
		dr.xRange = vec2<f32>(-27.258, 27.258);
		dr.yRange = vec2<f32>(-10.8898, 10.8898);
		dr.zRange = vec2<f32>(-27.258, 27.258);
	} else if (funcSelection == 8u) { // figure 8
		dr.uRange = vec2<f32>(0.0, 4.0*pi);
		dr.vRange = vec2<f32>(0.0, 2.0*pi);
		dr.xRange = vec2<f32>(-3.517, 3.5);
		dr.yRange = vec2<f32>(-1.25, 1.25);
		dr.zRange = vec2<f32>(-3.745, 3.745);		
	} else if (funcSelection == 9u) { // Henneberg
		dr.uRange = vec2<f32>(0.0, 1.0);
		dr.vRange = vec2<f32>(0.0, 2.0*pi);
		dr.xRange = vec2<f32>(-3.942, 3.944);
		dr.yRange = vec2<f32>(-3.762, 3.763);
		dr.zRange = vec2<f32>(-4.514, 4.514);
	} else if (funcSelection == 10u) { // kiss
		dr.uRange = vec2<f32>(-0.9999, 0.9999);
		dr.vRange = vec2<f32>(0.0, 2.0 * pi);
		dr.xRange = vec2<f32>(-1.383, 1.383);
		dr.yRange = vec2<f32>(-1.0, 1.0);
		dr.zRange = vec2<f32>(-1.383, 1.383);
	} else if (funcSelection == 11u) { // klein-bottle 2
		dr.uRange = vec2<f32>(0.0, 2.0 * pi);
		dr.vRange = vec2<f32>(0.0, 2.0 * pi);
		dr.xRange = vec2<f32>(-13.1, 9.761);
		dr.yRange = vec2<f32>(-16.0, 20.1);
		dr.zRange = vec2<f32>(-6.0, 6.0);
	} else if (funcSelection == 12u) { // klein-bottle 3
		dr.uRange = vec2<f32>(0.0, 4.0 * pi);
		dr.vRange = vec2<f32>(0.0, 2.0 * pi);
		dr.xRange = vec2<f32>(-9.055, 9.055);
		dr.yRange = vec2<f32>(-1.25, 1.25);
		dr.zRange = vec2<f32>(-9.127, 9.127);
	} else if (funcSelection == 13u) { // kuen
		dr.uRange = vec2<f32>(-4.5, 4.5);
		dr.vRange = vec2<f32>(-5.0, 5.0);
		dr.xRange = vec2<f32>(-1.025, 2.0);
		dr.yRange = vec2<f32>(-3.0, 3.0);
		dr.zRange = vec2<f32>(-1.063, 1.063);
	} else if (funcSelection == 14u) { // minimal
		dr.uRange = vec2<f32>(-8.2, 8.2);
		dr.vRange = vec2<f32>(-2.2, 2.2);
		dr.xRange = vec2<f32>(-9.39, 9.39);
		dr.yRange = vec2<f32>(-5.342, 5.342);
		dr.zRange = vec2<f32>(-3.57, 5.566);
	} else if (funcSelection == 15u) { // parabolic cyclide
		dr.uRange = vec2<f32>(-5.0, 5.0);
		dr.vRange = vec2<f32>(-5.5, 5.5);
		dr.xRange = vec2<f32>(-2.5, 2.5);
		dr.yRange = vec2<f32>(-0.231, 0.734);
		dr.zRange = vec2<f32>(-2.734, 2.734);
	} else if (funcSelection == 16u) { // pear
		dr.uRange = vec2<f32>(0.0, 1.0);
		dr.vRange = vec2<f32>(0.0, 2.0 * pi);
		dr.xRange = vec2<f32>(-0.325, 0.325);
		dr.yRange = vec2<f32>(-1.0, 0.0);
		dr.zRange = vec2<f32>(-0.325, 0.325);
	} else if (funcSelection == 17u) { // plucker conoid
		dr.uRange = vec2<f32>(-2.0, 2.0);
		dr.vRange = vec2<f32>(0.0, 2.0 * pi);
		dr.xRange = vec2<f32>(-4.0, 4.0);
		dr.yRange = vec2<f32>(-2.0, 2.0);
		dr.zRange = vec2<f32>(-4.0, 4.0);
	} else if (funcSelection == 18u) { // seashell
		dr.uRange = vec2<f32>(0.0, 6.0 * pi);
		dr.vRange = vec2<f32>(0.0, 2.0 * pi);
		dr.xRange = vec2<f32>(-3.012, 2.245);
		dr.yRange = vec2<f32>(-8.108, 0.0);
		dr.zRange = vec2<f32>(-3.437, 2.613);
	} else if (funcSelection == 19u) { // sievert-enneper
		dr.uRange = vec2<f32>(-pi / 2.1, pi / 2.1);
		dr.vRange = vec2<f32>(0.001, pi / 1.001);
		dr.xRange = vec2<f32>(-0.00142, 2.829);
		dr.yRange = vec2<f32>(-0.917, 0.917);
		dr.zRange = vec2<f32>(-5.6, 4.458);
	} else if (funcSelection == 20u) { // steiner
		dr.uRange = vec2<f32>(0.0, 1.999999*pi);
		dr.vRange = vec2<f32>(0.0, 1.999999*pi);
		dr.xRange = vec2<f32>(-0.5, 0.5);
		dr.yRange = vec2<f32>(-0.5, 0.5);
		dr.zRange = vec2<f32>(-0.5, 0.5);
	} else if (funcSelection == 21u) { // torus
		dr.uRange = vec2<f32>(0.0, 2.0 * pi);
		dr.vRange = vec2<f32>(0.0, 2.5 * pi);
		dr.xRange = vec2<f32>(-1.3, 1.3);
		dr.yRange = vec2<f32>(-0.3, 0.3);
		dr.zRange = vec2<f32>(-1.3, 1.3);
	} else if (funcSelection == 22u) { // wellenkugel
		dr.uRange = vec2<f32>(0.0, 14.5);
		dr.vRange = vec2<f32>(0.0, 5.2);
		dr.xRange = vec2<f32>(-14.171, 14.173);
		dr.yRange = vec2<f32>(-8.0, 10.626);
		dr.zRange = vec2<f32>(-14.172, 14.172);
	}
	return dr;
}


fn parametricSurfaceFunc(u:f32, v:f32, funcSelection:u32) -> vec3f {
	var pos = vec3(0.0, 0.0, 0.0);

	if (funcSelection == 0u) { // klein bottle
		pos = klein_bottle(u, v);
	} else if (funcSelection == 1u) { // astroid
		pos = astroid(u, v);
	} else if (funcSelection == 2u) { // astroid2
		pos = astroid2(u, v);
	} else if (funcSelection == 3u) { // astroidal torus
		pos = astroidal_torus(u, v);
	} else if (funcSelection == 4u) { // bohemian dome
		pos = bohemian_dome(u, v);
	} else if (funcSelection == 5u) { // boy shape
		pos = boy_shape(u, v);
	} else if (funcSelection == 6u) { // breather
		pos = breather(u, v);
	} else if (funcSelection == 7u) { // enneper
		pos = enneper(u, v);
	} else if (funcSelection == 8u) { // figure 8
		pos = figure8(u, v);
	} else if (funcSelection == 9u) { // henneberg
		pos = henneberg(u, v);
	} else if (funcSelection == 10u) { // kiss
		pos = kiss(u, v);
	} else if (funcSelection == 11u) { // klein-bottle 2
		pos = klein_bottle2(u, v);
	}
	else if (funcSelection == 12u) { // klein-bottle 3
		pos = klein_bottle3(u, v);
	} else if (funcSelection == 13u) { // kuen
		pos = kuen(u, v);
	} else if (funcSelection == 14u) { // minimal
		pos = minimal(u, v);
	} else if (funcSelection == 15u) { // parabolic cyclide
		pos = parabolic_cyclide(u, v);
	} else if (funcSelection == 16u) { // pear
		pos = pear(u, v);
	} else if (funcSelection == 17u) { // plucker conoid
		pos = plucker_conoid(u, v);
	} else if (funcSelection == 18u) { // seashell
		pos = seashell(u, v);
	} else if (funcSelection == 19u) { // sievert-enneper
		pos = sievert_enneper(u, v);
	} else if (funcSelection == 20u) { // steiner
		pos = steiner(u, v);
	} else if (funcSelection == 21u) { // torus
		pos = torus(u, v);
	} else if (funcSelection == 22u) { // wellenkugel
		pos = wellenkugel(u, v);
	}
	return pos;
}