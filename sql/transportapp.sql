-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 03-01-2026 a las 19:32:21
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `transportapp`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transporte_departure_templates`
--

CREATE TABLE `transporte_departure_templates` (
  `id` int(11) NOT NULL,
  `direction` enum('VIC_TO_LLE','LLE_TO_VIC') NOT NULL,
  `depart_time` time NOT NULL,
  `capacity_passengers` int(11) NOT NULL DEFAULT 7,
  `active` tinyint(4) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `transporte_departure_templates`
--

INSERT INTO `transporte_departure_templates` (`id`, `direction`, `depart_time`, `capacity_passengers`, `active`) VALUES
(1, 'VIC_TO_LLE', '06:30:00', 7, 1),
(2, 'LLE_TO_VIC', '07:30:00', 7, 1),
(3, 'VIC_TO_LLE', '09:00:00', 7, 1),
(4, 'LLE_TO_VIC', '10:00:00', 7, 1),
(5, 'VIC_TO_LLE', '11:00:00', 7, 1),
(6, 'LLE_TO_VIC', '12:00:00', 7, 1),
(7, 'VIC_TO_LLE', '13:00:00', 7, 1),
(8, 'LLE_TO_VIC', '14:00:00', 7, 1),
(9, 'VIC_TO_LLE', '16:00:00', 7, 1),
(10, 'LLE_TO_VIC', '17:00:00', 7, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transporte_payments`
--

