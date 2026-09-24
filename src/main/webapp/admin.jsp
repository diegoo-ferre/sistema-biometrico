<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires", 0);

if (session == null || session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel Administrador</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        body { margin: 0; min-height: 100vh; background: #050a0f; font-family: Arial, sans-serif; color: white; display: flex; }
        
        .sidebar { width: 280px; background: rgba(10, 15, 25, 0.95); padding: 20px; border-right: 1px solid rgba(255,255,255,0.1); height: 100vh; position: fixed; overflow-y: auto; }
        .btn-referencial { width: 100%; text-align: left; background: rgba(66, 37, 163, 0.3); color: white; border: none; padding: 15px; border-radius: 10px; font-weight: bold; margin-bottom: 10px; }
        .btn-referencial:hover { background: linear-gradient(35deg,#4225a3, #000738); 
        color: white}
        .sub-menu a { display: block; color: #b0bec5; padding: 10px 20px; text-decoration: none; font-size: 14px; transition: 0.3s; }
        .sub-menu a:hover { color: white; background: rgba(255,255,255,0.05); }

        .main-content { margin-left: 280px; padding: 40px; flex-grow: 1; display: flex; justify-content: center; align-items: center; }
        .contenedor { background: rgba(10, 15, 25, 0.88); padding: 40px; border-radius: 30px; text-align: center; width: 100%; max-width: 600px; box-shadow: 0px 0px 50px rgba(0,0,0,0.5); }
        h1 { font-size: 36px; margin-bottom: 30px; }
        .btn-custom { display: block; width: 100%; max-width: 360px; margin: 10px auto; padding: 12px; border: none; border-radius: 30px; color: white; font-weight: bold; text-decoration: none; transition: 0.3s; background: linear-gradient(30deg, #4225a3, #000738); }
        .btn-custom:hover { transform: scale(1.03); color: white; text-decoration: none; }
        .btn-cerrar { background: linear-gradient(35deg, #f74040, #f50404); margin-top: 20px; }
        
       .fondo-animado {
    position: fixed;
    top: 0; left: 0;
    width: 100%; height: 100%;
    z-index: -1;
    overflow: hidden;
    pointer-events: none;
}

.logo-flotante {
    position: absolute;
    width: 80px; 
    opacity: 0.1;
    animation: flotar linear infinite;
}
.logo-flotante:nth-child(1) { top: 5%; left: 5%; animation-duration: 25s; }
.logo-flotante:nth-child(2) { top: 15%; left: 85%; animation-duration: 35s; }
.logo-flotante:nth-child(3) { top: 40%; left: 10%; animation-duration: 28s; }
.logo-flotante:nth-child(4) { top: 60%; left: 70%; animation-duration: 40s; }
.logo-flotante:nth-child(5) { top: 80%; left: 20%; animation-duration: 32s; }
.logo-flotante:nth-child(6) { top: 10%; left: 45%; animation-duration: 38s; }
.logo-flotante:nth-child(7) { top: 50%; left: 90%; animation-duration: 26s; }
.logo-flotante:nth-child(8) { top: 75%; left: 50%; animation-duration: 42s; }
.logo-flotante:nth-child(9) { top: 25%; left: 30%; animation-duration: 30s; }
.logo-flotante:nth-child(10) { top: 90%; left: 80%; animation-duration: 36s; }
.logo-flotante:nth-child(11) { top: 35%; left: 60%; animation-duration: 29s; }
.logo-flotante:nth-child(12) { top: 5%; left: 40%; animation-duration: 45s; }
@keyframes flotar {
    0% { transform: translateY(0) rotate(0deg); }
    50% { transform: translateY(100px) rotate(10deg); }
    100% { transform: translateY(0) rotate(0deg); }
}
    </style>
</head>
<body>

<div class="fondo-animado">
        <img src="img/loogoproyecto.png" class="logo-flotante">
        <img src="img/loogoproyecto.png" class="logo-flotante">
        <img src="img/loogoproyecto.png" class="logo-flotante">
        <img src="img/loogoproyecto.png" class="logo-flotante">
        <img src="img/loogoproyecto.png" class="logo-flotante">
        <img src="img/loogoproyecto.png" class="logo-flotante">
        <img src="img/loogoproyecto.png" class="logo-flotante">
        <img src="img/loogoproyecto.png" class="logo-flotante">
        <img src="img/loogoproyecto.png" class="logo-flotante">
        <img src="img/loogoproyecto.png" class="logo-flotante">
        <img src="img/loogoproyecto.png" class="logo-flotante">
        <img src="img/loogoproyecto.png" class="logo-flotante">
    </div>

<div class="sidebar">
    <button class="btn btn-referencial" data-toggle="collapse" data-target="#menuReferenciales">
        ▼ Referenciales
    </button>
    <div id="menuReferenciales" class="collapse sub-menu">
        <a href="lista.jsp">Lista de personas</a>
        <a href="salario_base.jsp">Asignar salario base</a>
        <a href="aplicar_descuentos.jsp">Aplicar descuentos</a>
        <a href="aplicar_bonificaciones.jsp">Aplicar bonificaciones</a>
        <a href="configurar_periodo.jsp">Configurar periodo</a>
        <a href="configurar_horario.jsp">Configurar horario</a>
    </div>
</div>

<div class="main-content">
    <div class="contenedor">
        <h1>Panel Administrador</h1>
        <a href="ver_accesos.jsp" class="btn-custom">Marcaciones</a>
        <a href="motivos_descuento.jsp" class="btn-custom">Motivos de descuento</a>
        <a href="motivos_bonificacion.jsp" class="btn-custom">Motivos de bonificación</a>
        <a href="gestion_usuarios.jsp" class="btn-custom">Gestionar Usuarios</a>
        <a href="editar_salario_guardado.jsp" class="btn-custom">Gestión de salarios</a>
        <a href="Listar_periodos.jsp" class="btn-custom">Ver todos los Periodos</a>
        <a href="liquidacion_mensual.jsp" class="btn-custom">Liquidación mensual</a>
        <a href="logout.jsp" class="btn-custom btn-cerrar">Cerrar sesión</a>
    </div>
</div>

</body>
</html>
