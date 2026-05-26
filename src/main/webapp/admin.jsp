<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires", 0);

// 🔐 CONTROL DE SESIÓN
if (session == null || session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

// 🔐 CONTROL DE ROL
String rol = (String) session.getAttribute("rol");

if (rol == null || !"admin".equals(rol)) {
    response.sendRedirect("index.jsp");
    return;
}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Administrador</title>

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
            font-size: 42px;
            margin-bottom: 20px;
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
        }

        .btn-custom:hover {
            transform: scale(1.03);
            color: white;
            text-decoration: none;
        }

        .btn-lista { background: linear-gradient(45deg, #2193b0, #6dd5ed); }
        .btn-salarios { background: linear-gradient(45deg, #f39c12, #f1c40f); }
        .btn-dashboard { background: linear-gradient(45deg, #5e35b1, #8e24aa); }
        .btn-asistencias { background: linear-gradient(45deg, #6c5ce7, #a29bfe); }
        .btn-salario-base { background: linear-gradient(45deg, #00b894, #00cec9); }
        .btn-descuentos { background: linear-gradient(45deg, #6c5ce7, #a29bfe); }
        .btn-liquidacion { background: linear-gradient(45deg, #00b894, #55efc4); }
        .btn-usuarios { background: linear-gradient(45deg, #e17055, #fab1a0); }
        .btn-volver { background: linear-gradient(45deg, #636e72, #b2bec3); }
        .btn-cerrar { background: linear-gradient(45deg, #dc3545, #ff6b81); }

    </style>
</head>

<body>

<div class="contenedor">

    <h1>Panel Administrador</h1>

    <a href="lista.jsp" class="btn-custom btn-lista">Ver registros</a>

    <a href="salarios.jsp" class="btn-custom btn-salarios">Gestión de salarios</a>

    <a href="dashboard.jsp" class="btn-custom btn-dashboard">Ver dashboard</a>

    <a href="ver_accesos.jsp" class="btn-custom btn-asistencias">Ver accesos</a>

    <a href="ver_asistencias.jsp" class="btn-custom btn-asistencias">Ver asistencias</a>

    <a href="salario_base.jsp" class="btn-custom btn-salario-base">Asignar sueldo base</a>

    <a href="motivos_descuento.jsp" class="btn-custom btn-descuentos">Motivos de descuento</a>

    <a href="aplicar_descuentos.jsp" class="btn-custom btn-descuentos">Aplicar descuentos</a>

    <a href="liquidacion_mensual.jsp" class="btn-custom btn-liquidacion">Liquidación mensual</a>

    <a href="logout.jsp" class="btn-custom btn-cerrar">Cerrar sesión</a>

</div>

</body>
</html>