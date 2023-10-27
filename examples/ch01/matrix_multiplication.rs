#![allow(dead_code)]
use wgpu::util::DeviceExt;
use wgpu_simplified as ws;

async fn run() -> Option<Vec<f32>> {     
    let instance = wgpu::Instance::default();
    let adapter = instance
        .request_adapter(&wgpu::RequestAdapterOptions::default())
        .await?;
    let (device, queue) = adapter
        .request_device(
            &wgpu::DeviceDescriptor {
                label: None,
                features: wgpu::Features::empty(),
                limits: wgpu::Limits::downlevel_defaults(),
            },
            None,
        )
        .await
        .unwrap(); 

    let shader = device.create_shader_module(wgpu::include_wgsl!("matrix_multiplication.wgsl"));

    let first_mat = vec![
        2f32, // rows
        4.,   // columns 
        1., 2., 3., 4.,
        5., 6., 7., 8.,
    ];
    let first_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
        label: Some("First Buffer"),
        contents: bytemuck::cast_slice(&first_mat),
        usage: wgpu::BufferUsages::STORAGE,
    });

    let second_mat = vec![
        4f32, // rows
        2.,   // columns
        1., 2.,
        3., 4.,
        5., 6.,
        7., 8.  
    ];

    let second_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
        label: Some("Second Buffer"),
        contents: bytemuck::cast_slice(&second_mat),
        usage: wgpu::BufferUsages::STORAGE,
    });

    let result_buffer_size:u64 = 4 * (2 + 2 * 2);
    let result_buffer = device.create_buffer(&wgpu::BufferDescriptor {
        label: None,
        size: result_buffer_size,
        usage: wgpu::BufferUsages::STORAGE | wgpu::BufferUsages::COPY_SRC,
        mapped_at_creation: false,
    });

    let read_buffer = device.create_buffer(&wgpu::BufferDescriptor {
        label: None,
        size: result_buffer_size,
        usage: wgpu::BufferUsages::MAP_READ | wgpu::BufferUsages::COPY_DST,
        mapped_at_creation: false,
    });

    let (bind_group_layout, bind_group) = ws::create_bind_group_storage(
        &device, 
        vec![
            wgpu::ShaderStages::COMPUTE,
            wgpu::ShaderStages::COMPUTE,
            wgpu::ShaderStages::COMPUTE,
        ], 
        vec![
            wgpu::BufferBindingType::Storage { read_only: true },
            wgpu::BufferBindingType::Storage { read_only: true },
            wgpu::BufferBindingType::Storage { read_only: false },
        ], 
        &[
            first_buffer.as_entire_binding(),
            second_buffer.as_entire_binding(),
            result_buffer.as_entire_binding(),
        ],
    );

    let pipeline_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
        label: Some("Pipeline Layout"),
        bind_group_layouts: &[&bind_group_layout],
        push_constant_ranges: &[],
    });

    let pipeline = device.create_compute_pipeline(&wgpu::ComputePipelineDescriptor {
        label: Some("compute Pipeline"),
        layout: Some(&pipeline_layout),
        module: &shader,
        entry_point: "cs_main",
    });

    let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor { label: None });
    {
        let mut compute_pass = encoder.begin_compute_pass(&wgpu::ComputePassDescriptor { label: None });
        compute_pass.set_pipeline(&pipeline);
        compute_pass.set_bind_group(0, &bind_group, &[]);
        compute_pass.insert_debug_marker("compute collatz iterations");
        compute_pass.dispatch_workgroups(8, 8, 1); // Number of cells to run, the (x,y,z) size of item being processed
    }
    encoder.copy_buffer_to_buffer(&result_buffer, 0, &read_buffer, 0, result_buffer_size);
    queue.submit(Some(encoder.finish()));

    // read buffer 
    let read_buffer_slice = read_buffer.slice(..);
    let (sender, receiver) = flume::bounded(1);
    read_buffer_slice.map_async(wgpu::MapMode::Read, move |v| sender.send(v).unwrap());
    device.poll(wgpu::Maintain::Wait);

    if let Ok(Ok(())) = receiver.recv_async().await {
        // get buffer content
        let data = read_buffer_slice.get_mapped_range();
        let result = bytemuck::cast_slice(&data).to_vec();
        drop(data);
        read_buffer.unmap(); 
        println!("result = {:?}", result);
        Some(result)
    } else {
        panic!("failed to run compute on gpu!")
    }
}


fn main() {
    env_logger::init();
    pollster::block_on(run());
}