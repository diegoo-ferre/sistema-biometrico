<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires", 0);

if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

String rol = (String) session.getAttribute("rol");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sistema Biométrico</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <style>
        body { margin: 0; min-height: 100vh; font-family: Arial, sans-serif; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); display: flex; justify-content: center; align-items: center; padding: 20px; }
        .contenedor { background: rgba(10, 15, 25, 0.88); padding: 40px 35px; border-radius: 30px; text-align: center; color: white; width: 100%; max-width: 760px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        h1 { font-size: 44px; font-weight: bold; margin-bottom: 15px; }
        p { font-size: 18px; color: #dce6ef; margin-bottom: 25px; }
        .camera-box { margin: 0 auto 15px auto; width: 100%; max-width: 520px; border-radius: 22px; overflow: hidden; border: 3px solid rgba(255,255,255,0.08); box-shadow: 0 8px 25px rgba(0,0,0,0.5); background: #000; }
        video { width: 100%; display: block; }
        .estado-camara, .estado-gps { margin-top: 5px; margin-bottom: 15px; font-size: 14px; color: #cfd8dc; }
        .form-group-turno { max-width: 360px; margin: 0 auto 15px auto; text-align: left; }
        .form-control { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: white; border-radius: 15px; padding: 12px; }
        .form-control option { background: #0b1f2a; color: white; }
        .btn-custom { display: block; width: 100%; max-width: 360px; margin: 12px auto; padding: 14px 20px; border: none; border-radius: 30px; color: white; font-size: 18px; font-weight: bold; text-decoration: none; transition: 0.3s ease; cursor: pointer; }
        .btn-custom:hover { transform: scale(1.03); color: white; text-decoration: none; }
        .btn-verificar { background: linear-gradient(70deg, #4225a3, #000738); }
        .btn-cerrar { background: linear-gradient(30deg, #f74040, #f50404); }
        canvas { display: none; }
    </style>
</head>
<body>

<div class="contenedor">
    <h1>Bienvenido</h1>
    <p>Sistema biométrico activo</p>
    <div class="camera-box">
        <video id="video" autoplay playsinline muted></video>
    </div>
    <div class="estado-camara" id="estadoCamara">iniciando cámara...</div>
    <div class="estado-gps" id="estadoGps">obteniendo ubicación GPS...</div>
    <canvas id="canvas"></canvas>

    <div class="form-group-turno">
        <label for="turnoSelect"><strong>Seleccione su Turno:</strong></label>
        <select id="turnoSelect" class="form-control" required>
            <option value="">-- Seleccione un Turno --</option>
            <%
            Connection con = null;
            try {
                Class.forName("org.postgresql.Driver");
                con = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");
                Statement st = con.createStatement();
                ResultSet rs = st.executeQuery("SELECT id, nombre FROM turnos ORDER BY id");
                while(rs.next()) {
                    out.println("<option value='" + rs.getInt("id") + "'>" + rs.getString("nombre") + "</option>");
                }
                rs.close();
                st.close();
            } catch(Exception e) {
                out.println("<option value=''>Error al cargar turnos</option>");
            } finally {
                if(con != null) con.close();
            }
            %>
        </select>
    </div>

    <button type="button" class="btn-custom btn-verificar" onclick="verificarRostro()">
        Verificar rostro
    </button>

    <div id="resultadoReconocimiento" style="margin-top:20px;"></div>

    <a href="logout.jsp" class="btn-custom btn-cerrar">Cerrar sesión</a>
</div>

<script>
const video = document.getElementById("video");
const canvas = document.getElementById("canvas");
const estadoCamara = document.getElementById("estadoCamara");
const estadoGps = document.getElementById("estadoGps");
const resultadoReconocimiento = document.getElementById("resultadoReconocimiento");
const turnoSelect = document.getElementById("turnoSelect");

// Coordenadas del lugar de trabajo permitidas
const LATITUD_DESTINO = -25.339111;
const LONGITUD_DESTINO = -57.523444;
const RADIO_MAXIMO_KM = 1.0; 

let ubicacionActual = null;

// Activar cámara
navigator.mediaDevices.getUserMedia({ video: true })
.then(function(stream) {
    video.srcObject = stream;
    estadoCamara.innerText = "cámara activa";
})
.catch(function(error) {
    estadoCamara.innerText = "no se pudo acceder a la cámara";
});

// Obtener GPS del dispositivo en tiempo real
if (navigator.geolocation) {
    navigator.geolocation.watchPosition(
        function(position) {
            ubicacionActual = {
                lat: position.coords.latitude,
                lon: position.coords.longitude
            };
            let distancia = calcularDistancia(ubicacionActual.lat, ubicacionActual.lon, LATITUD_DESTINO, LONGITUD_DESTINO);
            if (distancia <= RADIO_MAXIMO_KM) {
                estadoGps.innerHTML = '<span style="color: #4cd137;">📍 Ubicación válida (A ' + (distancia * 1000).toFixed(0) + ' metros del puesto)</span>';
            } else {
                estadoGps.innerHTML = '<span style="color: #ff4757;">📍 Fuera de rango (Estás a ' + distancia.toFixed(2) + ' km del puesto autorizado)</span>';
            }
        },
        function(error) {
            estadoGps.innerHTML = '<span style="color: #ff4757;">⚠️ Error de GPS: Activa la ubicación en tu dispositivo.</span>';
        },
        { enableHighAccuracy: true, maximumAge: 10000, timeout: 20000 }
    );
} else {
    estadoGps.innerText = "el navegador no soporta geolocalización.";
}

function calcularDistancia(lat1, lon1, lat2, lon2) {
    const R = 6371; 
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = 
        Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
        Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
}

async function verificarRostro() {
    if (!video.srcObject) {
        alert("la cámara no está disponible.");
        return;
    }

    if (!turnoSelect.value) {
        alert("por favor, seleccione su turno antes de verificar.");
        turnoSelect.focus();
        return;
    }

    if (!ubicacionActual) {
        alert("esperando señal de GPS. Asegúrate de dar permisos de ubicación a tu navegador.");
        return;
    }

    const distanciaFinal = calcularDistancia(ubicacionActual.lat, ubicacionActual.lon, LATITUD_DESTINO, LONGITUD_DESTINO);
    if (distanciaFinal > RADIO_MAXIMO_KM) {
        resultadoReconocimiento.innerHTML = '<div class="alert alert-danger"><strong>Acceso denegado:</strong> Estás fuera del área permitida para marcar asistencia (más de 1 km de distancia).</div>';
        return;
    }

    const context = canvas.getContext("2d");
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    context.drawImage(video, 0, 0, canvas.width, canvas.height);
    const imagenBase64 = canvas.toDataURL("image/jpeg", 0.4);
    const turnoSeleccionado = turnoSelect.value;

    resultadoReconocimiento.innerHTML = '<div class="alert alert-info">verificando ubicación y rostro...</div>';

    try {
        // REEMPLAZA ESTA URL CON TU ENLACE ACTIVO DE FLASK EN RENDER
        const respuesta = await fetch("https://reconocimiento-flask-2.onrender.com/reconocer", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ foto: imagenBase64, turno_id: turnoSeleccionado })
        });
        const data = await respuesta.json();
        if (data.resultado === "permitido") {
            resultadoReconocimiento.innerHTML = 
                '<div class="alert alert-success">' +
                    '<strong>¡Asistencia marcada con éxito!</strong><br><br>' +
                    '<strong>Nombre:</strong> ' + data.nombre + '<br>' +
                    '<strong>CI:</strong> ' + data.ci + '<br>' +
                    '<strong>Turno:</strong> ' + turnoSelect.options[turnoSelect.selectedIndex].text + '<br>' +
                    '<strong>Estado:</strong> ' + data.asistencia + 
                '</div>';
        } else if (data.resultado === "denegado") {
            resultadoReconocimiento.innerHTML = '<div class="alert alert-danger">persona no registrada.</div>';
        } else if (data.resultado === "sin_rostro") {
            resultadoReconocimiento.innerHTML = '<div class="alert alert-warning">no se detectó un rostro.</div>';
        } else {
            resultadoReconocimiento.innerHTML = '<div class="alert alert-danger">error: ' + data.mensaje + '</div>';
        }
    } catch (error) {
        resultadoReconocimiento.innerHTML = '<div class="alert alert-danger">no se pudo conectar con Flask en la nube.</div>';
    }
}
</script>
</body>
</html>
