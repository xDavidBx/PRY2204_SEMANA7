-- =====================================================================
-- HOLDING CARPENTER SPA - Oracle SQL Developer
-- Ejecutar como script (F5) en el orden en que aparece.
-- =====================================================================

-- (OPCIONAL) Limpieza para volver a ejecutar desde cero:
-- DROP TABLE dominio CASCADE CONSTRAINTS;
-- DROP TABLE titulacion CASCADE CONSTRAINTS;
-- DROP TABLE personal CASCADE CONSTRAINTS;
-- DROP TABLE idioma CASCADE CONSTRAINTS;
-- DROP TABLE titulo CASCADE CONSTRAINTS;
-- DROP TABLE estado_civil CASCADE CONSTRAINTS;
-- DROP TABLE genero CASCADE CONSTRAINTS;
-- DROP TABLE compania CASCADE CONSTRAINTS;
-- DROP TABLE comuna CASCADE CONSTRAINTS;
-- DROP TABLE region CASCADE CONSTRAINTS;
-- DROP SEQUENCE seq_comuna;
-- DROP SEQUENCE seq_compania;

-- =====================================================================
-- CASO 1: IMPLEMENTACION DEL MODELO (de tablas fuertes a debiles)
-- =====================================================================

-- 1) REGION (identity: inicia en 7, incrementa en 2)
CREATE TABLE region (
    id_region     NUMBER(2) GENERATED ALWAYS AS IDENTITY (START WITH 7 INCREMENT BY 2) NOT NULL,
    nombre_region VARCHAR2(25) NOT NULL,
    CONSTRAINT region_pk PRIMARY KEY (id_region)
);

-- 2) COMUNA (PK compuesta)
CREATE TABLE comuna (
    id_comuna     NUMBER(5)    NOT NULL,
    comuna_nombre VARCHAR2(25) NOT NULL,
    cod_region    NUMBER(2)    NOT NULL,
    CONSTRAINT comuna_pk        PRIMARY KEY (id_comuna, cod_region),
    CONSTRAINT comuna_fk_region FOREIGN KEY (cod_region) REFERENCES region (id_region)
);

-- 3) COMPANIA
CREATE TABLE compania (
    id_empresa     NUMBER(2)    NOT NULL,
    nombre_empresa VARCHAR2(25) NOT NULL,
    calle          VARCHAR2(50) NOT NULL,
    numeracion     NUMBER(5)    NOT NULL,
    renta_promedio NUMBER(10)   NOT NULL,
    pct_aumento    NUMBER(4,3),
    cod_comuna     NUMBER(5)    NOT NULL,
    cod_region     NUMBER(2)    NOT NULL,
    CONSTRAINT compania_pk        PRIMARY KEY (id_empresa),
    CONSTRAINT compania_un_nombre UNIQUE (nombre_empresa),
    CONSTRAINT compania_fk_comuna FOREIGN KEY (cod_comuna, cod_region)
        REFERENCES comuna (id_comuna, cod_region)
);

-- 4) GENERO
CREATE TABLE genero (
    id_genero          VARCHAR2(3)  NOT NULL,
    descripcion_genero VARCHAR2(25) NOT NULL,
    CONSTRAINT genero_pk PRIMARY KEY (id_genero)
);

-- 5) ESTADO_CIVIL
CREATE TABLE estado_civil (
    id_estado_civil       VARCHAR2(2)  NOT NULL,
    descripcion_est_civil VARCHAR2(25) NOT NULL,
    CONSTRAINT estado_civil_pk PRIMARY KEY (id_estado_civil)
);

-- 6) TITULO
CREATE TABLE titulo (
    id_titulo          VARCHAR2(3)  NOT NULL,
    descripcion_titulo VARCHAR2(60) NOT NULL,
    CONSTRAINT titulo_pk PRIMARY KEY (id_titulo)
);

-- 7) IDIOMA (identity: inicia en 25, incrementa en 3)
CREATE TABLE idioma (
    id_idioma     NUMBER(3) GENERATED ALWAYS AS IDENTITY (START WITH 25 INCREMENT BY 3) NOT NULL,
    nombre_idioma VARCHAR2(30) NOT NULL,
    CONSTRAINT idioma_pk PRIMARY KEY (id_idioma)
);

