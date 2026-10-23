<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Usuarios</title>
    <!-- Incluimos Bootstrap para los modales y estilos de alerta cómodos -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <style>
        body { margin: 0; min-height: 100vh; font-family: Arial, sans-serif; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); display: flex; align-items: center; justify-content: center; padding: 30px; color: white; }
        .contenedor { background: rgba(10, 15, 25, 0.9); padding: 40px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); width: 95%; max-width: 1000px; }
        h2 { text-align: center; margin-bottom: 30px; }
        
        .filtro-box { margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; gap: 15px; }
        .filtro-box input { width: 100%; max-width: 300px; padding: 10px; border-radius: 20px; border: none; background: rgba(255,255,255,0.1); color: white; outline: none; }
        
        table { width: 100%; color: white; border-collapse: collapse; background: rgba(255,255,255,0.03); border-radius: 15px; overflow: hidden; }
        th, td { padding: 15px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.08); vertical-align: middle; }
        th { background: rgba(255,255,255,0.08); }
        
        .btn-accion { padding: 8px 15px; border-radius: 20px; border: none; color: white !important; font-weight: bold !important; cursor: pointer; transition: transform 0.3s ease; text-decoration: none !important; display: inline-block; font-size: 13px; }
        .btn-accion:hover { transform: scale(1.05); color: white !important; }
        .btn-edit { background: linear-gradient(30deg, #4225a3, #000738); font-weight: bold !important; color: white !important; }
        .btn-del { background: linear-gradient(35deg, #f74040, #f50404); font-weight: bold !important; color: white !important; }
        .btn-nuevo { background: linear-gradient(30deg, #4225a3, #000738); padding: 10px 20px; font-weight: bold !important; color: white !important; }
        
        .btn-custom { display: block; width: 100%; max-width: 360px; margin: 20px auto 0 auto; padding: 12px; border: none; border-radius: 30px; color: white; font-weight: bold !important; text-decoration: none; transition: 0.3s; background: linear-gradient(30deg, #4225a3, #000738); text-align: center; }
        .btn-custom:hover { transform: scale(1.03); color: white; text-decoration: none; }
        .btn-cerrar { background: linear-gradient(35deg, #f74040, #f50404); } 

        /* Estilos del Modal */
        .modal-content { background: #030a12; color: white; border: 1px solid rgba(255,255,255,0.08); border-radius: 20px; box-shadow: 0 15px 40px rgba(0,0,0,0.9); }
        .modal-header { border-bottom: 1px solid rgba(255,255,255,0.08); }
        .modal-footer { border-top: 1px solid rgba(255,255,255,0.08); }
        .form-control { background: rgba(255, 255, 255, 0.06); border: 1px solid rgba(255,255,255,0.1); color: white; border-radius: 10px; }
        .form-control option { background: #030a12; color: white; }
        .form-control:focus { background: rgba(255, 255, 255, 0.1); color: white; box-shadow: none; border-color: #4225a3; }
        .close { color: white; }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Gestión de Usuarios</h2>
    
    <div class="filtro-box">
        <input type="text" id="filtroUsuario" onkeyup="filtrarUsuarios()" placeholder="🔍 Buscar usuario...">
        <a href="registro_usuario.jsp" class="btn-accion btn-nuevo">+ Nuevo Usuario</a>
    </div>
    
<%
String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
String mensajeAlerta = "";

try (Connection con = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm")) {
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (request.getParameter("idDel") != null) {
            try (PreparedStatement ps = con.prepareStatement("DELETE FROM usuarios WHERE id = ? AND rol != 'admin'")) {
                ps.setInt(1, Integer.parseInt(request.getParameter("idDel")));
                ps.executeUpdate();
                mensajeAlerta = "<div class='alert alert-success'>Usuario eliminado con éxito.</div>";
            }
        } else if (request.getParameter("idReset") != null) {
            try (PreparedStatement ps = con.prepareStatement("UPDATE usuarios SET password = ci WHERE id = ? AND rol != 'admin'")) {
                ps.setInt(1, Integer.parseInt(request.getParameter("idReset")));
                ps.executeUpdate();
                mensajeAlerta = "<div class='alert alert-success'>Contraseña restablecida con éxito al CI.</div>";
            }
        } else if (request.getParameter("idEditarRol") != null) {
            String nuevoRol = request.getParameter("nuevo_rol");
            int idUsuario = Integer.parseInt(request.getParameter("idEditarRol"));
            try (PreparedStatement ps = con.prepareStatement("UPDATE usuarios SET rol = ? WHERE id = ?")) {
                ps.setString(1, nuevoRol);
                ps.setInt(2, idUsuario);
                ps.executeUpdate();
                mensajeAlerta = "<div class='alert alert-success'>¡Rol actualizado con éxito!</div>";
            }
        }
    }
%>

    <%= mensajeAlerta %>

    <table id="tablaUsuarios">
        <thead>
            <tr><th>Usuario</th><th>Contraseña</th><th>Rol</th><th>Acciones</th></tr>
        </thead>
        <tbody>
<%
    ResultSet rs = con.createStatement().executeQuery("SELECT * FROM usuarios ORDER BY id DESC");
    while (rs.next()) {
        int idUsr = rs.getInt("id");
        String nombreUsr = rs.getString("usuario");
        String rol = rs.getString("rol");
%>
            <tr>
                <td><%= nombreUsr %></td>
                <td>*****</td>
                <td><%= rol %></td>
                <td>
                    <div style="display:flex; gap:8px; justify-content:center; align-items:center;">
                        <% if (!"admin".equalsIgnoreCase(rol)) { %>
                            <button type="button" class="btn-accion btn-edit" onclick="abrirModalRol('<%= idUsr %>', '<%= nombreUsr %>', '<%= rol %>')">Editar Rol</button>

                            <form method="post" onsubmit="return confirm('¿Desea restablecer la contraseña de este usuario a su CI predeterminado?');" style="display:inline;">
                                <input type="hidden" name="idReset" value="<%= idUsr %>">
                                <button type="submit" class="btn-accion btn-edit">Resetear contraseña</button>
                            </form>
                            <form method="post" onsubmit="return confirm('¿Eliminar este usuario?');" style="display:inline;">
                                <input type="hidden" name="idDel" value="<%= idUsr %>">
                                <button type="submit" class="btn-accion btn-del">Eliminar</button>
                            </form>
                        <% } else { %>
                            <span style="font-size: 13px; color: #aaa; font-style: italic;">Protegido</span>
                        <% } %>
                    </div>
                </td>
            </tr>
<%  } rs.close(); %>
        </tbody>
    </table>
<% } catch (Exception e) { out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>"); } %>

    <div>
        <a href="admin.jsp" class="btn-custom btn-cerrar">Volver al Inicio</a>
    </div>
</div>

<!-- VENTANA MODAL PARA EDITAR ROL -->
<div class="modal fade" id="modalEditarRol" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title font-weight-bold">✏️ Editar Rol de Usuario</h5>
        <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <form method="POST">
          <div class="modal-body">
              <input type="hidden" id="idEditarRol" name="idEditarRol">
              
              <div class="form-group">
                  <label>Usuario:</label>
                  <input type="text" id="nombreUsuarioModal" class="form-control" readonly style="background: rgba(255,255,255,0.03);">
              </div>
              
              <div class="form-group">
                  <label>Seleccionar Nuevo Rol:</label>
                  <select name="nuevo_rol" id="selectNuevoRol" class="form-control" required>
                      <option value="empleado">empleado</option>
                      <option value="admin">admin</option>
                  </select>
              </div>
          </div>
          <div class="modal-footer">
              <button type="button" class="btn btn-accion btn-del" data-dismiss="modal" style="border-radius:20px;">Cancelar</button>
              <button type="submit" class="btn btn-accion btn-edit" style="border-radius:20px;">Guardar Cambios</button>
          </div>
      </form>
    </div>
  </div>
</div>

<!-- Scripts de Bootstrap y JavaScript para la interacción -->
<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function filtrarUsuarios() {
        let input = document.getElementById("filtroUsuario").value.toUpperCase();
        let tr = document.getElementById("tablaUsuarios").getElementsByTagName("tr");
        for (let i = 1; i < tr.length; i++) {
            let td = tr[i].getElementsByTagName("td")[0];
            tr[i].style.display = (td && td.textContent.toUpperCase().indexOf(input) > -1) ? "" : "none";
        }
    }

    function abrirModalRol(id, nombre, rolActual) {
        document.getElementById("idEditarRol").value = id;
        document.getElementById("nombreUsuarioModal").value = nombre;
        document.getElementById("selectNuevoRol").value = rolActual;
        $('#modalEditarRol').modal('show');
    }
</script>
</body>
</html>