CREATE TABLE `transporte_payments` (
  `id` bigint(20) NOT NULL,
  `reservation_id` bigint(20) NOT NULL,
  `method` enum('TRANSFER','CASH') NOT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `status` enum('PENDING','VERIFIED','REJECTED') NOT NULL DEFAULT 'PENDING',
  `reference` varchar(80) DEFAULT NULL,
  `proof_url` varchar(255) DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `transporte_payments`
--

INSERT INTO `transporte_payments` (`id`, `reservation_id`, `method`, `amount`, `status`, `reference`, `proof_url`, `verified_at`, `created_at`) VALUES
(1, 5, 'TRANSFER', NULL, 'VERIFIED', NULL, NULL, '2026-01-02 23:10:35', '2026-01-02 23:10:35'),
(2, 6, 'CASH', NULL, 'VERIFIED', NULL, NULL, '2026-01-03 17:41:13', '2026-01-03 17:41:13');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transporte_reservations`
--

CREATE TABLE `transporte_reservations` (
  `id` bigint(20) NOT NULL,
  `trip_id` bigint(20) NOT NULL,
  `type` enum('PASSENGER','PACKAGE') NOT NULL,
  `seats` int(11) NOT NULL DEFAULT 1,
  `customer_name` varchar(120) NOT NULL,
  `phone` varchar(30) NOT NULL,
  `package_details` varchar(255) DEFAULT NULL,
  `status` enum('PENDING_PAYMENT','PAID','CANCELLED') NOT NULL DEFAULT 'PENDING_PAYMENT',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `transporte_reservations`
--

INSERT INTO `transporte_reservations` (`id`, `trip_id`, `type`, `seats`, `customer_name`, `phone`, `package_details`, `status`, `created_at`) VALUES
(5, 10, 'PASSENGER', 1, 'Ladislao Rivera Mireles', '8341754423', NULL, 'PAID', '2026-01-02 23:09:54'),
(6, 15, 'PASSENGER', 1, 'bsdnz', '8344756376', NULL, 'PAID', '2026-01-03 17:39:02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transporte_reservation_passengers`
--

CREATE TABLE `transporte_reservation_passengers` (
  `id` bigint(20) NOT NULL,
  `reservation_id` bigint(20) NOT NULL,
  `passenger_name` varchar(120) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `transporte_reservation_passengers`
--

INSERT INTO `transporte_reservation_passengers` (`id`, `reservation_id`, `passenger_name`, `created_at`) VALUES
(1, 5, 'Ladislao Rivera Mireles', '2026-01-02 23:09:54'),
(2, 6, 'bsdnz', '2026-01-03 17:39:02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transporte_tickets`
--

CREATE TABLE `transporte_tickets` (
  `id` bigint(20) NOT NULL,
  `reservation_id` bigint(20) NOT NULL,
  `code` char(12) NOT NULL,
  `issued_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `transporte_tickets`
--

INSERT INTO `transporte_tickets` (`id`, `reservation_id`, `code`, `issued_at`) VALUES
(1, 5, 'XCHEVUKSRRY8', '2026-01-02 23:10:35'),
(2, 6, 'MWRQG55F9NFD', '2026-01-03 17:41:13');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transporte_trips`
--

CREATE TABLE `transporte_trips` (
  `id` bigint(20) NOT NULL,
  `template_id` int(11) NOT NULL,
  `trip_date` date NOT NULL,
  `status` enum('OPEN','CLOSED','CANCELLED') NOT NULL DEFAULT 'OPEN',
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `transporte_trips`
--

INSERT INTO `transporte_trips` (`id`, `template_id`, `trip_date`, `status`, `notes`, `created_at`) VALUES
(1, 1, '2026-01-02', 'OPEN', NULL, '2026-01-02 20:35:49'),
(2, 3, '2026-01-02', 'OPEN', NULL, '2026-01-02 20:35:49'),
(3, 5, '2026-01-02', 'OPEN', NULL, '2026-01-02 20:35:49'),
(4, 7, '2026-01-02', 'OPEN', NULL, '2026-01-02 20:35:49'),
(5, 9, '2026-01-02', 'OPEN', NULL, '2026-01-02 20:35:49'),
(6, 2, '2026-01-02', 'OPEN', NULL, '2026-01-02 20:35:51'),
(7, 4, '2026-01-02', 'OPEN', NULL, '2026-01-02 20:35:51'),
(8, 6, '2026-01-02', 'OPEN', NULL, '2026-01-02 20:35:51'),
(9, 8, '2026-01-02', 'OPEN', NULL, '2026-01-02 20:35:51'),
(10, 10, '2026-01-02', 'OPEN', NULL, '2026-01-02 20:35:51'),
(11, 1, '2026-01-03', 'OPEN', NULL, '2026-01-02 22:55:51'),
(12, 3, '2026-01-03', 'OPEN', NULL, '2026-01-02 22:55:51'),
(13, 5, '2026-01-03', 'OPEN', NULL, '2026-01-02 22:55:51'),
(14, 7, '2026-01-03', 'OPEN', NULL, '2026-01-02 22:55:51'),
(15, 9, '2026-01-03', 'OPEN', NULL, '2026-01-02 22:55:51'),
(16, 1, '2026-01-04', 'OPEN', NULL, '2026-01-02 23:06:09'),
(17, 3, '2026-01-04', 'OPEN', NULL, '2026-01-02 23:06:09'),
(18, 5, '2026-01-04', 'OPEN', NULL, '2026-01-02 23:06:09'),
(19, 7, '2026-01-04', 'OPEN', NULL, '2026-01-02 23:06:09'),
(20, 9, '2026-01-04', 'OPEN', NULL, '2026-01-02 23:06:09'),
(21, 1, '2026-01-05', 'OPEN', NULL, '2026-01-02 23:06:10'),
(22, 3, '2026-01-05', 'OPEN', NULL, '2026-01-02 23:06:10'),
(23, 5, '2026-01-05', 'OPEN', NULL, '2026-01-02 23:06:10'),
(24, 7, '2026-01-05', 'OPEN', NULL, '2026-01-02 23:06:10'),
(25, 9, '2026-01-05', 'OPEN', NULL, '2026-01-02 23:06:10'),
(26, 2, '2026-01-03', 'OPEN', NULL, '2026-01-03 00:02:27'),
(27, 4, '2026-01-03', 'OPEN', NULL, '2026-01-03 00:02:27'),
(28, 6, '2026-01-03', 'OPEN', NULL, '2026-01-03 00:02:27'),
(29, 8, '2026-01-03', 'OPEN', NULL, '2026-01-03 00:02:27'),
(30, 10, '2026-01-03', 'OPEN', NULL, '2026-01-03 00:02:27'),
(31, 2, '2026-01-04', 'OPEN', NULL, '2026-01-03 00:02:30'),
(32, 4, '2026-01-04', 'OPEN', NULL, '2026-01-03 00:02:30'),
(33, 6, '2026-01-04', 'OPEN', NULL, '2026-01-03 00:02:30'),
(34, 8, '2026-01-04', 'OPEN', NULL, '2026-01-03 00:02:30'),
(35, 10, '2026-01-04', 'OPEN', NULL, '2026-01-03 00:02:30'),
(36, 2, '2026-01-05', 'OPEN', NULL, '2026-01-03 00:02:32'),
(37, 4, '2026-01-05', 'OPEN', NULL, '2026-01-03 00:02:32'),
(38, 6, '2026-01-05', 'OPEN', NULL, '2026-01-03 00:02:32'),
(39, 8, '2026-01-05', 'OPEN', NULL, '2026-01-03 00:02:32'),
(40, 10, '2026-01-05', 'OPEN', NULL, '2026-01-03 00:02:32');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `transporte_departure_templates`
--
ALTER TABLE `transporte_departure_templates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `direction` (`direction`,`depart_time`);

--
-- Indices de la tabla `transporte_payments`
--
ALTER TABLE `transporte_payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_transporte_pay_res` (`reservation_id`);

--
-- Indices de la tabla `transporte_reservations`
--
ALTER TABLE `transporte_reservations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_transporte_res_trip` (`trip_id`),
  ADD KEY `idx_transporte_res_phone` (`phone`);

--
-- Indices de la tabla `transporte_reservation_passengers`
--
ALTER TABLE `transporte_reservation_passengers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reservation_id` (`reservation_id`);

--
-- Indices de la tabla `transporte_tickets`
--
ALTER TABLE `transporte_tickets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_transporte_tk_res` (`reservation_id`);

--
-- Indices de la tabla `transporte_trips`
--
ALTER TABLE `transporte_trips`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `template_id` (`template_id`,`trip_date`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `transporte_departure_templates`
--
ALTER TABLE `transporte_departure_templates`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `transporte_payments`
--
ALTER TABLE `transporte_payments`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `transporte_reservations`
--
ALTER TABLE `transporte_reservations`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `transporte_reservation_passengers`
--
ALTER TABLE `transporte_reservation_passengers`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `transporte_tickets`
--
ALTER TABLE `transporte_tickets`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `transporte_trips`
--
ALTER TABLE `transporte_trips`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `transporte_payments`
--
ALTER TABLE `transporte_payments`
  ADD CONSTRAINT `fk_transporte_pay_res` FOREIGN KEY (`reservation_id`) REFERENCES `transporte_reservations` (`id`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `transporte_reservations`
--
ALTER TABLE `transporte_reservations`
  ADD CONSTRAINT `fk_transporte_res_trip` FOREIGN KEY (`trip_id`) REFERENCES `transporte_trips` (`id`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `transporte_reservation_passengers`
--
ALTER TABLE `transporte_reservation_passengers`
  ADD CONSTRAINT `fk_transporte_res_passengers_res` FOREIGN KEY (`reservation_id`) REFERENCES `transporte_reservations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `transporte_tickets`
--
ALTER TABLE `transporte_tickets`
  ADD CONSTRAINT `fk_transporte_tk_res` FOREIGN KEY (`reservation_id`) REFERENCES `transporte_reservations` (`id`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `transporte_trips`
--
ALTER TABLE `transporte_trips`
  ADD CONSTRAINT `fk_transporte_trips_template` FOREIGN KEY (`template_id`) REFERENCES `transporte_departure_templates` (`id`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
