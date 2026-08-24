import java.sql.*;

public class DBConnection {

    public static Connection getConnection() throws Exception {
        String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
        String user = "neondb_owner";
        String pass = "npg_6rt8OdayAHcm";

        return DriverManager.getConnection(url, user, pass);
    }
}