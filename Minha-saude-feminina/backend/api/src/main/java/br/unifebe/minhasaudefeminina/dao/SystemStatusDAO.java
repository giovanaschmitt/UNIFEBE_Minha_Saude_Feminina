package br.unifebe.minhasaudefeminina.dao;

import br.unifebe.minhasaudefeminina.model.SystemStatus; 
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Repository;
import javax.sql.DataSource;
import java.sql.*;

@Repository
public class SystemStatusDAO {

    @Autowired
    private DataSource dataSource;

    @Autowired
    private StringRedisTemplate redisTemplate;

    public SystemStatus getCurrentStatus() {
        SystemStatus status = new SystemStatus(); 

        // Lógica Oracle
        try (Connection conn = dataSource.getConnection()) {
            status.getDatabase().status = "UP";
            status.getDatabase().user = conn.getMetaData().getUserName();
            status.getDatabase().version = conn.getMetaData().getDatabaseProductVersion();
            
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT sys_context('USERENV', 'CON_NAME') FROM dual")) {
                if (rs.next()) status.getDatabase().serviceName = rs.getString(1);
            }
        } catch (Exception e) {
            status.getDatabase().status = "DOWN";
        }

        // Lógica Redis
        try {
            var factory = redisTemplate.getConnectionFactory();

            if (factory != null) {
                status.getCache().ping = factory.getConnection().ping();
                status.getCache().status = "UP";
            } else {
                System.err.println("REDIS: ConnectionFactory está nula.");
            }
        } catch (Exception e) {
            status.getCache().status = "DOWN";
        }

        return status;
    }
}