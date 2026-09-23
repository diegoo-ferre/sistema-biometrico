<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.ZonedDateTime" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
String mensaje = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String nombre = request.getParameter("nombre");
    String ci = request.getParameter("ci");
    String correo = request.getParameter("correo");
    String telefono = request.getParameter("telefono");
    String direccion = request.getParameter("direccion");
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
        
        // Obtenemos la hora exacta en Asunción y la formateamos directamente como texto plano
        ZonedDateTime fechaAsuncion = ZonedDateTime.now(ZoneId.of("America/Asuncion"));
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
        String fechaTexto = fechaAsuncion.format(formatter);

        // SQL 1: Guardar persona enviando la fecha ya convertida en texto plano
        String sqlPersona = "INSERT INTO personas(nombre, ci, correo, telefono, direccion, fecha_registro, foto1, foto2, foto3, foto4, foto5) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        // SQL 2: Crear usuario (Usuario = Nombre, Password = CI)
        String sqlUsuario = "INSERT INTO usuarios(usuario, password, rol, ci) VALUES (?, ?, 'empleado', ?)";

        try {
            Class.forName("org.postgresql.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                conn.setAutoCommit(false); 

                try (PreparedStatement psP = conn.prepareStatement(sqlPersona);
                     PreparedStatement psU = conn.prepareStatement(sqlUsuario)) {
                    
                    psP.setString(1, nombre);
                    psP.setString(2, ci);
                    psP.setString(3, correo);
                    psP.setString(4, telefono);
                    psP.setString(5, direccion);
                    psP.setString(6, fechaTexto); // <--- Guardamos el texto plano directamente
                    psP.setString(7, fotos[0]);
                    psP.setString(8, fotos[1]);
                    psP.setString(9, fotos[2]);
                    psP.setString(10, fotos[3]);
                    psP.setString(11, fotos[4]);
                    psP.executeUpdate();

                    psU.setString(1, nombre); 
                    psU.setString(2, ci); 
                    psU.setString(3, ci);
                    psU.executeUpdate();

                    conn.commit();
                    mensaje = "Registro guardado. Usuario: " + nombre + " / Contraseña: " + ci;
                } catch (SQLException e) {
                    conn.rollback();
                    mensaje = "Error al guardar: " + e.getMessage();
                }
            }
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
    <title>Registro Biométrico</title>
    <style>
        body { margin: 0; min-height: 100vh; font-family: Arial, sans-serif; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); display: flex; justify-content: center; align-items: center; padding: 20px; }
        .contenedor { background: rgba(10, 15, 25, 0.88); padding: 40px 35px; border-radius: 30px; text-align: center; color: white; width: 100%; max-width: 760px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        .camera-box { margin: 0 auto 25px auto; width: 100%; max-width: 520px; border-radius: 22px; overflow: hidden; border: 3px solid rgba(255,255,255,0.08); background: #000; }
        video { width: 100%; display: block; }
        input[type="text"], input[type="email"], input[type="tel"] { width: 100%; max-width: 400px; padding: 14px; border-radius: 15px; border: none; margin-bottom: 20px; font-size: 16px; outline: none; }
        .btn-custom { display: block; width: 100%; max-width: 360px; margin: 12px auto; padding: 14px 20px; border: none; border-radius: 30px; color: white; font-size: 18px; font-weight: bold; cursor: pointer; transition: 0.3s ease; }
        .btn-custom:hover { transform: scale(1.03); }
        .btn-captura, .btn-guardar { background: linear-gradient(35deg, #4225a3, #000738); }
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); text-decoration: none; }
        .mensaje { margin-bottom: 20px; font-size: 18px; font-weight: bold; color: #96ff96; }
        .icon10 { filter: brightness(0) invert(1); }
        canvas { display: none; }
    </style>
</head>
<body>
<div class="contenedor">
    <img src="img/reconocimiento-facial.png" class="icon10">
    <p>Complete los datos y capture 5 fotos para registrar al empleado.</p>
    <% if (!mensaje.equals("")) { %> <div class="mensaje"><%= mensaje %></div> <% } %>
    <form method="post" onsubmit="return validarFotos();">
        <input type="text" name="nombre" id="nombre" placeholder="Nombre completo" required>
        <input type="text" name="ci" id="ci" placeholder="Número de CI" required>
        <input type="email" name="correo" id="correo" placeholder="Correo electrónico">
        <input type="tel" name="telefono" id="telefono" placeholder="Número de teléfono">
        <input type="text" name="direccion" id="direccion" placeholder="Dirección">
        <div class="camera-box"> <video id="video" autoplay playsinline muted></video> </div>
        <button type="button" class="btn-custom btn-captura" onclick="capturar()">Capturar Foto</button>
        <div id="contador">Fotos capturadas: 0 / 5</div>
        <input type="hidden" name="foto1" id="foto1"><input type="hidden" name="foto2" id="foto2">
        <input type="hidden" name="foto3" id="foto3"><input type="hidden" name="foto4" id="foto4">
        <input type="hidden" name="foto5" id="foto5">
        <canvas id="canvas"></canvas>
        <button type="submit" class="btn-custom btn-guardar">Guardar Registro y Crear Usuario</button>
        <a href="admin.jsp" class="btn-custom btn-volver">Volver al Inicio</a>
    </form>
</div>
<script>
    let contador = 0;
    const video = document.getElementById("video");
    navigator.mediaDevices.getUserMedia({ video: true }).then(stream => { video.srcObject = stream; }).catch(e => alert("Cámara no disponible"));
    function capturar() {
        if (contador >= 5) { alert("Ya capturaste las 5 fotos"); return; }
        const canvas = document.getElementById("canvas");
        canvas.width = video.videoWidth; canvas.height = video.videoHeight;
        canvas.getContext("2d").drawImage(video, 0, 0);
        document.getElementById("foto" + (++contador)).value = canvas.toDataURL("image/jpeg", 0.4);
        document.getElementById("contador").innerText = "Fotos capturadas: " + contador + " / 5";
    }
    function validarFotos() { if (contador < 5) { alert("Debe capturar 5 fotos"); return false; } return true; }
</script>
</body>
</html>