-- 8) PERSONAL (auto-relacion: encargado_rut)
CREATE TABLE personal (
    rut_persona       NUMBER(8)     NOT NULL,
    dv_persona        CHAR(1)       NOT NULL,
    primer_nombre     VARCHAR2(25)  NOT NULL,
    segundo_nombre    VARCHAR2(25),
    primer_apellido   VARCHAR2(25)  NOT NULL,
    segundo_apellido  VARCHAR2(25)  NOT NULL,
    fecha_contratacion DATE         NOT NULL,
    fecha_nacimiento  DATE          NOT NULL,
    email             VARCHAR2(100),
    calle             VARCHAR2(50)  NOT NULL,
    numeracion        NUMBER(5)     NOT NULL,
    sueldo            NUMBER(7)     NOT NULL,
    cod_comuna        NUMBER(5)     NOT NULL,
    cod_region        NUMBER(2)     NOT NULL,
    cod_genero        VARCHAR2(3),
    cod_estado_civil  VARCHAR2(2)   NOT NULL,
    cod_empresa       NUMBER(2)     NOT NULL,
    encargado_rut     NUMBER(8),
    CONSTRAINT personal_pk              PRIMARY KEY (rut_persona),
    CONSTRAINT personal_fk_compania     FOREIGN KEY (cod_empresa)
        REFERENCES compania (id_empresa),
    CONSTRAINT personal_fk_comuna       FOREIGN KEY (cod_comuna, cod_region)
        REFERENCES comuna (id_comuna, cod_region),
    CONSTRAINT personal_fk_estado_civil FOREIGN KEY (cod_estado_civil)
        REFERENCES estado_civil (id_estado_civil),
    CONSTRAINT personal_fk_genero       FOREIGN KEY (cod_genero)
        REFERENCES genero (id_genero),
    CONSTRAINT personal_fk_personal     FOREIGN KEY (encargado_rut)
        REFERENCES personal (rut_persona)
);

-- 9) TITULACION (PK compuesta)
CREATE TABLE titulacion (
    cod_titulo       VARCHAR2(3) NOT NULL,
    persona_rut      NUMBER(8)   NOT NULL,
    fecha_titulacion DATE        NOT NULL,
    CONSTRAINT titulacion_pk         PRIMARY KEY (cod_titulo, persona_rut),
    CONSTRAINT titulacion_fk_titulo  FOREIGN KEY (cod_titulo)  REFERENCES titulo (id_titulo),
    CONSTRAINT titulacion_fk_persona FOREIGN KEY (persona_rut) REFERENCES personal (rut_persona)
);

-- 10) DOMINIO (PK compuesta)
CREATE TABLE dominio (
    id_idioma   NUMBER(3)    NOT NULL,
    persona_rut NUMBER(8)    NOT NULL,
    nivel       VARCHAR2(25) NOT NULL,
    CONSTRAINT dominio_pk          PRIMARY KEY (id_idioma, persona_rut),
    CONSTRAINT dominio_fk_idioma   FOREIGN KEY (id_idioma)   REFERENCES idioma (id_idioma),
    CONSTRAINT dominio_fk_personal FOREIGN KEY (persona_rut) REFERENCES personal (rut_persona)
);

-- =====================================================================
-- CASO 2: MODIFICACION DEL MODELO (ALTER TABLE)
-- =====================================================================

-- Email opcional pero no repetido
ALTER TABLE personal
    ADD CONSTRAINT personal_un_email UNIQUE (email);

-- Digito verificador: 0-9 o 'K'
ALTER TABLE personal
    ADD CONSTRAINT personal_ck_dv
    CHECK (dv_persona IN ('0','1','2','3','4','5','6','7','8','9','K'));

-- Sueldo minimo 450.000
ALTER TABLE personal
    ADD CONSTRAINT personal_ck_sueldo
    CHECK (sueldo >= 450000);

