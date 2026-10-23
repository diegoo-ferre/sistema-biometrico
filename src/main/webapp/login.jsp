<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión | Sistema Biométrico</title>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">

    <style>
        body {
            margin: 0;
            min-height: 100vh;
            font-family: 'Segoe UI', Arial, sans-serif;
            background: linear-gradient(135deg, #02060c, #07111c, #0f2233);
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        /* Contenedor Ultra Moderno y Profesional */
        .contenedor {
            background: rgba(13, 20, 33, 0.75);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            padding: 50px 40px;
            border-radius: 32px;
            text-align: center;
            color: white;
            width: 100%;
            max-width: 440px;
            box-shadow: 0 25px 60px rgba(0, 0, 0, 0.8), 0 0 40px rgba(66, 37, 163, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.08);
            position: relative;
            overflow: hidden;
        }

        /* Línea decorativa superior luminosa */
        .contenedor::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, transparent, #6366f1, #4225a3, transparent);
        }

        .logo {
            width: 90px;
            height: 90px;
            object-fit: contain;
            margin-bottom: 22px;
            filter: drop-shadow(0 0 15px rgba(99, 102, 241, 0.4));
            transition: transform 0.3s ease;
        }

        .logo:hover {
            transform: scale(1.05);
        }

        h2 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 8px;
            color: #f8fafc;
            letter-spacing: 0.5px;
        }

        p {
            font-size: 14px;
            color: #94a3b8;
            margin-bottom: 30px;
        }

        .form-group {
            text-align: left;
            margin-bottom: 20px;
        }

        .form-control {
            background: rgba(2, 8, 15, 0.6);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: #f8fafc;
            border-radius: 16px;
            padding: 14px 20px;
            font-size: 15px;
            height: auto;
            transition: all 0.3s ease;
        }

        .form-control::placeholder {
            color: #64748b;
        }

        .form-control:focus {
            background: rgba(2, 8, 15, 0.85);
            color: #ffffff;
            border-color: #6366f1;
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.15);
        }

        /* Contenedor del campo de contraseña */
        .password-wrapper {
            position: relative;
        }
        
        .password-wrapper .form-control {
            padding-right: 45px;
            margin-bottom: 0;
        }

        .btn-toggle-pass {
            position: absolute;
            right: 18px;
            top: 50%;
            transform: translateY(-50%);
            background: transparent;
            border: none;
            color: #64748b;
            cursor: pointer;
            padding: 0;
            z-index: 5;
            transition: color 0.2s;
        }

        .btn-toggle-pass:hover {
            color: #ffffff;
        }

        .btn-ingresar {
            width: 100%;
            border: none;
            border-radius: 16px;
            padding: 14px;
            font-size: 16px;
            font-weight: 600;
            color: white;
            background: linear-gradient(135deg, #4225a3, #2a146e);
            transition: all 0.3s ease;
            cursor: pointer;
            box-shadow: 0 8px 25px rgba(66, 37, 163, 0.4);
            margin-top: 10px;
            letter-spacing: 0.5px;
        }

        .btn-ingresar:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 30px rgba(66, 37, 163, 0.6);
            background: linear-gradient(135deg, #4f2dbd, #321980);
            color: white;
        }

        .alert-danger-custom {
            background-color: rgba(248, 215, 218, 0.1);
            color: #ff6b6b;
            border: 1px solid rgba(248, 215, 218, 0.2);
            border-radius: 14px;
            padding: 12px 15px;
            margin-bottom: 25px;
            font-weight: 600;
            font-size: 14px;
            text-align: center;
            backdrop-filter: blur(5px);
        }

        /* Fondo Animado de Logos Flotantes */
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
            width: 65px; 
            opacity: 0.04;
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
            50% { transform: translateY(50px) rotate(15deg); }
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

    <h2>Bienvenido</h2>

    <p>Acceda al sistema biométrico empresarial.</p>

    <%
    if (error != null) {
    %>
        <div class="alert-danger-custom" role="alert">
            <i class="fas fa-exclamation-circle mr-2"></i> Usuario o contraseña incorrectos.
        </div>
    <%
    }
    %>

    <form action="${pageContext.request.contextPath}/LoginServlet" method="post">

        <div class="form-group">
            <input 
                type="text"
                name="usuario"
                class="form-control"
                placeholder="Ingrese su usuario o CI"
                required
            >
        </div>

        <div class="form-group">
            <div class="password-wrapper">
                <input 
                    type="password"
                    name="password"
                    id="passwordInput"
                    class="form-control"
                    placeholder="Ingrese su contraseña"
                    required
                >
                <button type="button" class="btn-toggle-pass" onclick="togglePassword('passwordInput', this)">
                    <i class="fas fa-eye"></i>
                </button>
            </div>
        </div>

        <button type="submit" class="btn-ingresar">
            Iniciar Sesión
        </button>

    </form>

</div>

<script>
    function togglePassword(fieldId, btn) {
        const input = document.getElementById(fieldId);
        const icon = btn.querySelector('i');
        if (input.type === "password") {
            input.type = "text";
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        } else {
            input.type = "password";
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        }
    }
</script>

</body>
</html>