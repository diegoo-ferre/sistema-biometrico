<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.temporal.ChronoUnit" %>

<%
response.setCharacterEncoding("UTF-8");

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    request.setCharacterEncoding("UTF-8");

    String personaIdStr = request.getParameter("persona_id");
    String nombre = request.getParameter("nombre");
    String ci = request.getParameter("ci");

    if (personaIdStr == null || personaIdStr.trim().equals("")) {
        out.print("{\"ok\":false,\"mensaje\":\"persona no válida\"}");
        return;
    }

    int personaId = Integer.parseInt(personaIdStr);

    Class.forName("org.postgresql.Driver");

    String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
                String user = "neondb_owner";
                String pass = "npg_6rt8OdayAHcm";

                con = DriverManager.getConnection(url, user, pass);

    LocalDate fechaHoy = LocalDate.now();
    LocalTime horaActual = LocalTime.now().truncatedTo(ChronoUnit.SECONDS);
    LocalTime horaLimite = LocalTime.of(8, 15, 0);

    ps = con.prepareStatement("select * from asistencias where persona_id = ? and fecha = ?");
    ps.setInt(1, personaId);
    ps.setDate(2, java.sql.Date.valueOf(fechaHoy));
    rs = ps.executeQuery();

    if (!rs.next()) {
        rs.close();
        ps.close();

        int minutosTardanza = 0;
        String estado = "entrada registrada";

        if (horaActual.isAfter(horaLimite)) {
            minutosTardanza = (int) ChronoUnit.MINUTES.between(horaLimite, horaActual);
            estado = "tardanza";
        }

        ps = con.prepareStatement(
            "insert into asistencias (persona_id, fecha, hora_entrada, estado, minutos_tardanza) values (?, ?, ?, ?, ?)"
        );
        ps.setInt(1, personaId);
        ps.setDate(2, java.sql.Date.valueOf(fechaHoy));
        ps.setTime(3, java.sql.Time.valueOf(horaActual));
        ps.setString(4, estado);
        ps.setInt(5, minutosTardanza);
        ps.executeUpdate();

        out.print("{\"ok\":true,\"tipo\":\"entrada\",\"nombre\":\"" + nombre + "\",\"ci\":\"" + ci + "\",\"hora\":\"" + horaActual.toString() + "\",\"tardanza\":\"" + minutosTardanza + "\"}");
    } else {
        Time horaEntradaSql = rs.getTime("hora_entrada");
        Time horaSalidaSql = rs.getTime("hora_salida");
        int asistenciaId = rs.getInt("id");
        int minutosTardanza = rs.getInt("minutos_tardanza");

        rs.close();
        ps.close();

        if (horaEntradaSql != null && horaSalidaSql == null) {
            LocalTime horaEntrada = horaEntradaSql.toLocalTime();
            long minutos = ChronoUnit.MINUTES.between(horaEntrada, horaActual);
            double horasTrabajadas = minutos / 60.0;

            String estadoFinal = minutosTardanza > 0 ? "tardanza con salida" : "salida registrada";

            ps = con.prepareStatement(
                "update asistencias set hora_salida = ?, horas_trabajadas = ?, estado = ? where id = ?"
            );
            ps.setTime(1, java.sql.Time.valueOf(horaActual));
            ps.setDouble(2, horasTrabajadas);
            ps.setString(3, estadoFinal);
            ps.setInt(4, asistenciaId);
            ps.executeUpdate();

            out.print("{\"ok\":true,\"tipo\":\"salida\",\"nombre\":\"" + nombre + "\",\"ci\":\"" + ci + "\",\"hora\":\"" + horaActual.toString() + "\",\"horas\":\"" + horasTrabajadas + "\",\"tardanza\":\"" + minutosTardanza + "\"}");
        } else {
            out.print("{\"ok\":false,\"tipo\":\"completo\",\"mensaje\":\"la asistencia de hoy ya fue registrada completamente\"}");
        }
    }

} catch (Exception e) {
    out.print("{\"ok\":false,\"mensaje\":\"" + e.getMessage().replace("\"", "'") + "\"}");
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>