<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Configurar Horario</title>
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
            padding: 40px 35px;
            border-radius: 30px;
            text-align: center;
            color: white;
            width: 100%;
            max-width: 500px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.9);
        }

        h2 { margin-bottom: 25px; font-weight: bold; }

        .form-group { text-align: left; }

        .btn-custom {
            display: block;
            width: 100%;
            margin: 12px auto;
            padding: 14px 20px;
            border: none;
            border-radius: 30px;
            color: white;
            font-size: 18px;
            font-weight: bold;
            text-decoration: none;
            transition: 0.3s ease;
        }

        .btn-custom:hover { transform: scale(1.03); color: white; text-decoration: none; }
        .btn-guardar { background: linear-gradient(40deg, #4225a3, #000738); }
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); }
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
    } catch(Exception e) { out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>"); }
    finally { if(con != null) con.close(); }
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
        <button type="submit" class="btn btn-custom btn-guardar">Guardar Configuración</button>
        <a href="admin.jsp" class="btn btn-custom btn-volver">Volver</a>
    </form>
</div>

</body>
</html>