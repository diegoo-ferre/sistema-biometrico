<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
// Verificamos que el usuario haya iniciado sesión
if (session.getAttribute("usuario") == null) { 
    response.sendRedirect("login.jsp"); 
    return; 
}
String nombreUsuario = (String) session.getAttribute("usuario");

// Capturamos posibles mensajes de error o éxito enviados por el Servlet
String error = request.getParameter("error");
String exito = request.getParameter("exito");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cambiar Contraseña</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { background: #050a0f; color: white; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; font-family: Arial, sans-serif; padding: 15px; }
        .contenedor { background: rgba(10, 15, 25, 0.9); padding: 40px; border-radius: 30px; text-align: center; width: 100%; max-width: 400px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        h1 { font-size: 24px; margin-bottom: 25px; }
        .form-group { text-align: left; margin-bottom: 15px; }
        label { font-size: 14px; color: #dce6ef; }
        
        .form-control { background: #050a0f; border: 1px solid #222d3d; color: white; border-radius: 20px; padding: 10px 15px; padding-right: 45px; }
        .form-control:focus { background: #050a0f; color: white; border-color: #555; box-shadow: none; }
        
        /* Contenedor y botón para ver contraseña */
        .password-wrapper { position: relative; }
        .btn-toggle-pass {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            background: transparent;
            border: none;
            color: #94a3b8;
            cursor: pointer;
            padding: 0;
            z-index: 5;
        }
        .btn-toggle-pass:hover { color: #ffffff; }

        .btn-custom { display: block; width: 100%; padding: 15px; margin: 15px 0 10px 0; border-radius: 30px; color: white; text-decoration: none; font-weight: bold; background: linear-gradient(30deg, #4225a3, #000738); border: none; transition: 0.3s; cursor: pointer; }
        .btn-custom:hover { transform: scale(1.03); color: white; }
        .btn-eliminar { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 20px; padding: 12px 18px; color: white; font-weight: bold; display: block; width: 100%; text-decoration: none; transition: 0.3s; text-align: center; }
        .btn-eliminar:hover { transform: scale(1.03); color: white; text-decoration: none; }
        .alert-success-custom { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; border-radius: 20px; padding: 10px 15px; margin-bottom: 20px; font-weight: bold; font-size: 14px; text-align: center; }
        .alert-danger-custom { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; border-radius: 20px; padding: 10px 15px; margin-bottom: 20px; font-weight: bold; font-size: 14px; text-align: center; }

        /* Estilos responsivos para celulares */
        @media (max-width: 576px) {
            body { padding: 10px; }
            .contenedor { padding: 25px 20px; border-radius: 20px; }
            h1 { font-size: 21px; margin-bottom: 20px; }
            .form-control { padding: 8px 12px; font-size: 14px; padding-right: 40px; }
            .btn-custom { padding: 12px; font-size: 14px; }
            .btn-eliminar { padding: 10px; font-size: 14px; }
        }
    </style>
</head>
<body>
<div class="contenedor">
    <h1>Cambiar Contraseña</h1>
    
    <% if ("passwordActualizado".equals(exito)) { %>
        <div class="alert-success-custom" role="alert">
            ¡Contraseña actualizada correctamente!
        </div>
    <% } %>
    
    <% if ("noCoinciden".equals(error)) { %>
        <div class="alert-danger-custom" role="alert">
            Las nuevas contraseñas no coinciden.
        </div>
    <% } else if ("actualIncorrecto".equals(error)) { %>
        <div class="alert-danger-custom" role="alert">
            La contraseña actual es incorrecta.
        </div>
    <% } else if ("excepcion".equals(error)) { %>
        <div class="alert-danger-custom" role="alert">
            Ocurrió un error en el servidor. Intente nuevamente.
        </div>
    <% } %>
    
    <form action="ActualizarPasswordServlet" method="POST">
        <div class="form-group">
            <label for="passwordActual">Contraseña Actual (CI o anterior):</label>
            <div class="password-wrapper">
                <input type="password" class="form-control" id="passwordActual" name="passwordActual" required>
                <button type="button" class="btn-toggle-pass" onclick="togglePassword('passwordActual', this)">
                    <i class="fas fa-eye"></i>
                </button>
            </div>
        </div>
        
        <div class="form-group">
            <label for="nuevoPassword">Nueva Contraseña:</label>
            <div class="password-wrapper">
                <input type="password" class="form-control" id="nuevoPassword" name="nuevoPassword" required>
                <button type="button" class="btn-toggle-pass" onclick="togglePassword('nuevoPassword', this)">
                    <i class="fas fa-eye"></i>
                </button>
            </div>
        </div>
        
        <div class="form-group">
            <label for="confirmarPassword">Confirmar Nueva Contraseña:</label>
            <div class="password-wrapper">
                <input type="password" class="form-control" id="confirmarPassword" name="confirmarPassword" required>
                <button type="button" class="btn-toggle-pass" onclick="togglePassword('confirmarPassword', this)">
                    <i class="fas fa-eye"></i>
                </button>
            </div>
        </div>
        
        <button type="submit" class="btn-custom">Actualizar Contraseña</button>
    </form>
    
    <a href="empleado_dashboard.jsp" class="btn-eliminar">Volver al inicio</a>
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
