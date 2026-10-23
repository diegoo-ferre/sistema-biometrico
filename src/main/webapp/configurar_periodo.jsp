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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { margin: 0; min-height: 100vh; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); font-family: Arial, sans-serif; color: white; padding: 30px 15px; display: flex; align-items: center; justify-content: center; }
        .contenedor { max-width: 600px; width: 100%; margin: auto; background: rgba(10, 15, 25, 0.9); padding: 40px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        h2 { text-align: center; margin-bottom: 30px; font-size: 32px; font-weight: bold; }
        
        label { color: #dce6ef; font-size: 14px; }
        .form-control { background: rgba(255, 255, 255, 0.06); border: 1px solid rgba(255,255,255,0.1); color: white; border-radius: 15px; padding: 12px; height: auto; }
        .form-control option { background: #030a12; color: white; }
        .form-control:focus { background: rgba(255, 255, 255, 0.1); color: white; border-color: #4225a3; box-shadow: none; }

        .btn-guardar { background: linear-gradient(30deg, #4225a3, #000738); border: none; border-radius: 30px; color: white; width: 100%; padding: 12px; font-weight: bold; margin-top: 15px; cursor: pointer; transition: 0.3s; }
        .btn-guardar:hover { transform: scale(1.03); color: white; }

        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 30px; color: white; width: 100%; padding: 12px; font-weight: bold; text-decoration: none; display: block; text-align: center; margin-top: 15px; transition: 0.3s; }
        .btn-volver:hover { color: white; text-decoration: none; transform: scale(1.03); }
        
        .icon8 { filter: brightness(0) invert(1); width: 32px; vertical-align: middle; margin-left: 5px; }

        .alert-success-custom { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; border-radius: 15px; padding: 12px 20px; margin-bottom: 25px; font-weight: bold; font-size: 14px; text-align: center; }
        .alert-danger-custom { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; border-radius: 15px; padding: 12px 20px; margin-bottom: 25px; font-weight: bold; font-size: 14px; text-align: center; }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Configurar Periodo <img src="img/calendario.png" class="icon8"></h2>
    <%
    Connection con = null;
    String mensaje = null;
    String tipoMensaje = "exito";
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
            ps.close();
            mensaje = "¡Periodo actualizado correctamente!";
            tipoMensaje = "exito";
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
        rs.close();
        psSelect.close();
    %>

    <% if (mensaje != null) { %>
        <% if ("exito".equals(tipoMensaje)) { %>
            <div class="alert-success-custom" role="alert"><%= mensaje %></div>
        <% } else { %>
            <div class="alert-danger-custom" role="alert"><%= mensaje %></div>
        <% } %>
    <% } %>

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
        <a href="admin.jsp" class="btn-volver">Volver al Inicio</a>
    </form>
    <%
    } catch(Exception e) { 
        out.println("<div class='alert-danger-custom'>Error: " + e.getMessage() + "</div>"); 
    } finally { 
        if(con != null) con.close(); 
    }
    %>
</div>
</body>
</html>