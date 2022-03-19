const numberOrUndefined = (n) => {
  const parsed = Number(n);
  return isNaN(parsed) ? undefined : parsed
};

const numberOrNull = (n) => {
  const parsed = Number(n);
  return isNaN(parsed) ? null : parsed
}

module.exports = {
  app: {
    listen: {
      hostname: process.env.APP_SERVER_HOSTNAME ?? "localhost",
      port: numberOrUndefined(process.env.APP_SERVER_PORT) ?? 3000
    },  
  },
  auth: {
    token: {
      secret: process.env.APP_AUTH_TOKEN_SECRET,
      algorithm: process.env.APP_AUTH_TOKEN_ALGORITHM ?? ["HS256"],
      expiresIn: process.env.APP_AUTH_TOKEN_EXPIRES_IN ?? "30 days",
      issuer: process.env.APP_AUTH_TOKEN_ISSUER
    },
    cors: {
      allowedOrigin: (process.env.APP_CORS_ALLOWED_ORIGIN ?? "").split(",")
    }
  },
  database: {
    postgres: {
      pool: {
        host: process.env.DB_HOST,
        port: Number(process.env.DB_PORT),
        database: process.env.DB_DATABASE,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        max: numberOrNull(process.env.DB_MAX_CONNECTION),
        idleTimeoutMillis: numberOrNull(process.env.DB_IDLE_TIMEOUT_MILLIS),
        connectionTimeoutMillis: numberOrNull(process.env.DB_CONN_TIMEOUT_MILLIS)
      }
    }
  }
}