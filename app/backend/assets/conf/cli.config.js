module.exports = {
  process: {
    pidFile: process.env.APP_PROCESS_PID_FILE ?? "/var/run/nanolog.pid"
  },
}