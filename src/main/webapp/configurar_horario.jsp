<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

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
    <title>Configuración de Horarios</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <style>
        body { margin: 0; min-height: 100vh; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); font-family: Arial, sans-serif; color: white; padding: 30px 15px; }
        .contenedor { max-width: 600px; margin: auto; background: rgba(10, 15, 25, 0.88); padding: 35px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        h2 { text-align: center; margin-bottom: 30px; font-size: 32px; font-weight: bold; }
        .form-control { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: white; border-radius: 15px; padding: 12px; }
        .form-control option { background: #0b1f2a; color: white; }
        .btn-guardar { background: linear-gradient(40deg, #4225a3, #000738); border: none; border-radius: 15px; color: white; width: 100%; padding: 12px; font-weight: bold; margin-top: 15px; }
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 15px; color: white; width: 100%; padding: 12px; font-weight: bold; text-decoration: none; display: block; text-align: center; margin-top: 10px; }
        .btn-volver:hover { color: white; text-decoration: none; }
        .icon7{ filter: brightness(0) invert(1); }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Configuración de Horario <img src="img/reloj.png" class="icon7"></h2>
    <%
    Connection con = null;
    try {
        Class.forName("org.postgresql.Driver");
        con = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String turnoIdStr = request.getParameter("turno_id");
            String horaEntrada = request.getParameter("hora_entrada");
            String horaSalida = request.getParameter("hora_salida");
            String toleranciaStr = request.getParameter("tolerancia");
            
            if(turnoIdStr != null && !turnoIdStr.isEmpty()) {
                int turnoId = Integer.parseInt(turnoIdStr);
                
                // 1. Actualizar las horas del turno específico elegido
                PreparedStatement ps = con.prepareStatement("UPDATE turnos SET hora_inicio = ?, hora_fin = ? WHERE id = ?");
                ps.setTime(1, java.sql.Time.valueOf(horaEntrada.length() == 5 ? horaEntrada + ":00" : horaEntrada));
                ps.setTime(2, java.sql.Time.valueOf(horaSalida.length() == 5 ? horaSalida + ":00" : horaSalida));
                ps.setInt(3, turnoId);
                ps.executeUpdate();
                ps.close();

                // 2. Actualizar la tolerancia global compartida
                if(toleranciaStr != null && !toleranciaStr.isEmpty()) {
                    PreparedStatement psTol = con.prepareStatement("UPDATE configuracion_horario SET tolerancia_minutos = ?");
                    psTol.setInt(1, Integer.parseInt(toleranciaStr));
                    psTol.executeUpdate();
                    psTol.close();
                }

                out.println("<div class='alert alert-success text-center'>¡Configuración del turno actualizada con éxito!</div>");
            }
        }
    } catch(Exception e) { 
        out.println("<div class='alert alert-danger'>Error al actualizar: " + e.getMessage() + "</div>"); 
    }
    %>

    <form method="post" id="formHorario">
        <div class="form-group">
            <label>Seleccionar Turno a Configurar:</label>
            <select name="turno_id" id="turno_id" class="form-control" required>
                <option value="">-- Seleccione un Turno --</option>
                <%
                try {
                    Statement st = con.createStatement();
                    ResultSet rs = st.executeQuery("SELECT id, nombre, hora_inicio, hora_fin FROM turnos ORDER BY id");
                    while(rs.next()) {
                        out.println("<option value='" + rs.getInt("id") + "'>" + rs.getString("nombre") + " (" + rs.getTime("hora_inicio") + " - " + rs.getTime("hora_fin") + ")</option>");
                    }
                    rs.close();
                    st.close();
                } catch(Exception ex) {}
                %>
            </select>
        </div>

        <div class="form-group">
            <label>Nueva Hora de Entrada Oficial:</label>
            <input type="time" name="hora_entrada" id="hora_entrada" class="form-control" required>
        </div>
        <div class="form-group">
            <label>Nueva Hora de Salida Oficial:</label>
            <input type="time" name="hora_salida" id="hora_salida" class="form-control" required>
        </div>
        <div class="form-group">
            <label>Minutos de Tolerancia</label>
            <input type="number" name="tolerancia" id="tolerancia" class="form-control" value="10" required>
        </div>
        
        <button type="submit" class="btn-guardar">Guardar Cambios del Turno</button>
        <a href="admin.jsp" class="btn-volver">Volver al inicio</a>
    </form>
</div>

</body>
</html>
