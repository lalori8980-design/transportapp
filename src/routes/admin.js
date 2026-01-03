const express = require("express");
const bcrypt = require("bcrypt");
const { pool } = require("../db");

const router = express.Router();

function requireAdmin(req, res, next) {
    if (req.session && req.session.admin) return next();
    return res.redirect("/admin/login");
}

function directionLabel(direction) {
    return direction === "VIC_TO_LLE" ? "Victoria → Llera" : "Llera → Victoria";
}

// LOGIN
router.get("/login", (req, res) => {
    res.render("admin_login", { error: null });
});

router.post("/login", async (req, res) => {
    const { user, pass } = req.body;

    if (user !== process.env.ADMIN_USER) {
        return res.render("admin_login", { error: "Usuario o contraseña incorrectos." });
    }

    const hash = process.env.ADMIN_PASS_HASH;
    if (!hash) return res.status(500).send("Falta ADMIN_PASS_HASH en .env");

    const ok = await bcrypt.compare(pass, hash);
    if (!ok) {
        return res.render("admin_login", { error: "Usuario o contraseña incorrectos." });
    }

    req.session.admin = true;
    return res.redirect("/admin/agenda");
});

router.post("/logout", (req, res) => {
    req.session.destroy(() => res.redirect("/admin/login"));
});

// AGENDA (por día)
router.get("/agenda", requireAdmin, async (req, res) => {
    const date = req.query.date || new Date().toISOString().slice(0, 10);

    const [trips] = await pool.query(
        `
            SELECT t.id AS trip_id, t.trip_date, dt.direction, dt.depart_time, dt.capacity_passengers,
                   COALESCE(SUM(CASE WHEN r.type='PASSENGER' AND r.status IN ('PENDING_PAYMENT','PAID') THEN r.seats ELSE 0 END), 0) AS used_seats,
                   COALESCE(SUM(CASE WHEN r.type='PACKAGE' AND r.status IN ('PENDING_PAYMENT','PAID') THEN 1 ELSE 0 END), 0) AS packages
            FROM transporte_trips t
                     JOIN transporte_departure_templates dt ON dt.id = t.template_id
                     LEFT JOIN transporte_reservations r ON r.trip_id = t.id
            WHERE t.trip_date = ?
            GROUP BY t.id, t.trip_date, dt.direction, dt.depart_time, dt.capacity_passengers
            ORDER BY dt.depart_time
        `,
        [date]
    );

    res.render("admin_agenda", { date, trips, directionLabel });
});

// DETALLE SALIDA
router.get("/trip/:tripId", requireAdmin, async (req, res) => {
    const { tripId } = req.params;
    const onlyPending = req.query.onlyPending === "1";

    const [[trip]] = await pool.query(
        `
            SELECT t.id AS trip_id, t.trip_date, dt.direction, dt.depart_time, dt.capacity_passengers
            FROM transporte_trips t
                     JOIN transporte_departure_templates dt ON dt.id = t.template_id
            WHERE t.id = ?
        `,
        [tripId]
    );
    if (!trip) return res.status(404).send("Salida no encontrada.");

    const [reservations] = await pool.query(
        `
            SELECT r.*,
                   (SELECT tk.code FROM transporte_tickets tk WHERE tk.reservation_id = r.id LIMIT 1) AS ticket_code,
      GROUP_CONCAT(p.passenger_name ORDER BY p.id SEPARATOR ', ') AS passenger_names
            FROM transporte_reservations r
                LEFT JOIN transporte_reservation_passengers p ON p.reservation_id = r.id
            WHERE r.trip_id = ?
              AND (? = 0 OR r.status <> 'PAID')
            GROUP BY r.id
            ORDER BY r.created_at
        `,
        [tripId, onlyPending ? 1 : 0]
    );

    res.render("admin_trip", {
        trip,
        reservations,
        directionLabel,
        onlyPending,
        baseUrl: process.env.BASE_URL
    });
});

function randomTicketCode(len = 12) {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    let out = "";
    for (let i = 0; i < len; i++) out += chars[Math.floor(Math.random() * chars.length)];
    return out;
}

// MARCAR PAGADO + CREAR TICKET + REDIRECT CON RETURN
router.post("/reservation/:reservationId/mark-paid", requireAdmin, async (req, res) => {
    const { reservationId } = req.params;
    const method = (req.body.method === "TRANSFER") ? "TRANSFER" : "CASH";

    const conn = await pool.getConnection();
    try {
        await conn.beginTransaction();

        // lock reservation
        const [[r]] = await conn.query(
            `
                SELECT r.id, r.status, r.trip_id
                FROM transporte_reservations r
                WHERE r.id = ? FOR UPDATE
            `,
            [reservationId]
        );
        if (!r) throw new Error("Reserva no encontrada.");

        if (r.status !== "PAID") {
            await conn.query(`UPDATE transporte_reservations SET status='PAID' WHERE id=?`, [reservationId]);

            await conn.query(
                `
        INSERT INTO transporte_payments(reservation_id, method, status, verified_at)
        VALUES (?, ?, 'VERIFIED', NOW())
        `,
                [reservationId, method]
            );
        }

        // only one ticket
        const [[existing]] = await conn.query(
            `SELECT code FROM transporte_tickets WHERE reservation_id=?`,
            [reservationId]
        );

        let code = existing?.code;

        if (!code) {
            for (let i = 0; i < 6; i++) {
                const candidate = randomTicketCode(12);
                try {
                    await conn.query(
                        `INSERT INTO transporte_tickets(reservation_id, code) VALUES (?, ?)`,
                        [reservationId, candidate]
                    );
                    code = candidate;
                    break;
                } catch {
                    // duplicate, retry
                }
            }
            if (!code) throw new Error("No pude generar ticket. Intenta otra vez.");
        }

        await conn.commit();

        // ✅ return to the same trip detail after viewing ticket
        const returnTo = `/admin/trip/${r.trip_id}`;
        return res.redirect(`/ticket/${code}?return=${encodeURIComponent(returnTo)}`);

    } catch (e) {
        await conn.rollback();
        return res.status(500).send(e.message);
    } finally {
        conn.release();
    }
});

// CANCELAR
router.post("/reservation/:reservationId/cancel", requireAdmin, async (req, res) => {
    const { reservationId } = req.params;

    const conn = await pool.getConnection();
    try {
        await conn.beginTransaction();

        const [[r]] = await conn.query(
            `SELECT id, trip_id, status FROM transporte_reservations WHERE id=? FOR UPDATE`,
            [reservationId]
        );
        if (!r) throw new Error("Reserva no encontrada.");

        if (r.status !== "CANCELLED") {
            await conn.query(`UPDATE transporte_reservations SET status='CANCELLED' WHERE id=?`, [reservationId]);
        }

        await conn.query(
            `UPDATE transporte_payments
             SET status='REJECTED'
             WHERE reservation_id=? AND status='PENDING'`,
            [reservationId]
        );

        await conn.commit();
        return res.redirect(`/admin/trip/${r.trip_id}`);
    } catch (e) {
        await conn.rollback();
        return res.status(500).send(e.message);
    } finally {
        conn.release();
    }
});

module.exports = router;
