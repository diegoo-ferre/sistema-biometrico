<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login del Sistema</title>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">

    <style>

        body {
            margin: 0;
            min-height: 100vh;
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #020408, #050a0f, #08121a);
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .contenedor {
            background: rgba(10, 15, 25, 0.88);
            padding: 45px 35px;
            border-radius: 30px;
            text-align: center;
            color: white;
            width: 100%;
            max-width: 500px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.9);
        }

        .logo {
            width: 110px;
            height: 110px;
            object-fit: contain;
            margin-bottom: 20px;
        }

        h2 {
            font-size: 38px;
            font-weight: bold;
            margin-bottom: 15px;
        }

        p {
            font-size: 18px;
            color: #dce6ef;
            margin-bottom: 25px;
        }

        .form-control {
            border-radius: 20px;
            padding: 14px;
            font-size: 16px;
            margin-bottom: 20px;
            border: none;
        }

        .btn-ingresar {
            width: 100%;
            border: none;
            border-radius: 25px;
            padding: 14px;
            font-size: 18px;
            font-weight: bold;
            color: white;
            background: linear-gradient(40deg, #4225a3, #000738);
            transition: 0.3s ease;
        }

        .btn-ingresar:hover {
            transform: scale(1.03);
        }

        .mensaje {
            margin-bottom: 20px;
        }

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
    width: 80px; /* Tamaño un poco más pequeño para que no saturen */
    opacity: 0.1; /* Más transparencia para que no distraigan */
    animation: flotar linear infinite;
}

/* Configuraciones aleatorias para los 12 logos */
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
    
<div class="contenedor">

    <img src="img/loogoproyecto.png" class="logo" alt="Logo">

    <h2>Iniciar sesión</h2>

    <p>
        Acceda al sistema biométrico empresarial.
    </p>

    <%
    if (error != null) {
    %>

        <div class="alert alert-danger mensaje">
            Usuario o contraseña incorrectos.
        </div>

    <%
    }
    %>

    <form action="${pageContext.request.contextPath}/LoginServlet" method="post">

        <input 
            type="text"
            name="usuario"
            class="form-control"
            placeholder="Ingrese su usuario"
            required
        >

        <input 
            type="password"
            name="password"
            class="form-control"
            placeholder="Ingrese su contraseña"
            required
        >

        <button type="submit" class="btn-ingresar">
            Ingresar
        </button>

    </form>

</div>

</body>
</html>