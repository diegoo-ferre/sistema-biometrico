<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
    try (Connection conn = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm");
         PreparedStatement ps = conn.prepareStatement("INSERT INTO usuarios (usuario, password, ci, rol) VALUES (?, ?, ?, ?)")) {
        
        ps.setString(1, request.getParameter("usuario"));
        ps.setString(2, request.getParameter("password")); // Usamos la contraseña/CI
        ps.setString(3, request.getParameter("password")); // Asumimos que la CI es la misma que la pass
        ps.setString(4, request.getParameter("rol"));
        
        ps.executeUpdate();
        response.sendRedirect("gestion_usuarios.jsp");
        return;
    } catch (Exception e) { out.println("Error: " + e.getMessage()); }
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Nuevo Usuario</title>
    <style>
        body { background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); color: white; display:flex; justify-content:center; align-items:center; min-height:100vh; font-family: Arial, sans-serif; margin: 0; }
        .contenedor { background: rgba(10, 15, 25, 0.9); padding: 40px; border-radius: 30px; width: 100%; max-width: 400px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        input, select { width: 100%; padding: 12px; margin: 10px 0; border-radius: 15px; border: none; background: rgba(255,255,255,0.05); color: white; box-sizing: border-box; }
        .btn { display: block; width: 100%; padding: 12px; margin: 10px 0; border: none; border-radius: 30px; color: white !important; font-weight: bold; cursor: pointer; transition: transform 0.3s; text-decoration: none !important; text-align: center; box-sizing: border-box; }
        .btn:hover { transform: scale(1.05); }
        .btn-guardar { background: linear-gradient(30deg, #4225a3, #000738); }
        .btn-cancelar { background: linear-gradient(35deg, #f74040, #f50404); }
    </style>
</head>
<body>
    <div class="contenedor">
        <h2>Nuevo Usuario</h2>
        <form method="post">
            <input type="text" name="usuario" required placeholder="Nombre de usuario">
            <input type="text" name="password" required placeholder="Contraseña / CI">
            <select name="rol">
                <option value="empleado">Empleado</option>
                <option value="admin">Admin</option>
            </select>
            <button type="submit" class="btn btn-guardar">Registrar</button>
            <a href="gestion_usuarios.jsp" class="btn btn-cancelar">Cancelar</a>
        </form>
    </div>
</body>
</html>