<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires", 0);

// 🔐 CONTROL DE SESIÓN
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

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">

    <style>
        body {
            margin: 0;
            min-height: 100vh;
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a);
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .contenedor {
            background: rgba(10, 15, 25, 0.88);
            padding: 40px 35px;
            border-radius: 30px;
            text-align: center;
            color: white;
            width: 100%;
            max-width: 760px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.9);
        }

        h1 {
            font-size: 44px;
            font-weight: bold;
            margin-bottom: 15px;
        }

        p {
            font-size: 18px;
            color: #dce6ef;
            margin-bottom: 25px;
        }

        .camera-box {
            margin: 0 auto 25px auto;
            width: 100%;
            max-width: 520px;
            border-radius: 22px;
            overflow: hidden;
            border: 3px solid rgba(255,255,255,0.08);
            box-shadow: 0 8px 25px rgba(0,0,0,0.5);
            background: #000;
        }

        video {
            width: 100%;
            display: block;
        }

        .estado-camara {
            margin-top: 10px;
            margin-bottom: 20px;
            font-size: 15px;
            color: #cfd8dc;
        }

        .btn-custom {
            display: block;
            width: 100%;
            max-width: 360px;
            margin: 12px auto;
            padding: 14px 20px;
            border: none;
            border-radius: 30px;
            color: white;
            font-size: 18px;
            font-weight: bold;
            text-decoration: none;
            transition: 0.3s ease;
            cursor: pointer;
        }

        .btn-custom:hover {
            transform: scale(1.03);
            color: white;
            text-decoration: none;
        }

        .btn-verificar {
            background: linear-gradient(45deg, #7b1fa2, #9c27b0);
        }

        .btn-registro {
            background: linear-gradient(45deg, #00b09b, #96c93d);
        }

        .btn-admin {
            background: linear-gradient(45deg, #5e35b1, #8e24aa);
        }

        .btn-cerrar {
            background: linear-gradient(45deg, #dc3545, #ff6b81);
        }

        canvas {
            display: none;
        }
    </style>
</head>

<body>

<div class="contenedor">

    <h1>Bienvenido</h1>

    <p>Sistema biométrico activo</p>

    <div class="camera-box">
        <video id="video" autoplay playsinline muted></video>
    </div>

    <div class="estado-camara" id="estadoCamara">
        iniciando cámara...
    </div>

    <canvas id="canvas"></canvas>

    <button type="button"
            class="btn-custom btn-verificar"
            onclick="verificarRostro()">
        Verificar rostro
    </button>

    <div id="resultadoReconocimiento" style="margin-top:20px;"></div>

    <a href="registro.jsp"
       class="btn-custom btn-registro">
        Registrar persona
    </a>

    <% if ("admin".equals(rol)) { %>
        <a href="admin.jsp"
           class="btn-custom btn-admin">
            Panel administrador
        </a>
    <% } %>

    <a href="logout.jsp" class="btn-custom btn-cerrar">
        Cerrar sesión
    </a>

</div>

<script>
const video = document.getElementById("video");
const canvas = document.getElementById("canvas");
const estadoCamara = document.getElementById("estadoCamara");
const resultadoReconocimiento = document.getElementById("resultadoReconocimiento");

navigator.mediaDevices.getUserMedia({ video: true })
.then(function(stream) {
    video.srcObject = stream;
    estadoCamara.innerText = "cámara activa";
})
.catch(function(error) {
    estadoCamara.innerText = "no se pudo acceder a la cámara";
});

async function verificarRostro() {
    if (!video.srcObject) {
        alert("la cámara no está disponible.");
        return;
    }

    const context = canvas.getContext("2d");
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    context.drawImage(video, 0, 0, canvas.width, canvas.height);
    const imagenBase64 = canvas.toDataURL("image/jpeg", 0.4);

    resultadoReconocimiento.innerHTML = '<div class="alert alert-info">verificando rostro...</div>';

    try {
        const respuesta = await fetch("https://reconocimiento-flask-2.onrender.com/reconocer", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ foto: imagenBase64 })
        });

        const data = await respuesta.json();

        if (data.resultado === "permitido") {
            resultadoReconocimiento.innerHTML = 
                '<div class="alert alert-success">' +
                    '<strong>¡Acceso permitido!</strong><br><br>' +
                    '<strong>Nombre:</strong> ' + data.nombre + '<br>' +
                    '<strong>CI:</strong> ' + data.ci + '<br>' +
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