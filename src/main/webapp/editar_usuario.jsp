<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
String id = request.getParameter("id");
String usuario = "", pass = "", rol = "";
String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";

// Procesar actualización
if ("POST".equalsIgnoreCase(request.getMethod())) {
    try (Connection conn = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm");
         PreparedStatement ps = conn.prepareStatement("UPDATE usuarios SET usuario=?, password=?, rol=? WHERE id=?")) {
        ps.setString(1, request.getParameter("usuario"));
        ps.setString(2, request.getParameter("password"));
        ps.setString(3, request.getParameter("rol"));
        ps.setInt(4, Integer.parseInt(id));
        ps.executeUpdate();
        response.sendRedirect("gestion_usuarios.jsp");
        return;
    }
}

// Cargar datos actuales
try (Connection conn = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm");
     PreparedStatement ps = conn.prepareStatement("SELECT * FROM usuarios WHERE id=?")) {
    ps.setInt(1, Integer.parseInt(id));
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
        usuario = rs.getString("usuario");
        pass = rs.getString("password");
        rol = rs.getString("rol");
    }
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Editar Usuario</title>
   <style>
    body { background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); color: white; display:flex; justify-content:center; align-items:center; min-height:100vh; font-family: Arial, sans-serif; margin: 0; }
    .contenedor { background: rgba(10, 15, 25, 0.9); padding: 40px; border-radius: 30px; width: 100%; max-width: 400px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
    input, select { width: 100%; padding: 12px; margin: 10px 0; border-radius: 15px; border: none; background: rgba(255,255,255,0.05); color: white; box-sizing: border-box; }
    
    /* Ambos botones con el mismo tamaño, padding y margen */
    .btn { 
        display: block; 
        width: 100%; 
        padding: 12px; 
        margin: 10px 0; 
        border: none; 
        border-radius: 30px; 
        color: white !important; 
        font-weight: bold; 
        cursor: pointer; 
        transition: transform 0.3s; 
        text-decoration: none !important; 
        text-align: center;
        box-sizing: border-box; /* Asegura que el padding no afecte el ancho */
    }
    
    .btn:hover { transform: scale(1.05); }
    
    .btn-guardar { background: linear-gradient(30deg, #4225a3, #000738); }
    .btn-cancelar { background: linear-gradient(35deg, #f74040, #f50404); }
    .empleado{
        color: black;
    }
    .admin{
        color: black;
    }
</style>
</head>
<body>
    <div class="contenedor">
        <h2>Editar Usuario</h2>
        <form method="post">
            <input type="text" name="usuario" value="<%= usuario %>" required placeholder="Nombre de usuario">
            <input type="text" name="password" value="<%= pass %>" required placeholder="Contraseña/CI">
            <select name="rol"">
                <option value="empleado" class="empleado" <%= rol.equals("empleado") ? "selected" : "" %>>Empleado</option>
                <option value="admin" class="admin" <%= rol.equals("admin") ? "selected" : "" %>>Admin</option>
            </select>
            <button type="submit" class="btn btn-guardar">Guardar Cambios</button>
            <a href="gestion_usuarios.jsp" class="btn btn-cancelar">Cancelar</a>
        </form>
    </div>
</body>
</html>