-- =====================================================================
-- CASO 3: POBLAMIENTO (orden segun dependencias)
-- IDIOMA -> REGION -> COMUNA -> COMPANIA
-- =====================================================================

-- Secuencias
CREATE SEQUENCE seq_comuna   START WITH 1101 INCREMENT BY 6 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_compania START WITH 10   INCREMENT BY 5 NOCACHE NOCYCLE;

-- IDIOMA (identity: 25, 28, 31, 34, 37)
INSERT INTO idioma (nombre_idioma) VALUES ('Ingles');
INSERT INTO idioma (nombre_idioma) VALUES ('Chino');
INSERT INTO idioma (nombre_idioma) VALUES ('Aleman');
INSERT INTO idioma (nombre_idioma) VALUES ('Espanol');
INSERT INTO idioma (nombre_idioma) VALUES ('Frances');

-- REGION (identity: 7, 9, 11)
INSERT INTO region (nombre_region) VALUES ('ARICA Y PARINACOTA');
INSERT INTO region (nombre_region) VALUES ('METROPOLITANA');
INSERT INTO region (nombre_region) VALUES ('LA ARAUCANIA');

-- COMUNA (secuencia: 1101, 1107, 1113)
INSERT INTO comuna (id_comuna, comuna_nombre, cod_region) VALUES (seq_comuna.NEXTVAL, 'Arica',    7);
INSERT INTO comuna (id_comuna, comuna_nombre, cod_region) VALUES (seq_comuna.NEXTVAL, 'Santiago', 9);
INSERT INTO comuna (id_comuna, comuna_nombre, cod_region) VALUES (seq_comuna.NEXTVAL, 'Temuco',   11);

-- COMPANIA (secuencia: 10, 15, 20, ... 55)
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'CCyRojas', 'Amapolas', 506, 1857000, 0.5, 1101, 7);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'SenTTy', 'Los Alamos', 3490, 897000, 0.025, 1101, 7);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'Praxia LTDA', 'Las Camelias', 11098, 2157000, 0.035, 1107, 9);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'TIC spa', 'FLORES S.A.', 4357, 857000, NULL, 1107, 9);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'SANTANA LTDA', 'AVDA VIC. MACKENA', 106, 757000, 0.015, 1101, 7);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'FLORES Y ASOCIADOS', 'PEDRO LATORRE', 557, 589000, 0.015, 1107, 9);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'J.A. HOFFMAN', 'LATINA D.32', 509, 1857000, 0.025, 1113, 11);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'CAGLIARI D.', 'ALAMEDA', 206, 1857000, NULL, 1113, 11);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'Rojas HNOS LTDA', 'SUCRE', 106, 957000, 0.015, 1113, 11);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'FRIENDS P. S.A', 'SUECIA', 506, 857000, 0.015, 1113, 11);

COMMIT;

-- Verificacion del poblamiento
SELECT * FROM idioma;
SELECT * FROM region;
SELECT * FROM comuna;
SELECT * FROM compania;

-- =====================================================================
-- CASO 4: RECUPERACION DE DATOS
-- =====================================================================

-- INFORME 1: Simulacion de Renta Promedio
SELECT nombre_empresa                              AS "Nombre Empresa",
       calle || ' ' || numeracion                  AS "Dirección",
       renta_promedio                              AS "Renta Promedio",
       renta_promedio + (renta_promedio * pct_aumento) AS "Simulación de Renta"
FROM   compania
ORDER  BY renta_promedio DESC,
          nombre_empresa ASC;

-- INFORME 2: Nueva simulacion (+15% adicional al porcentaje registrado)
SELECT id_empresa                                  AS "CODIGO",
       nombre_empresa                              AS "EMPRESA",
       renta_promedio                              AS "PROM RENTA ACTUAL",
       pct_aumento + 0.15                          AS "PCT AUMENTADO EN 15%",
       renta_promedio * (pct_aumento + 0.15)       AS "RENTA AUMENTADA"
FROM   compania
ORDER  BY renta_promedio ASC,
          nombre_empresa DESC;