CREATE DATABASE IF NOT EXISTS inventario_lab CHARACTER SET utf8mb4;
USE inventario_lab;
CREATE TABLE servicios (
  id INT PRIMARY KEY,
  nombre VARCHAR(60) NOT NULL,
  puerto_interno INT NOT NULL,
  protocolo VARCHAR(20) NOT NULL,
  finalidad VARCHAR(120) NOT NULL
);
INSERT INTO servicios VALUES
(1,'WordPress',80,'HTTP','Portal de noticias de practica'),
(2,'OpenSSH',22,'SSH','Enumerar identidad y capacidades SSH'),
(3,'MySQL',3306,'MySQL','Metadatos e inventario de solo lectura');
CREATE TABLE equipo_web (
  id INT PRIMARY KEY,
  nombre VARCHAR(80),
  rol VARCHAR(60),
  contacto VARCHAR(120)
);
INSERT INTO equipo_web VALUES
(1,'Lucia Demo','Redaccion','lucia@example.test'),
(2,'Mateo Demo','Agenda','mateo@example.test');
CREATE TABLE documentos (
  id INT PRIMARY KEY,
  titulo VARCHAR(100),
  clasificacion VARCHAR(30)
);
INSERT INTO documentos VALUES
(10,'Guia del portal','publico'),
(11,'Horario de talleres','publico');
CREATE VIEW v_servicios AS
SELECT nombre,puerto_interno,protocolo FROM servicios;
CREATE USER IF NOT EXISTS 'auditor'@'%' IDENTIFIED BY 'EnumSQL-2026!';
GRANT SELECT, SHOW VIEW ON inventario_lab.* TO 'auditor'@'%';
