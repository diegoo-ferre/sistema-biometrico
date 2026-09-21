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
    <title>Cambiar Contraseña</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <style>
        body { background: #050a0f; color: white; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; font-family: Arial, sans-serif; }
        .contenedor { background: rgba(10, 15, 25, 0.9); padding: 40px; border-radius: 30px; text-align: center; width: 100%; max-width: 400px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        h1 { font-size: 24px; margin-bottom: 25px; }
        .form-group { text-align: left; margin-bottom: 15px; }
        label { font-size: 14px; color: #dce6ef; }
        
        /* AQUÍ CAMBIÉ EL BORDE: Cambia a 1px solid #222 o solid transparent para quitarlo por completo */
        .form-control { background: #050a0f; border: 1px solid #222d3d; color: white; border-radius: 20px; padding: 10px 15px; }
        .form-control:focus { background: #050a0f; color: white; border-color: #555; box-shadow: none; }
        
        .btn-custom { display: block; width: 100%; padding: 15px; margin: 15px 0 10px 0; border-radius: 30px; color: white; text-decoration: none; font-weight: bold; background: linear-gradient(30deg, #4225a3, #000738); border: none; transition: 0.3s; cursor: pointer; }
        .btn-custom:hover { transform: scale(1.03); color: white; }
        .btn-eliminar { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 20px; padding: 12px 18px; color: white; font-weight: bold; display: block; width: 100%; text-decoration: none; transition: 0.3s; text-align: center; }
        .btn-eliminar:hover { transform: scale(1.03); color: white; text-decoration: none; }
        .alert-success-custom { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; border-radius: 20px; padding: 10px 15px; margin-bottom: 20px; font-weight: bold; font-size: 14px; text-align: center; }
        .alert-danger-custom { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; border-radius: 20px; padding: 10px 15px; margin-bottom: 20px; font-weight: bold; font-size: 14px; text-align: center; }
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
            <input type="password" class="form-control" id="passwordActual" name="passwordActual" required>
        </div>
        
        <div class="form-group">
            <label for="nuevoPassword">Nueva Contraseña:</label>
            <input type="password" class="form-control" id="nuevoPassword" name="nuevoPassword" required>
        </div>
        
        <div class="form-group">
            <label for="confirmarPassword">Confirmar Nueva Contraseña:</label>
            <input type="password" class="form-control" id="confirmarPassword" name="confirmarPassword" required>
        </div>
        
        <button type="submit" class="btn-custom">Actualizar Contraseña</button>
    </form>
    
    <a href="empleado_dashboard.jsp" class="btn-eliminar">Volver al inicio</a>
</div>
</body>
</html>