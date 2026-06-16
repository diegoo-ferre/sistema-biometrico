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

        .btn-registro { background: linear-gradient(30deg, #4225a3, #000738); }
        .btn-lista { background: linear-gradient(30deg, #4225a3, #000738); }
        .btn-salarios { background: linear-gradient(35deg, #4225a3, #000738); }
        .btn-dashboard { background: linear-gradient(40deg, #4225a3, #000738); }
        .btn-asistencias { background: linear-gradient(50deg, #4225a3, #000738); }
        .btn-salario-base { background: linear-gradient(55deg, #4225a3, #000738); }
        .btn-descuentos { background: linear-gradient(50deg, #4225a3, #000738); }
        .btn-liquidacion { background: linear-gradient(45deg, #4225a3, #000738); }
        .btn-usuarios { background: linear-gradient(40deg, #4225a3, #000738); }
        .btn-configurar { background: linear-gradient(40deg, #4225a3, #000738); }
        .btn-volver { background: linear-gradient(35deg, #4225a3, #000738); }
        .btn-cerrar { background: linear-gradient(35deg, #f74040, #f50404); }

    </style>
</head>

<body>

<div class="contenedor">

    <h1>Panel Administrador</h1>
    
    <a href="registro.jsp" class="btn-custom btn-registro">Registrar persona</a>

    <a href="lista.jsp" class="btn-custom btn-lista">Ver registros</a>

    <a href="salario_base.jsp" class="btn-custom btn-salario-base">Asignar sueldo base</a>
    
    <a href="motivos_descuento.jsp" class="btn-custom btn-descuentos">Motivos de descuento</a>

    <a href="aplicar_descuentos.jsp" class="btn-custom btn-descuentos">Aplicar descuentos</a>
    
    <a href="editar_salario_guardado.jsp" class="btn-custom btn-salarios">Gestión de salarios</a>
    
    <a href="ver_accesos.jsp" class="btn-custom btn-asistencias">Ver accesos</a>
    
    <a href="configurar_horario.jsp" class="btn-custom btn-configurar">Configurar Horario</a>
    
    <a href="dashboard.jsp" class="btn-custom btn-dashboard">Ver dashboard</a>

    <a href="liquidacion_mensual.jsp" class="btn-custom btn-liquidacion">Liquidación mensual</a>

    <a href="logout.jsp" class="btn-custom btn-cerrar">Cerrar sesión</a>

</div>

</body>
</html>