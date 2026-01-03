require("dotenv").config();

const express = require("express");
const path = require("path");
const session = require("express-session");

const { pool } = require("./src/db");
const publicRoutes = require("./src/routes/public");
const adminRoutes = require("./src/routes/admin");

const app = express();

// Views
app.set("views", path.join(__dirname, "views"));
app.use(express.static(path.join(__dirname, "public")));

// Body parsers
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Static files (para usar /css/theme.css y /js/theme.js)
app.use(express.static(path.join(__dirname, "..", "public")));

// Sessions (ANTES de /admin)
app.use(session({
    secret: process.env.SESSION_SECRET || "dev_secret_change_me",
    resave: false,
    saveUninitialized: false
}));

// Routes
app.use("/", publicRoutes);
app.use("/admin", adminRoutes);

// Health check
app.get("/health", async (req, res) => {
    try {
        const [[row]] = await pool.query("SELECT 1 AS ok");
        res.json({ ok: row.ok === 1, db: true });
    } catch (e) {
        res.status(500).json({ ok: false, db: false, error: e.message });
    }
});

// Start
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Running on ${process.env.BASE_URL || `http://localhost:${PORT}`}`);
});
