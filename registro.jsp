<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Persona</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">

    <style>
        body {
            margin: 0;
            min-height: 100vh;
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a);
        }

        .navbar-custom {
            background: rgba(10, 10, 10, 0.9);
            box-shadow: 0 4px 15px rgba(0,0,0,0.5);
        }

        .navbar-brand {
            font-weight: bold;
            font-size: 28px;
            color: white !important;
            width: 100%;
            text-align: center;
        }

        .hero-section {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 30px 15px;
        }

        .form-box {
            background: rgba(10, 15, 25, 0.85);
            border: 1px solid rgba(255,255,255,0.08);
            backdrop-filter: blur(15px);
            border-radius: 25px;
            padding: 40px 35px;
            text-align: center;
            color: white;
            box-shadow: 0 10px 40px rgba(0,0,0,0.9);
        }

        .logo-img {
            width: 120px;
            filter: drop-shadow(0 0 20px rgba(255,255,255,0.6));
            margin-bottom: 15px;
            animation: flotar 3s ease-in-out infinite;
        }

        @keyframes flotar {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-8px); }
            100% { transform: translateY(0px); }
        }

        .titulo {
            font-size: 42px;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .subtexto {
            color: #d0d8df;
            margin-bottom: 25px;
            font-size: 17px;
        }

        .form-control {
            border-radius: 12px;
            padding: 12px;
        }

        label {
            font-weight: 600;
            text-align: left;
            display: block;
            margin-bottom: 6px;
        }

        .btn-custom {
            border-radius: 30px;
            padding: 12px 28px;
            font-size: 17px;
            font-weight: 600;
            transition: 0.3s;
            border: none;
        }

        .btn-custom:hover {
            transform: translateY(-2px);
        }

        .btn-primary {
            background: linear-gradient(45deg, #007bff, #00c6ff);
        }

        .btn-success {
            background: linear-gradient(45deg, #28a745, #5eff8a);
        }

        .btn-secondary {
            background: linear-gradient(45deg, #6c757d, #9aa3ab);
        }

        .botones {
            display: flex;
            justify-content: center;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 20px;
        }

        .foto-box {
            margin-top: 20px;
            padding: 18px;
            border-radius: 15px;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.08);
        }

        .foto-texto {
            color: #d0d8df;
            margin-bottom: 10px;
        }

        video {
            width: 320px;
            height: 240px;
            border-radius: 15px;
            border: 2px solid rgba(255,255,255,0.1);
            margin-bottom: 15px;
        }

        .galeria-fotos {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 10px;
            margin-top: 15px;
        }

        .galeria-fotos img {
            width: 100%;
            height: 100px;
            object-fit: cover;
            border-radius: 12px;
            border: 2px solid rgba(255,255,255,0.1);
        }

        .contador {
            margin-top: 10px;
            font-weight: bold;
            color: #ffffff;
        }
    </style>
</head>
<body>

<%
    String mensaje = null;
    String error = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String nombre = request.getParameter("nombre");
        String ci = request.getParameter("ci");
        String foto1 = request.getParameter("foto1");
        String foto2 = request.getParameter("foto2");
        String foto3 = request.getParameter("foto3");
        String foto4 = request.getParameter("foto4");
        String foto5 = request.getParameter("foto5");

        Connection con = null;
        PreparedStatement ps = null;

        try {
            Class.forName("org.postgresql.Driver");

            String url = "jdbc:postgresql://127.0.0.1:5432/biometrico";
            String usuario = "postgres";
            String clave = "1234";

            con = DriverManager.getConnection(url, usuario, clave);

            ps = con.prepareStatement(
                "INSERT INTO personas(nombre, ci, foto1, foto2, foto3, foto4, foto5) VALUES (?, ?, ?, ?, ?, ?, ?)"
            );

            ps.setString(1, nombre);
            ps.setString(2, ci);
            ps.setString(3, foto1);
            ps.setString(4, foto2);
            ps.setString(5, foto3);
            ps.setString(6, foto4);
            ps.setString(7, foto5);

            ps.executeUpdate();

            mensaje = "Registro guardado correctamente.";
        } catch (Exception e) {
            error = "Error al guardar: " + e.getMessage();
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
%>

<nav class="navbar navbar-dark navbar-custom">
    <span class="navbar-brand">Registro de Persona</span>
</nav>

<section class="hero-section">
    <div class="form-box col-lg-8">

        <img src="img/loogoproyecto.png" class="logo-img" alt="Logo">

        <h1 class="titulo">Registro</h1>
        <p class="subtexto">
            Ingresá tus datos y capturá 5 fotos para registrar correctamente a la persona.
        </p>

        <% if (mensaje != null) { %>
            <div class="alert alert-success"><%= mensaje %></div>
        <% } %>

        <% if (error != null) { %>
            <div class="alert alert-danger"><%= error %></div>
        <% } %>

        <form method="post">
            <div class="form-group text-left">
                <label for="nombre">Nombre completo</label>
                <input type="text" class="form-control" id="nombre" name="nombre"
                       pattern="[A-Za-zÁÉÍÓÚáéíóúñÑ ]+" title="Solo letras" required>
            </div>

            <div class="form-group text-left">
                <label for="ci">CI</label>
                <input type="text" class="form-control" id="ci" name="ci"
                       pattern="[0-9]+" title="Solo números" required>
            </div>

            <div class="foto-box">
                <p class="foto-texto">
                    Iniciá la cámara y tomá 5 fotos desde distintos ángulos.
                </p>

                <video id="video" autoplay></video>
                <canvas id="canvas" width="320" height="240" style="display:none;"></canvas>

                <div class="botones">
                    <button type="button" class="btn btn-secondary btn-custom" onclick="iniciarCamara()">Iniciar cámara</button>
                    <button type="button" class="btn btn-primary btn-custom" onclick="capturarFoto()">Tomar foto</button>
                </div>

                <div class="contador" id="contadorFotos">Fotos capturadas: 0 / 5</div>

                <div class="galeria-fotos" id="galeriaFotos"></div>

                <input type="hidden" name="foto1" id="foto1">
                <input type="hidden" name="foto2" id="foto2">
                <input type="hidden" name="foto3" id="foto3">
                <input type="hidden" name="foto4" id="foto4">
                <input type="hidden" name="foto5" id="foto5">
            </div>

            <div class="botones">
                <button type="submit" class="btn btn-success btn-custom">Guardar registro</button>
                <a href="index.jsp" class="btn btn-primary btn-custom">Volver al inicio</a>
            </div>
        </form>

    </div>
</section>

<script>
document.getElementById("nombre").addEventListener("input", function () {
    this.value = this.value.replace(/[^A-Za-zÁÉÍÓÚáéíóúñÑ ]/g, '');
});

document.getElementById("ci").addEventListener("input", function () {
    this.value = this.value.replace(/[^0-9]/g, '');
});

let streamActual = null;
let contador = 0;

function iniciarCamara() {
    const video = document.getElementById("video");

    navigator.mediaDevices.getUserMedia({ video: true })
        .then(function(stream) {
            streamActual = stream;
            video.srcObject = stream;
        })
        .catch(function(error) {
            alert("No se pudo acceder a la cámara: " + error);
        });
}

function capturarFoto() {
    if (contador >= 5) {
        alert("Ya capturaste las 5 fotos.");
        return;
    }

    const video = document.getElementById("video");
    const canvas = document.getElementById("canvas");
    const galeria = document.getElementById("galeriaFotos");
    const contadorFotos = document.getElementById("contadorFotos");

    const contexto = canvas.getContext("2d");
    contexto.drawImage(video, 0, 0, canvas.width, canvas.height);

    const imagenData = canvas.toDataURL("image/png");
    contador++;

    document.getElementById("foto" + contador).value = imagenData;

    const img = document.createElement("img");
    img.src = imagenData;
    galeria.appendChild(img);

    contadorFotos.textContent = "Fotos capturadas: " + contador + " / 5";
}
</script>

</body>
</html>