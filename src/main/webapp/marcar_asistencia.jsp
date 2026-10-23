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

    // Obtener la fecha y hora exacta directamente desde PostgreSQL adaptada a la zona horaria de Paraguay
    LocalDate fechaHoy = null;
    LocalTime horaActual = null;

    PreparedStatement psTime = con.prepareStatement("SELECT CURRENT_DATE, (CURRENT_TIME AT TIME ZONE 'UTC' AT TIME ZONE 'America/Asuncion')::time");
    ResultSet rsTime = psTime.executeQuery();
    if (rsTime.next()) {
        fechaHoy = rsTime.getDate(1).toLocalDate();
        horaActual = rsTime.getTime(2).toLocalTime().truncatedTo(ChronoUnit.SECONDS);
    }
    rsTime.close();
    psTime.close();

    // Respaldo por seguridad en caso de que la consulta falle
    if (fechaHoy == null || horaActual == null) {
        fechaHoy = LocalDate.now();
        horaActual = LocalTime.now().truncatedTo(ChronoUnit.SECONDS);
    }

    // Obtener la hora de entrada y tolerancia configuradas en la BD
    LocalTime horaLimite = LocalTime.of(8, 15, 0); 
    int toleranciaMinutos = 0;

    PreparedStatement psConf = con.prepareStatement("SELECT hora_entrada, tolerancia_minutos FROM configuracion_horario LIMIT 1");
    ResultSet rsConf = psConf.executeQuery();
    if (rsConf.next()) {
        Time hEntradaDb = rsConf.getTime("hora_entrada");
        if (hEntradaDb != null) {
            horaLimite = hEntradaDb.toLocalTime();
        }
        toleranciaMinutos = rsConf.getInt("tolerancia_minutos");
    }
    rsConf.close();
    psConf.close();

    // Sumar los minutos de tolerancia a la hora límite permitida
    LocalTime horaConTolerancia = horaLimite.plusMinutes(toleranciaMinutos);

    ps = con.prepareStatement("select * from asistencias where persona_id = ? and fecha = ?");
    ps.setInt(1, personaId);
    ps.setDate(2, java.sql.Date.valueOf(fechaHoy));
    rs = ps.executeQuery();

    if (!rs.next()) {
        rs.close();
        ps.close();

        int minutosTardanza = 0;
        String estado = "entrada registrada";

        // Si marca después de la hora límite + tolerancia, se cuenta la tardanza
        if (horaActual.isAfter(horaConTolerancia)) {
            minutosTardanza = (int) ChronoUnit.MINUTES.between(horaConTolerancia, horaActual);
            estado = "tardanza";
            
            // APLICAR AUTOMÁTICAMENTE EL DESCUENTO DE 50.000 Gs. EN LA LIQUIDACIÓN
            int mesActual = fechaHoy.getMonthValue();
            int anioActual = fechaHoy.getYear();
            double montoDescuentoTardanza = 50000;
            int motivoTardanzaId = 1; // ID 1 corresponde a "llegada tardía"

            PreparedStatement psDesc = con.prepareStatement(
                "INSERT INTO descuentos_persona (persona_id, motivo_id, monto_aplicado, mes, anio) VALUES (?, ?, ?, ?, ?)"
            );
            psDesc.setInt(1, personaId);
            psDesc.setInt(2, motivoTardanzaId);
            psDesc.setDouble(3, montoDescuentoTardanza);
            psDesc.setInt(4, mesActual);
            psDesc.setInt(5, anioActual);
            psDesc.executeUpdate();
            psDesc.close();
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