<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Empleado</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        :root {
            --bg-main: #050a0f;
            --card-bg: rgba(17, 24, 39, 0.75);
            --border-color: rgba(255, 255, 255, 0.08);
        }

        body { background: var(--bg-main); color: white; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; padding: 15px; }
        .contenedor { background: rgba(10, 15, 25, 0.9); padding: 35px 30px; border-radius: 30px; text-align: center; width: 100%; max-width: 450px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        h1 { font-size: 24px; margin-bottom: 10px; }
        .bienvenido { color: #dce6ef; margin-bottom: 20px; font-size: 16px; }
        
        .btn-custom { display: block; width: 100%; padding: 13px; margin: 10px 0; border-radius: 30px; color: white; text-decoration: none; font-weight: bold; background: linear-gradient(30deg, #4225a3, #000738); transition: 0.3s; border: none; }
        .btn-custom:hover { transform: scale(1.03); color: white; text-decoration: none; }

        /* Estilos del Modal adaptados a la estética oscura del sistema */
        .modal-content { background: #111827; color: #f8fafc; border-radius: 20px; border: 1px solid var(--border-color); box-shadow: 0 15px 35px rgba(0,0,0,0.6); }
        .modal-header { border-bottom: 1px solid var(--border-color); padding: 20px; }
        .modal-body { padding: 20px; }
        .modal-footer { border-top: 1px solid var(--border-color); padding: 15px 20px; }
        
        .form-control { background: rgba(255,255,255,0.05); border: 1px solid var(--border-color); color: white; border-radius: 12px; font-size: 14px; padding: 12px; }
        .form-control:focus { background: rgba(255,255,255,0.08); color: white; border-color: #818cf8; box-shadow: none; }
        .form-control option { background: #0b1f2a; color: white; }
        label { font-size: 13px; color: #94a3b8; font-weight: 600; text-align: left; display: block; margin-bottom: 6px; }

        .btn-rojo-custom { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 20px; padding: 8px 20px; color: white; font-weight: bold; font-size: 14px; box-shadow: 0 4px 12px rgba(247, 64, 64, 0.3); transition: 0.2s; }
        .btn-rojo-custom:hover { opacity: 0.9; color: white; transform: translateY(-1px); }

        .btn-lila-custom { background: linear-gradient(30deg, #4225a3, #000738); border: none; border-radius: 20px; padding: 8px 20px; color: white; font-weight: bold; font-size: 14px; transition: 0.2s; }
        .btn-lila-custom:hover { opacity: 0.9; color: white; transform: translateY(-1px); }

        /* Estilos responsivos para celulares */
        @media (max-width: 576px) {
            body { padding: 10px; }
            .contenedor { padding: 25px 20px; border-radius: 20px; }
            h1 { font-size: 21px; margin-bottom: 10px; }
            .bienvenido { font-size: 15px; margin-bottom: 15px; }
            .btn-custom { padding: 11px; font-size: 14px; margin: 8px 0; }
        }
    </style>
</head>
<body>
<div class="contenedor">
    <h1>Panel del Empleado</h1>
    <p class="bienvenido">Hola, <strong><%= nombreUsuario %></strong></p>
    
    <a href="index.jsp" class="btn-custom">Marcar Asistencia</a>
    <a href="ver_accesos.jsp" class="btn-custom">Ver mis marcaciones</a>
    <a href="cambiar_password.jsp" class="btn-custom">Cambiar Contraseña</a>
    
    <!-- Botón para abrir el Modal -->
    <button type="button" class="btn-custom" data-toggle="modal" data-target="#modalReporte">
        Reportar Tardanza o Ausencia
    </button>

    <a href="logout.jsp" class="btn-custom" style="background: linear-gradient(35deg, #f74040, #f50404);">Cerrar sesión</a>
</div>

<!-- MODAL PARA REPORTAR TARDANZA O AUSENCIA -->
<div class="modal fade" id="modalReporte" tabindex="-1" role="dialog" aria-labelledby="modalReporteLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalReporteLabel" style="font-size: 17px; font-weight: bold; color: #f1f5f9;">Reportar Tardanza o Ausencia</h5>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close" style="outline: none;">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form action="enviar_reporte_empleado.jsp" method="POST">
                <div class="modal-body text-left">
                    <div class="form-group mb-3">
                        <label>Tipo de Incidencia:</label>
                        <select name="tipo_incidencia" class="form-control" required>
                            <option value="">-- Seleccionar --</option>
                            <option value="Tardanza">Llegada Tardía</option>
                            <option value="Ausencia">Ausencia / Falta</option>
                        </select>
                    </div>
                    <div class="form-group mb-3">
                        <label>Fecha del Incidente:</label>
                        <input type="date" name="fecha" class="form-control" required>
                    </div>
                    <div class="form-group mb-2">
                        <label>Motivo o Justificación:</label>
                        <textarea name="motivo" class="form-control" rows="3" placeholder="Explique brevemente el motivo..." required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-rojo-custom" data-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn-lila-custom">Enviar al Administrador</button>
                </div>
            </form>
        </div>
    </div>
</div>

</body>
</html>
