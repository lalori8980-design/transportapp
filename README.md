# TransportApp 🚐✨

Aplicación web para **gestionar y reservar servicios de transporte**, con panel de administración y flujo de reservación/pago.  
Construida con **Node.js + Express + EJS**, enfocada en un sistema sencillo, rápido y fácil de desplegar.

---

## 🧩 Características

- Sitio público para:
  - Reservar viajes
  - Generar ticket / confirmación
  - Flujo de pago (pantalla / endpoint)
- Panel de administración para:
  - Login de administrador
  - Agenda de viajes
  - Gestión de viajes (crear/editar)
- Plantillas **EJS** con layout y partials
- Tema UI (CSS/JS) centralizado para estilos y comportamiento

---

## 🛠️ Tecnologías

- **Node.js**
- **Express**
- **EJS** (views)
- JavaScript / CSS (tema)
- Base de datos (configurable desde `src/db.js`)

---

## 📁 Estructura del proyecto

```txt
transportapp/
├─ public/
│  ├─ css/
│  │  └─ theme.css
│  └─ js/
│     └─ theme.js
├─ src/
│  ├─ db.js
│  └─ routes/
│     ├─ admin.js
│     └─ public.js
├─ views/
│  ├─ partials/
│  │  ├─ head.ejs
│  │  ├─ navbar.ejs
│  │  └─ scripts.ejs
│  ├─ layout.ejs
│  ├─ index.ejs
│  ├─ reserve.ejs
│  ├─ pay.ejs
│  ├─ ticket.ejs
│  ├─ admin_login.ejs
│  ├─ admin_agenda.ejs
│  └─ admin_trip.ejs
└─ server.js
