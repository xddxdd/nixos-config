use axum::{
    extract::Path,
    http::StatusCode,
    response::Html,
    routing::{get, post},
    Json, Router,
};
use clap::Parser;
use libpulse_binding::volume::{ChannelVolumes, Volume};
use pulsectl::controllers::types::DeviceInfo;
use pulsectl::controllers::DeviceControl;
use pulsectl::controllers::SinkController;
use serde::{Deserialize, Serialize};

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// Address to listen on (e.g. 0.0.0.0:8080, unix:/tmp/sock, or sd-listen)
    #[arg(short, long, default_value = "0.0.0.0:8080")]
    listen: tokio_listener::ListenerAddress,
}

#[derive(Debug, Clone, Serialize)]
struct Sink {
    index: u32,
    name: String,
    description: String,
    volume: f32,
    muted: bool,
    channels: u8,
}

#[derive(Debug, Deserialize)]
struct VolumeRequest {
    volume: f32,
}

const HTML_PAGE: &str = r#"<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PipeWire Volume Control</title>
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #1a1a2e;
            color: #eee;
            padding: 20px;
            max-width: 600px;
            margin: 0 auto;
        }
        h1 { color: #4a9eff; margin-bottom: 30px; }
        .sink {
            background: #16213e;
            padding: 20px;
            margin-bottom: 15px;
        }
        .sink-name {
            font-size: 14px;
            color: #888;
            margin-bottom: 5px;
        }
        .sink-desc {
            font-size: 18px;
            font-weight: 500;
            margin-bottom: 15px;
        }
        .sink.muted .sink-desc {
            color: #666;
        }
        .volume-row {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        input[type="range"] {
            flex: 1;
            height: 8px;
            -webkit-appearance: none;
            background: #0f3460;
            outline: none;
        }
        input[type="range"]::-webkit-slider-thumb {
            -webkit-appearance: none;
            width: 20px;
            height: 20px;
            background: #4a9eff;
            cursor: pointer;
        }
        input[type="number"] {
            width: 70px;
            padding: 5px;
            background: #0f3460;
            border: 1px solid #4a9eff;
            color: #eee;
            text-align: center;
            font-size: 14px;
        }
        .no-sinks {
            text-align: center;
            color: #666;
            padding: 40px;
        }
        .refresh-row {
            text-align: center;
            margin-bottom: 20px;
        }
        .refresh-row button {
            padding: 10px 30px;
            background: #4a9eff;
            border: none;
            color: #fff;
            font-size: 16px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <h1>🔊 PipeWire Volume Control</h1>
    <div class="refresh-row"><button onclick="fetchSinks()">Refresh</button></div>
    <div id="sinks"></div>
    <script>
        async function fetchSinks() {
            try {
                const res = await fetch('/api/sinks');
                const sinks = await res.json();
                sinks.sort((a, b) => a.name.localeCompare(b.name));
                renderSinks(sinks);
            } catch (e) {
                console.error('Failed to fetch sinks:', e);
            }
        }

        function renderSinks(sinks) {
            const container = document.getElementById('sinks');
            if (sinks.length === 0) {
                container.innerHTML = '<div class="no-sinks">No audio sinks found</div>';
                return;
            }
            container.innerHTML = sinks.map(sink => `
                <div class="sink ${sink.muted ? 'muted' : ''}">
                    <div class="sink-name">${escapeHtml(sink.name)}</div>
                    <div class="sink-desc">${escapeHtml(sink.description)}${sink.muted ? ' (Muted)' : ''}</div>
                    <div class="volume-row">
                        <input type="range" min="0" max="150" value="${Math.round(sink.volume)}"
                            onchange="setVolume(${sink.index}, this.value, ${sink.channels})"
                            oninput="updateFromSlider(this)">
                        <input type="number" min="0" max="150" value="${Math.round(sink.volume)}"
                            onkeydown="handleVolumeKey(event, ${sink.index}, this, ${sink.channels})">%
                    </div>
                </div>
            `).join('');
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        function updateFromSlider(slider) {
            const input = slider.parentElement.querySelector('input[type="number"]');
            input.value = slider.value;
        }

        function handleVolumeKey(event, sinkIndex, input, channels) {
            if (event.key === 'Enter') {
                setVolume(sinkIndex, input.value, channels);
                const slider = input.parentElement.querySelector('input[type="range"]');
                slider.value = input.value;
            }
        }

        async function setVolume(index, percent, channels) {
            try {
                await fetch(`/api/sinks/${index}/volume`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ volume: parseFloat(percent) })
                });
            } catch (e) {
                console.error('Failed to set volume:', e);
            }
        }

        fetchSinks();
    </script>
</body>
</html>"#;

fn device_to_sink(dev: &DeviceInfo) -> Sink {
    let avg_volume = dev.volume.avg().0 as f32 / Volume::NORMAL.0 as f32 * 100.0;

    Sink {
        index: dev.index,
        name: dev.name.clone().unwrap_or_default(),
        description: dev.description.clone().unwrap_or_default(),
        volume: avg_volume,
        muted: dev.mute,
        channels: dev.volume.len() as u8,
    }
}

#[tokio::main]
async fn main() {
    let args = Args::parse();

    let app = Router::new()
        .route("/", get(index_handler))
        .route("/api/sinks", get(get_sinks))
        .route("/api/sinks/:index/volume", post(set_volume));

    let listener = tokio_listener::Listener::bind(
        &args.listen,
        &tokio_listener::SystemOptions::default(),
        &tokio_listener::UserOptions::default(),
    )
    .await
    .unwrap();

    println!("Server running at {}", args.listen);

    tokio_listener::axum07::serve(listener, app.into_make_service())
        .await
        .unwrap();
}

async fn index_handler() -> Html<&'static str> {
    Html(HTML_PAGE)
}

async fn get_sinks() -> Result<Json<Vec<Sink>>, StatusCode> {
    let sinks = tokio::task::spawn_blocking(|| {
        let mut controller =
            SinkController::create().map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
        let devices = controller
            .list_devices()
            .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
        let sinks: Vec<Sink> = devices.iter().map(device_to_sink).collect();
        Ok::<_, StatusCode>(sinks)
    })
    .await
    .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)??;

    Ok(Json(sinks))
}

async fn set_volume(Path(index): Path<u32>, Json(req): Json<VolumeRequest>) -> StatusCode {
    let volume_percent = req.volume.clamp(0.0, 150.0);

    let result = tokio::task::spawn_blocking(move || {
        let mut controller = SinkController::create().ok()?;

        let device = controller.get_device_by_index(index).ok()?;
        let channel_count = device.volume.len() as u8;

        let vol_value = (volume_percent / 100.0 * Volume::NORMAL.0 as f32) as u32;
        let mut volumes = ChannelVolumes::default();
        volumes.set(channel_count, Volume(vol_value));

        controller.set_device_volume_by_index(index, &volumes);
        Some(())
    })
    .await;

    match result {
        Ok(Some(_)) => StatusCode::OK,
        _ => StatusCode::INTERNAL_SERVER_ERROR,
    }
}
