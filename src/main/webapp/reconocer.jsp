<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verificación de Rostro</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">

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
            max-width: 700px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.9);
        }

        h2 {
            font-size: 38px;
            font-weight: bold;
            margin-bottom: 20px;
        }

        p {
            font-size: 18px;
            color: #dce6ef;
            margin-bottom: 25px;
        }

        .foto-preview {
            width: 100%;
            max-width: 420px;
            border-radius: 20px;
            border: 3px solid rgba(255,255,255,0.08);
            margin-bottom: 25px;
        }

        .btn-custom {
            display: inline-block;
            padding: 12px 24px;
            border-radius: 25px;
            font-size: 16px;
            font-weight: bold;
            color: white;
            text-decoration: none;
            margin: 8px;
        }

        .btn-volver {
            background: linear-gradient(45deg, #28a745, #00c851);
        }

        .btn-registro {
            background: linear-gradient(45deg, #ff9800, #ff5722);
        }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Resultado de verificación</h2>

<%
String foto = request.getParameter("foto_verificacion");

if (foto == null || foto.trim().equals("")) {
%>
    <div class="alert alert-danger">no se recibió ninguna imagen para verificar.</div>
<%
} else {
%>
    <p>la imagen fue capturada correctamente.</p>
    <img src="<%= foto %>" class="foto-preview" alt="captura">

    <div class="alert alert-info">
        siguiente paso: conectar esta imagen con la comparación facial real contra la base de datos.
    </div>
<%
}
%>

    <a href="index.jsp" class="btn-custom btn-volver">Volver al inicio</a>
    <a href="registro.jsp" class="btn-custom btn-registro">Ir a registrar</a>
</div>

</body>

