const mysql = require("mysql2/promise");

const cleanEnv = (v) =>
    (v ?? "")
        .toString()
        .trim()
        .replace(/^['"]|['"]$/g, ""); // quito comillas al inicio/fin

const DB_HOST_RAW = cleanEnv(process.env.DB_HOST);
const DB_HOST =
    DB_HOST_RAW === "localhost" || DB_HOST_RAW === "::1" ? "127.0.0.1" : DB_HOST_RAW;

const DB_PORT = Number(cleanEnv(process.env.DB_PORT) || 3306);
const DB_USER = cleanEnv(process.env.DB_USER);
const DB_PASS = cleanEnv(process.env.DB_PASS);
const DB_NAME = cleanEnv(process.env.DB_NAME);

const hasDb = !!DB_HOST && !!DB_USER && !!DB_NAME && !!DB_PASS;

let pool = null;

if (hasDb) {
    pool = mysql.createPool({
        host: DB_HOST,
        port: DB_PORT,
        user: DB_USER,
        password: DB_PASS,
        database: DB_NAME,
        connectionLimit: 10,
        dateStrings: true,
    });
}

module.exports = { pool, hasDb };
