<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires", 0);

if (session == null || session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

String usuarioLogueado = (String) session.getAttribute("usuario");

// Lógica para eliminar el reporte si se solicita
String accionEliminar = request.getParameter("accion");
if ("eliminar".equals(accionEliminar)) {
    String idRepStr = request.getParameter("id");
    if (idRepStr != null) {
        Connection connDel = null;
        PreparedStatement psDel = null;
        try {
            Class.forName("org.postgresql.Driver");
            connDel = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");
            psDel = connDel.prepareStatement("DELETE FROM reportes_empleado WHERE id = ?");
            psDel.setInt(1, Integer.parseInt(idRepStr));
            psDel.executeUpdate();
            
            response.sendRedirect("ver_justificativos.jsp?eliminado=exito");
            return;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (psDel != null) try { psDel.close(); } catch(Exception ex) {}
            if (connDel != null) try { connDel.close(); } catch(Exception ex) {}
        }
    }
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Justificativos y Reportes | Sistema Biométrico</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        body { margin: 0; min-height: 100vh; font-family: Arial, sans-serif; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); display: flex; align-items: center; justify-content: center; padding: 30px; color: white; }
        .contenedor { background: rgba(10, 15, 25, 0.9); padding: 40px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); width: 95%; max-width: 1100px; }
        h2 { text-align: center; margin-bottom: 30px; font-weight: bold; }
        
        .user-info-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; background: rgba(255,255,255,0.03); padding: 10px 20px; border-radius: 15px; border: 1px solid rgba(255,255,255,0.08); }
        
        table { width: 100%; color: white; border-collapse: collapse; background: rgba(255,255,255,0.03); border-radius: 15px; overflow: hidden; }
        th, td { padding: 15px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.08); vertical-align: middle; }
        th { background: rgba(255,255,255,0.08); font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; }
        
        .btn-accion { padding: 8px 15px; border-radius: 20px; border: none; color: white !important; font-weight: bold !important; cursor: pointer; transition: transform 0.3s ease; text-decoration: none !important; display: inline-block; font-size: 13px; margin: 2px; }
        .btn-accion:hover { transform: scale(1.05); color: white !important; text-decoration: none; }
        .btn-edit { background: linear-gradient(30deg, #4225a3, #000738); }
        .btn-del { background: linear-gradient(35deg, #f74040, #f50404); }
        
        .btn-custom { display: block; width: 100%; max-width: 360px; margin: 30px auto 0 auto; padding: 12px; border: none; border-radius: 30px; color: white; font-weight: bold !important; text-decoration: none; transition: 0.3s; background: linear-gradient(30deg, #4225a3, #000738); text-align: center; }
        .btn-custom:hover { transform: scale(1.03); color: white; text-decoration: none; }
        .btn-cerrar { background: linear-gradient(35deg, #f74040, #f50404); }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Justificativos y Reportes de Empleados</h2>
    
    <div class="user-info-bar">
        <span><i class="fas fa-bell mr-2" style="color: #818cf8;"></i> Listado de solicitudes y descargos</span>
        <span style="color: #94a3b8;"><i class="fas fa-user-circle mr-1" style="color: #818cf8;"></i> <%= usuarioLogueado %></span>
    </div>

    <%
    String eliminado = request.getParameter("eliminado");
    if ("exito".equals(eliminado)) {
    %>
        <div class="alert alert-success text-center" style="border-radius: 15px;">
            ¡El reporte ha sido eliminado correctamente!
        </div>
    <%
    }
    %>

    <div class="table-responsive">
        <table>
            <thead>
                <tr>
                    <th>Empleado</th>
                    <th>Incidencia</th>
                    <th>Fecha</th>
                    <th>Motivo / Descargo</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                <%
                Connection connRep = null;
                try {
                    Class.forName("org.postgresql.Driver");
                    connRep = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");
                    Statement stRep = connRep.createStatement();
                    ResultSet rsRep = stRep.executeQuery("SELECT r.id, p.nombre, r.tipo_incidencia, r.fecha, r.motivo FROM reportes_empleado r JOIN personas p ON r.persona_id = p.id ORDER BY r.id DESC");
                    
                    boolean hayReportes = false;
                    while(rsRep.next()) {
                        hayReportes = true;
                        String tipoInc = rsRep.getString("tipo_incidencia");
                        String badgeInc = "badge-warning";
                        if("Ausencia".equalsIgnoreCase(tipoInc)) {
                            badgeInc = "badge-danger";
                        }
                %>
                <tr>
                    <td><strong><%= rsRep.getString("nombre") %></strong></td>
                    <td><span class="badge <%= badgeInc %>" style="font-size: 12px; padding: 6px 10px; border-radius: 10px;"><%= tipoInc %></span></td>
                    <td><%= rsRep.getDate("fecha") %></td>
                    <td><%= rsRep.getString("motivo") %></td>
                    <td>
                        <a href="aplicar_descuentos.jsp" class="btn-accion btn-edit">Gestionar Descuento</a>
                        <a href="ver_justificativos.jsp?accion=eliminar&id=<%= rsRep.getInt("id") %>" class="btn-accion btn-del" onclick="return confirm('¿Está seguro de que desea eliminar este reporte?');">Eliminar</a>
                    </td>
                </tr>
                <%
                    }
                    rsRep.close();
                    stRep.close();
                    if(!hayReportes) {
                %>
                <tr>
                    <td colspan="5" class="text-center text-muted py-4">No hay reportes o justificativos enviados por los empleados.</td>
                </tr>
                <%
                    }
                } catch(Exception ex) {
                %>
                <tr>
                    <td colspan="5" class="text-center text-danger py-4">Error al cargar los reportes de empleados.</td>
                </tr>
                <%
                } finally {
                    if(connRep != null) connRep.close();
                }
                %>
            </tbody>
        </table>
    </div>

    <div>
        <a href="admin.jsp" class="btn-custom btn-cerrar">Volver al Inicio</a>
    </div>
</div>

</body>
</html>