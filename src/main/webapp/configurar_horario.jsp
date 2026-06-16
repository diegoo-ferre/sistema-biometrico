<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Configurar Horario</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <style>
        body { background: #0b1f2a; color: white; padding: 50px; font-family: Arial; }
        .contenedor { max-width: 500px; margin: auto; background: #12384a; padding: 30px; border-radius: 20px; }
    </style>
</head>
<body>
<div class="contenedor">
    <h2>Configuración de Entrada</h2>
    <%
    Connection con = null;
    try {
        Class.forName("org.postgresql.Driver");
        con = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String hora = request.getParameter("hora_entrada");
            int tol = Integer.parseInt(request.getParameter("tolerancia"));
            PreparedStatement ps = con.prepareStatement("UPDATE configuracion_horarios SET hora_entrada_oficial = ?, minutos_tolerancia = ? WHERE id = 1");
            ps.setTime(1, java.sql.Time.valueOf(hora + ":00"));
            ps.setInt(2, tol);
            ps.executeUpdate();
            out.println("<div class='alert alert-success'>Configuración guardada</div>");
        }
    } catch(Exception e) { out.println("Error: " + e.getMessage()); }
    %>
    <form method="post">
        <div class="form-group">
            <label>Hora de Entrada Oficial:</label>
            <input type="time" name="hora_entrada" class="form-control" required>
        </div>
        <div class="form-group">
            <label>Minutos de Tolerancia:</label>
            <input type="number" name="tolerancia" class="form-control" required>
        </div>
        <button type="submit" class="btn btn-primary">Guardar Configuración</button>
        <a href="admin.jsp" class="btn btn-secondary">Volver</a>
    </form>
</div>
</body>
</html>