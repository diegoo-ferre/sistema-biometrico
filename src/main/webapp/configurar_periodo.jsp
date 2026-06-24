<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalDate" %>

<%
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Configurar Periodo</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <style>
        body { margin: 0; min-height: 100vh; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); font-family: Arial, sans-serif; color: white; padding: 30px 15px; }
        .contenedor { max-width: 600px; margin: auto; background: rgba(10, 15, 25, 0.88); padding: 35px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        h2 { text-align: center; margin-bottom: 30px; font-size: 32px; font-weight: bold; }
        .form-control { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: white; border-radius: 15px; padding: 12px; }
        .btn-guardar { background: linear-gradient(40deg, #4225a3, #000738); border: none; border-radius: 15px; color: white; width: 100%; padding: 12px; font-weight: bold; margin-top: 15px; }
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 15px; color: white; width: 100%; padding: 12px; font-weight: bold; text-decoration: none; display: block; text-align: center; margin-top: 10px; }
        .btn-volver:hover { color: white; text-decoration: none; }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Configurar Periodo</h2>
    <%
    Connection con = null;
    try {
        Class.forName("org.postgresql.Driver");
        con = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");
        
        // Procesar cambios al enviar formulario
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            int mes = Integer.parseInt(request.getParameter("mes"));
            int anio = Integer.parseInt(request.getParameter("anio"));
            String fecha = request.getParameter("fecha_cierre");
            
            PreparedStatement ps = con.prepareStatement("UPDATE periodo_activo SET mes = ?, anio = ?, fecha_cierre = ? WHERE id = 1");
            ps.setInt(1, mes);
            ps.setInt(2, anio);
            ps.setDate(3, java.sql.Date.valueOf(fecha));
            ps.executeUpdate();
            out.println("<div class='alert alert-success text-center'>Periodo actualizado correctamente</div>");
        }

        // Obtener valores actuales
        PreparedStatement psSelect = con.prepareStatement("SELECT mes, anio, fecha_cierre FROM periodo_activo WHERE id = 1");
        ResultSet rs = psSelect.executeQuery();
        int mesActual = 6, anioActual = 2026;
        String fechaActual = LocalDate.now().toString();
        if(rs.next()){
            mesActual = rs.getInt("mes");
            anioActual = rs.getInt("anio");
            if(rs.getDate("fecha_cierre") != null) fechaActual = rs.getDate("fecha_cierre").toString();
        }
    %>
    <form method="post">
        <div class="form-group">
            <label>Mes:</label>
            <select name="mes" class="form-control">
                <% for(int i=1; i<=12; i++){ %>
                    <option value="<%=i%>" <%= i==mesActual?"selected":"" %>><%=i%></option>
                <% } %>
            </select>
        </div>
        <div class="form-group">
            <label>Año:</label>
            <input type="number" name="anio" class="form-control" value="<%=anioActual%>" required>
        </div>
        <div class="form-group">
            <label>Fecha de Cierre:</label>
            <input type="date" name="fecha_cierre" class="form-control" value="<%=fechaActual%>" required>
        </div>
        <button type="submit" class="btn-guardar">Guardar Periodo</button>
        <a href="admin.jsp" class="btn-volver">Volver al inicio</a>
    </form>
    <%
    } catch(Exception e) { out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>"); }
    finally { if(con != null) con.close(); }
    %>
</div>
</body>
</html>