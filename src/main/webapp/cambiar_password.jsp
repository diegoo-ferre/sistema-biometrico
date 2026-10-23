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
        body { margin: 0; min-height: 100vh; font-family: Arial, sans-serif; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); display: flex; align-items: center; justify-content: center; padding: 20px; color: white; }
        .contenedor { background: rgba(10, 15, 25, 0.9); padding: 40px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); width: 100%; max-width: 450px; text-align: center; }
        h2 { font-size: 24px; margin-bottom: 25px; font-weight: bold; }
        .form-group { text-align: left; margin-bottom: 20px; }
        label { font-size: 14px; color: #dce6ef; }
        
        .form-control { background: rgba(255, 255, 255, 0.06); border: 1px solid rgba(255,255,255,0.1); color: white; border-radius: 15px; padding: 12px 15px; padding-right: 45px; }
        .form-control:focus { background: rgba(255, 255, 255, 0.1); color: white; border-color: #4225a3; box-shadow: none; }
        
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

        .btn-custom { display: block; width: 100%; padding: 12px; margin: 20px 0 10px 0; border-radius: 30px; color: white; text-decoration: none; font-weight: bold; background: linear-gradient(30deg, #4225a3, #000738); border: none; transition: 0.3s; cursor: pointer; text-align: center; }
        .btn-custom:hover { transform: scale(1.03); color: white; text-decoration: none; }
        
        .btn-eliminar { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 30px; padding: 12px; color: white; font-weight: bold; display: block; width: 100%; text-decoration: none; transition: 0.3s; text-align: center; }
        .btn-eliminar:hover { transform: scale(1.03); color: white; text-decoration: none; }
        
        .alert-success-custom { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; border-radius: 15px; padding: 10px 15px; margin-bottom: 20px; font-weight: bold; font-size: 14px; text-align: center; }
        .alert-danger-custom { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; border-radius: 15px; padding: 10px 15px; margin-bottom: 20px; font-weight: bold; font-size: 14px; text-align: center; }

        @media (max-width: 576px) {
            .contenedor { padding: 25px 20px; border-radius: 20px; }
            h2 { font-size: 21px; margin-bottom: 20px; }
        }
    </style>
</head>
<body>
<div class="contenedor">
    <h2>Cambiar Contraseña</h2>
    
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
    
    <a href="empleado_dashboard.jsp" class="btn-eliminar">Volver al Inicio</a>
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