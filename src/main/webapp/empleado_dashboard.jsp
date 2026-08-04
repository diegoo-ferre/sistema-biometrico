<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
// Verificamos que el usuario haya iniciado sesión
if (session.getAttribute("usuario") == null) { 
    response.sendRedirect("login.jsp"); 
    return; 
}
String nombreUsuario = (String) session.getAttribute("usuario");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel Empleado</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <style>
        body { background: #050a0f; color: white; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; font-family: Arial, sans-serif; }
        .contenedor { background: rgba(10, 15, 25, 0.9); padding: 40px; border-radius: 30px; text-align: center; width: 100%; max-width: 400px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        h1 { font-size: 24px; margin-bottom: 25px; }
        .bienvenido { color: #dce6ef; margin-bottom: 20px; font-size: 18px; }
        .btn-custom { display: block; width: 100%; padding: 15px; margin: 10px 0; border-radius: 30px; color: white; text-decoration: none; font-weight: bold; background: linear-gradient(30deg, #4225a3, #000738); transition: 0.3s; }
        .btn-custom:hover { transform: scale(1.03); color: white; text-decoration: none; }
    </style>
</head>
<body>
<div class="contenedor">
    <h1>Panel del Empleado</h1>
    <p class="bienvenido">Hola, <strong><%= nombreUsuario %></strong></p>
    
    <a href="index.jsp" class="btn-custom">Marcar Asistencia</a>
    <a href="ver_accesos.jsp" class="btn-custom">Ver mis marcaciones</a>
    <a href="logout.jsp" class="btn-custom" style="background: linear-gradient(35deg, #f74040, #f50404);">Cerrar sesión</a>
</div>
</body>
</html>