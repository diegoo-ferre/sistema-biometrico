<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
String mensaje = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String nombre = request.getParameter("nombre");
    String ci = request.getParameter("ci");
    String[] fotos = {
        request.getParameter("foto1"), request.getParameter("foto2"), 
        request.getParameter("foto3"), request.getParameter("foto4"), 
        request.getParameter("foto5")
    };

    if (nombre == null || nombre.trim().isEmpty() || ci == null || ci.trim().isEmpty()) {
        mensaje = "Debe completar nombre y CI.";
    } else if (fotos[0] == null || fotos[0].isEmpty()) {
        mensaje = "Debe capturar las 5 fotos.";
    } else {
        String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
        String user = "neondb_owner";
        String pass = "npg_6rt8OdayAHcm";
        String sql = "INSERT INTO personas(nombre, ci, fecha_registro, foto1, foto2, foto3, foto4, foto5) VALUES (?, ?, CURRENT_TIMESTAMP, ?, ?, ?, ?, ?)";

        try {
            // Asegúrate de que el jar de PostgreSQL esté en WEB-INF/lib
            Class.forName("org.postgresql.Driver"); 
            
            try (Connection conn = DriverManager.getConnection(url, user, pass);
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                
                ps.setString(1, nombre);
                ps.setString(2, ci);
                ps.setString(3, fotos[0]);
                ps.setString(4, fotos[1]);
                ps.setString(5, fotos[2]);
                ps.setString(6, fotos[3]);
                ps.setString(7, fotos[4]);

                ps.executeUpdate();
                mensaje = "Registro guardado correctamente.";
            }
        } catch (ClassNotFoundException e) {
            mensaje = "Error: Driver de PostgreSQL no encontrado.";
        } catch (SQLException e) {
            mensaje = "Error de base de datos: " + e.getMessage();
        } catch (Exception e) {
            mensaje = "Error general: " + e.getMessage();
        }
    }
}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro Biométrico</title>

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
            font-size: 42px;
            margin-bottom: 10px;
        }

        p {
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

        input[type="text"] {
            width: 100%;
            max-width: 400px;
            padding: 14px;
            border-radius: 15px;
            border: none;
            margin-bottom: 20px;
            font-size: 16px;
            outline: none;
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
            cursor: pointer;
            transition: 0.3s ease;
        }

        .btn-custom:hover {
            transform: scale(1.03);
        }

        .btn-captura {
            background: linear-gradient(35deg, #4225a3, #000738);
        }

        .btn-guardar {
            background: linear-gradient(35deg, #4225a3, #000738);
        }

        .btn-volver {
            background: linear-gradient(35deg, #f74040, #f50404);
            text-decoration: none;
            
        }

        .contador {
            margin-top: 15px;
            margin-bottom: 15px;
            font-size: 18px;
            color: #dce6ef;
        }

        .mensaje {
            margin-bottom: 20px;
            font-size: 18px;
            font-weight: bold;
            color: #96ff96;
        }

        canvas {
            display: none;
        }
           .icon10{
     filter: brightness(0) invert(1);
}

    </style>
</head>

<body>

<div class="contenedor">

    <img src="img/reconocimiento-facial.png" class="icon10"></img>

    <p>
        Complete los datos y capture 5 fotos del rostro
        para el reconocimiento facial.
    </p>

    <% if (!mensaje.equals("")) { %>

        <div class="mensaje">
            <%= mensaje %>
        </div>

    <% } %>

    <form method="post" onsubmit="return validarFotos();">


        <input type="text"
               name="nombre"
               id="nombre"
               placeholder="Nombre completo"
               required>


        <input type="text"
               name="ci"
               id="ci"
               placeholder="Número de CI"
               required>

        <div class="camera-box">
            <video id="video" autoplay playsinline muted></video>
        </div>

        <button type="button"
                class="btn-custom btn-captura"
                onclick="capturar()">

            Capturar Foto

        </button>

        <div class="contador" id="contador">
            Fotos capturadas: 0 / 5
        </div>

        <input type="hidden" name="foto1" id="foto1">
        <input type="hidden" name="foto2" id="foto2">
        <input type="hidden" name="foto3" id="foto3">
        <input type="hidden" name="foto4" id="foto4">
        <input type="hidden" name="foto5" id="foto5">

        <canvas id="canvas"></canvas>

        <button type="submit"
                class="btn-custom btn-guardar">

            Guardar Registro

        </button>

        <a href="index.jsp"
           class="btn-custom btn-volver">

            Volver al Inicio

        </a>

    </form>

</div>

<script>

let contador = 0;

const video = document.getElementById("video");

navigator.mediaDevices.getUserMedia({ video: true })
.then(stream => {

    video.srcObject = stream;

})
.catch(error => {

    alert("No se pudo acceder a la cámara");

});

function capturar() {

    if (contador >= 5) {

        alert("Ya capturaste las 5 fotos");
        return;
    }

    const canvas = document.getElementById("canvas");

    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;

    const ctx = canvas.getContext("2d");

    ctx.drawImage(video, 0, 0);


    const foto = canvas.toDataURL("image/jpeg", 0.4);

    contador++;

    document.getElementById("foto" + contador).value = foto;

    document.getElementById("contador").innerText =
        "Fotos capturadas: " + contador + " / 5";
}

function validarFotos() {

    if (contador < 5) {

        alert("Debe capturar las 5 fotos");
        return false;
    }

    return true;
}

</script>

</body>
</html>