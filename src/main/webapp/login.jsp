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
            background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a);
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
            background: linear-gradient(45deg, #00b09b, #96c93d);
            transition: 0.3s ease;
        }

        .btn-ingresar:hover {
            transform: scale(1.03);
        }

        .mensaje {
            margin-bottom: 20px;
        }

    </style>

</head>
<body>

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