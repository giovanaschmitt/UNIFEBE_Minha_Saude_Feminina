package br.unifebe.minhasaudefeminina.model;

public class SystemStatus {
    private final DatabaseStatus database = new DatabaseStatus();
    private final CacheStatus cache = new CacheStatus();


    public DatabaseStatus getDatabase() {
        return database;
    }

    public CacheStatus getCache() {
        return cache;
    }

    public static class DatabaseStatus {
        public String status;
        public String serviceName;
        public String user;
        public String version;
    }

    public static class CacheStatus {
        public String status;
        public String ping;
    }
}