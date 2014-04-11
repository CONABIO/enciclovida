--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: lower_unaccent(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION lower_unaccent(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT lower(translate($1
     , '¹²³áàâãäåāăąÀÁÂÃÄÅĀĂĄÆćčç©ĆČÇĐÐèéêёëēĕėęěÉÈÊËЁĒĔĖĘĚ€ğĞıìíîïìĩīĭÌÍÎÏЇÌĨĪĬłŁńňñŃŇÑòóôõöōŏőøÒÓÔÕÖŌŎŐØŒř®ŘšşșßŠŞȘùúûüũūŭůÙÚÛÜŨŪŬŮýÿÝŸžżźŽŻŹ'
     , '123aaaaaaaaaaaaaaaaaaacccccccddeeeeeeeeeeeeeeeeeeeeeggiiiiiiiiiiiiiiiiiillnnnnnnooooooooooooooooooorrrsssssssuuuuuuuuuuuuuuuuyyyyzzzzzz'
     ));

     $_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: bibliografias; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bibliografias (
    id integer NOT NULL,
    autor character varying(255) NOT NULL,
    titulo_publicacion character varying(255) NOT NULL,
    anio numeric(4,0),
    titulo_sub_publicacion character varying(255),
    editorial_pais_pagina character varying(255),
    numero_volumen_anio integer,
    editores_compiladores character varying(255),
    isbnissn character varying(255),
    cita_completa text NOT NULL,
    orden_cita_completa integer,
    observaciones text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE bibliografias; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE bibliografias IS 'bibliografias de nombres, especies, regiones';


--
-- Name: bibliografias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bibliografias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bibliografias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bibliografias_id_seq OWNED BY bibliografias.id;


--
-- Name: bitacoras; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bitacoras (
    id integer NOT NULL,
    descripcion text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    usuario_id integer NOT NULL
);


--
-- Name: TABLE bitacoras; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE bitacoras IS 'Lleva el control de las modificaciones';


--
-- Name: bitacoras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bitacoras_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bitacoras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bitacoras_id_seq OWNED BY bitacoras.id;


--
-- Name: bitacoras_usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bitacoras_usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bitacoras_usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bitacoras_usuario_id_seq OWNED BY bitacoras.usuario_id;


--
-- Name: catalogos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE catalogos (
    id integer NOT NULL,
    descripcion character varying(255) NOT NULL,
    nivel1 smallint NOT NULL,
    nivel2 smallint DEFAULT 0 NOT NULL,
    nivel3 smallint DEFAULT 0 NOT NULL,
    nivel4 smallint DEFAULT 0 NOT NULL,
    nivel5 smallint DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE catalogos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE catalogos IS 'Catalogo de los estados de conservacion';


--
-- Name: catalogos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE catalogos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: catalogos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE catalogos_id_seq OWNED BY catalogos.id;


--
-- Name: categorias_taxonomicas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categorias_taxonomicas (
    id integer NOT NULL,
    nombre_categoria_taxonomica character varying(255) NOT NULL,
    nivel1 smallint NOT NULL,
    nivel2 smallint DEFAULT 0 NOT NULL,
    nivel3 smallint DEFAULT 0 NOT NULL,
    nivel4 smallint DEFAULT 0 NOT NULL,
    ruta_icono character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE categorias_taxonomicas; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE categorias_taxonomicas IS 'Arbol de taxonomia de la especie';


--
-- Name: categorias_taxonomicas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categorias_taxonomicas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categorias_taxonomicas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categorias_taxonomicas_id_seq OWNED BY categorias_taxonomicas.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    queue character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: especies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE especies (
    id integer NOT NULL,
    nombre character varying(255) NOT NULL,
    estatus smallint NOT NULL,
    fuente character varying(255),
    nombre_autoridad character varying(255) DEFAULT 'ND'::character varying NOT NULL,
    numero_filogenetico character varying(255),
    cita_nomenclatural text,
    sis_clas_cat_dicc character varying(255) DEFAULT 'ND'::character varying NOT NULL,
    anotacion character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id_nombre_ascendente integer NOT NULL,
    id_ascend_obligatorio integer NOT NULL,
    categoria_taxonomica_id integer NOT NULL,
    ancestry_acendente_directo character varying(255),
    ancestry_acendente_obligatorio character varying(255),
    nombre_cientifico character varying(255),
    delta boolean DEFAULT false
);


--
-- Name: TABLE especies; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE especies IS 'especies con su nombre cientificos de toda la taxonomia';


--
-- Name: especies_bibliografias; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE especies_bibliografias (
    especie_id integer NOT NULL,
    bibliografia_id integer NOT NULL,
    observaciones text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE especies_bibliografias; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE especies_bibliografias IS 'Relacion entre el nombre cientifico y su autor';


--
-- Name: especies_bibliografias_bibliografia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_bibliografias_bibliografia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_bibliografias_bibliografia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_bibliografias_bibliografia_id_seq OWNED BY especies_bibliografias.bibliografia_id;


--
-- Name: especies_bibliografias_especie_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_bibliografias_especie_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_bibliografias_especie_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_bibliografias_especie_id_seq OWNED BY especies_bibliografias.especie_id;


--
-- Name: especies_catalogos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE especies_catalogos (
    especie_id integer NOT NULL,
    catalogo_id integer NOT NULL,
    observaciones text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE especies_catalogos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE especies_catalogos IS 'Relacion del tipo de estado de conservacioncon la especie';


--
-- Name: especies_catalogos_catalogo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_catalogos_catalogo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_catalogos_catalogo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_catalogos_catalogo_id_seq OWNED BY especies_catalogos.catalogo_id;


--
-- Name: especies_catalogos_especie_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_catalogos_especie_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_catalogos_especie_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_catalogos_especie_id_seq OWNED BY especies_catalogos.especie_id;


--
-- Name: especies_categoria_taxonomica_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_categoria_taxonomica_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_categoria_taxonomica_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_categoria_taxonomica_id_seq OWNED BY especies.categoria_taxonomica_id;


--
-- Name: especies_estatuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE especies_estatuses (
    especie_id1 integer NOT NULL,
    especie_id2 integer NOT NULL,
    estatus_id integer NOT NULL,
    observaciones text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE especies_estatuses; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE especies_estatuses IS 'Relacion entre el nombre y si esta activa o no';


--
-- Name: especies_estatuses_bibliografias; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE especies_estatuses_bibliografias (
    especie_id integer NOT NULL,
    estatus_id integer NOT NULL,
    bibliografia_id integer NOT NULL,
    observaciones text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE especies_estatuses_bibliografias; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE especies_estatuses_bibliografias IS 'Relacion entre los nombre activos e inactivos y su bibliografia';


--
-- Name: especies_estatuses_bibliografias_bibliografia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_estatuses_bibliografias_bibliografia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_estatuses_bibliografias_bibliografia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_estatuses_bibliografias_bibliografia_id_seq OWNED BY especies_estatuses_bibliografias.bibliografia_id;


--
-- Name: especies_estatuses_bibliografias_especie_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_estatuses_bibliografias_especie_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_estatuses_bibliografias_especie_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_estatuses_bibliografias_especie_id_seq OWNED BY especies_estatuses_bibliografias.especie_id;


--
-- Name: especies_estatuses_bibliografias_estatus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_estatuses_bibliografias_estatus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_estatuses_bibliografias_estatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_estatuses_bibliografias_estatus_id_seq OWNED BY especies_estatuses_bibliografias.estatus_id;


--
-- Name: especies_estatuses_especie_id1_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_estatuses_especie_id1_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_estatuses_especie_id1_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_estatuses_especie_id1_seq OWNED BY especies_estatuses.especie_id1;


--
-- Name: especies_estatuses_especie_id2_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_estatuses_especie_id2_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_estatuses_especie_id2_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_estatuses_especie_id2_seq OWNED BY especies_estatuses.especie_id2;


--
-- Name: especies_estatuses_estatus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_estatuses_estatus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_estatuses_estatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_estatuses_estatus_id_seq OWNED BY especies_estatuses.estatus_id;


--
-- Name: especies_id_ascend_obligatorio_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_id_ascend_obligatorio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_id_ascend_obligatorio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_id_ascend_obligatorio_seq OWNED BY especies.id_ascend_obligatorio;


--
-- Name: especies_id_nombre_ascendente_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_id_nombre_ascendente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_id_nombre_ascendente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_id_nombre_ascendente_seq OWNED BY especies.id_nombre_ascendente;


--
-- Name: especies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_id_seq OWNED BY especies.id;


--
-- Name: especies_regiones; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE especies_regiones (
    especie_id integer NOT NULL,
    region_id integer NOT NULL,
    observaciones text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tipo_distribucion_id integer
);


--
-- Name: TABLE especies_regiones; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE especies_regiones IS 'Relacion del tipo de zona y especie';


--
-- Name: especies_regiones_especie_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_regiones_especie_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_regiones_especie_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_regiones_especie_id_seq OWNED BY especies_regiones.especie_id;


--
-- Name: especies_regiones_region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_regiones_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_regiones_region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_regiones_region_id_seq OWNED BY especies_regiones.region_id;


--
-- Name: especies_regiones_tipo_distribucion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE especies_regiones_tipo_distribucion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: especies_regiones_tipo_distribucion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE especies_regiones_tipo_distribucion_id_seq OWNED BY especies_regiones.tipo_distribucion_id;


--
-- Name: estatuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE estatuses (
    id integer NOT NULL,
    descripcion character varying(255) NOT NULL,
    nivel1 smallint NOT NULL,
    nivel2 smallint DEFAULT 0 NOT NULL,
    nivel3 smallint DEFAULT 0 NOT NULL,
    nivel4 smallint DEFAULT 0 NOT NULL,
    nivel5 smallint DEFAULT 0 NOT NULL,
    ruta_icono character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE estatuses; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE estatuses IS 'Taxonomia activa o inactiva';


--
-- Name: estatuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE estatuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: estatuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE estatuses_id_seq OWNED BY estatuses.id;


--
-- Name: listas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE listas (
    id integer NOT NULL,
    nombre_lista character varying(255) NOT NULL,
    columnas text,
    formato character varying(255),
    esta_activa smallint DEFAULT 0 NOT NULL,
    cadena_especies text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    usuario_id integer NOT NULL
);


--
-- Name: TABLE listas; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE listas IS 'Listas para exportar por los usuarios';


--
-- Name: listas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE listas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: listas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE listas_id_seq OWNED BY listas.id;


--
-- Name: listas_usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE listas_usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: listas_usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE listas_usuario_id_seq OWNED BY listas.usuario_id;


--
-- Name: nombres_comunes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nombres_comunes (
    id integer NOT NULL,
    nombre_comun character varying(255) NOT NULL,
    lengua character varying(255) NOT NULL,
    observaciones text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE nombres_comunes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE nombres_comunes IS 'Nombres comunes de toda la taxonomia';


--
-- Name: nombres_comunes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nombres_comunes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nombres_comunes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nombres_comunes_id_seq OWNED BY nombres_comunes.id;


--
-- Name: nombres_regiones; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nombres_regiones (
    especie_id integer NOT NULL,
    region_id integer NOT NULL,
    nombre_comun_id integer NOT NULL,
    observaciones text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE nombres_regiones; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE nombres_regiones IS 'Relaciones del nombre comun con la especie y la region';


--
-- Name: nombres_regiones_bibliografias; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nombres_regiones_bibliografias (
    especie_id integer NOT NULL,
    region_id integer NOT NULL,
    nombre_comun_id integer NOT NULL,
    bibliografia_id integer NOT NULL,
    observaciones text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE nombres_regiones_bibliografias; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE nombres_regiones_bibliografias IS 'Relacion del nombre con la especie, la region y su bibliografia';


--
-- Name: nombres_regiones_bibliografias_bibliografia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nombres_regiones_bibliografias_bibliografia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nombres_regiones_bibliografias_bibliografia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nombres_regiones_bibliografias_bibliografia_id_seq OWNED BY nombres_regiones_bibliografias.bibliografia_id;


--
-- Name: nombres_regiones_bibliografias_especie_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nombres_regiones_bibliografias_especie_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nombres_regiones_bibliografias_especie_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nombres_regiones_bibliografias_especie_id_seq OWNED BY nombres_regiones_bibliografias.especie_id;


--
-- Name: nombres_regiones_bibliografias_nombre_comun_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nombres_regiones_bibliografias_nombre_comun_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nombres_regiones_bibliografias_nombre_comun_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nombres_regiones_bibliografias_nombre_comun_id_seq OWNED BY nombres_regiones_bibliografias.nombre_comun_id;


--
-- Name: nombres_regiones_bibliografias_region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nombres_regiones_bibliografias_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nombres_regiones_bibliografias_region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nombres_regiones_bibliografias_region_id_seq OWNED BY nombres_regiones_bibliografias.region_id;


--
-- Name: nombres_regiones_especie_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nombres_regiones_especie_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nombres_regiones_especie_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nombres_regiones_especie_id_seq OWNED BY nombres_regiones.especie_id;


--
-- Name: nombres_regiones_nombre_comun_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nombres_regiones_nombre_comun_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nombres_regiones_nombre_comun_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nombres_regiones_nombre_comun_id_seq OWNED BY nombres_regiones.nombre_comun_id;


--
-- Name: nombres_regiones_region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nombres_regiones_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nombres_regiones_region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nombres_regiones_region_id_seq OWNED BY nombres_regiones.region_id;


--
-- Name: regiones; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE regiones (
    id integer NOT NULL,
    nombre_region character varying(255) NOT NULL,
    clave_region character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tipo_region_id integer NOT NULL,
    id_region_asc integer NOT NULL,
    ancestry character varying(255)
);


--
-- Name: TABLE regiones; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE regiones IS 'Ubicaciones de las especies';


--
-- Name: regiones_id_region_asc_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE regiones_id_region_asc_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regiones_id_region_asc_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE regiones_id_region_asc_seq OWNED BY regiones.id_region_asc;


--
-- Name: regiones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE regiones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regiones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE regiones_id_seq OWNED BY regiones.id;


--
-- Name: regiones_tipo_region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE regiones_tipo_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regiones_tipo_region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE regiones_tipo_region_id_seq OWNED BY regiones.tipo_region_id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    nombre_rol character varying(255) NOT NULL,
    atributos_base text,
    tablas_adicionales text,
    permisos character varying(255),
    taxonomia_especifica text,
    usuarios_especificos text,
    es_admin smallint DEFAULT 0 NOT NULL,
    es_super_usuario smallint DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE roles; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE roles IS 'Roles de los usuarios';


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sessiones; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sessiones (
    id integer NOT NULL,
    session_id character varying(255) NOT NULL,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sessiones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessiones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessiones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessiones_id_seq OWNED BY sessiones.id;


--
-- Name: tipos_distribuciones; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tipos_distribuciones (
    id integer NOT NULL,
    descripcion character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE tipos_distribuciones; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE tipos_distribuciones IS 'Tipos de distribuciones de las especies';


--
-- Name: tipos_distribuciones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tipos_distribuciones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tipos_distribuciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tipos_distribuciones_id_seq OWNED BY tipos_distribuciones.id;


--
-- Name: tipos_regiones; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tipos_regiones (
    id integer NOT NULL,
    descripcion character varying(255) NOT NULL,
    nivel1 smallint NOT NULL,
    nivel2 smallint DEFAULT 0 NOT NULL,
    nivel3 smallint DEFAULT 0 NOT NULL,
    nivel4 smallint NOT NULL,
    nivel5 smallint DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: TABLE tipos_regiones; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE tipos_regiones IS 'Catalogo de Regiones';


--
-- Name: tipos_regiones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tipos_regiones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tipos_regiones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tipos_regiones_id_seq OWNED BY tipos_regiones.id;


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE usuarios (
    id integer NOT NULL,
    usuario character varying(255) NOT NULL,
    correo character varying(255) NOT NULL,
    nombre character varying(255) NOT NULL,
    apellido character varying(255) NOT NULL,
    institucion character varying(255) NOT NULL,
    grado_academico character varying(255) NOT NULL,
    contrasenia character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    rol_id integer DEFAULT 1 NOT NULL,
    salt character varying(255)
);


--
-- Name: TABLE usuarios; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE usuarios IS 'Usuarios de la aplicacion';


--
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE usuarios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE usuarios_id_seq OWNED BY usuarios.id;


--
-- Name: usuarios_rol_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE usuarios_rol_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuarios_rol_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE usuarios_rol_id_seq OWNED BY usuarios.rol_id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bibliografias ALTER COLUMN id SET DEFAULT nextval('bibliografias_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bitacoras ALTER COLUMN id SET DEFAULT nextval('bitacoras_id_seq'::regclass);


--
-- Name: usuario_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bitacoras ALTER COLUMN usuario_id SET DEFAULT nextval('bitacoras_usuario_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY catalogos ALTER COLUMN id SET DEFAULT nextval('catalogos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categorias_taxonomicas ALTER COLUMN id SET DEFAULT nextval('categorias_taxonomicas_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies ALTER COLUMN id SET DEFAULT nextval('especies_id_seq'::regclass);


--
-- Name: id_nombre_ascendente; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies ALTER COLUMN id_nombre_ascendente SET DEFAULT nextval('especies_id_nombre_ascendente_seq'::regclass);


--
-- Name: id_ascend_obligatorio; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies ALTER COLUMN id_ascend_obligatorio SET DEFAULT nextval('especies_id_ascend_obligatorio_seq'::regclass);


--
-- Name: categoria_taxonomica_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies ALTER COLUMN categoria_taxonomica_id SET DEFAULT nextval('especies_categoria_taxonomica_id_seq'::regclass);


--
-- Name: especie_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_bibliografias ALTER COLUMN especie_id SET DEFAULT nextval('especies_bibliografias_especie_id_seq'::regclass);


--
-- Name: bibliografia_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_bibliografias ALTER COLUMN bibliografia_id SET DEFAULT nextval('especies_bibliografias_bibliografia_id_seq'::regclass);


--
-- Name: especie_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_catalogos ALTER COLUMN especie_id SET DEFAULT nextval('especies_catalogos_especie_id_seq'::regclass);


--
-- Name: catalogo_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_catalogos ALTER COLUMN catalogo_id SET DEFAULT nextval('especies_catalogos_catalogo_id_seq'::regclass);


--
-- Name: especie_id1; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_estatuses ALTER COLUMN especie_id1 SET DEFAULT nextval('especies_estatuses_especie_id1_seq'::regclass);


--
-- Name: especie_id2; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_estatuses ALTER COLUMN especie_id2 SET DEFAULT nextval('especies_estatuses_especie_id2_seq'::regclass);


--
-- Name: estatus_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_estatuses ALTER COLUMN estatus_id SET DEFAULT nextval('especies_estatuses_estatus_id_seq'::regclass);


--
-- Name: especie_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_estatuses_bibliografias ALTER COLUMN especie_id SET DEFAULT nextval('especies_estatuses_bibliografias_especie_id_seq'::regclass);


--
-- Name: estatus_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_estatuses_bibliografias ALTER COLUMN estatus_id SET DEFAULT nextval('especies_estatuses_bibliografias_estatus_id_seq'::regclass);


--
-- Name: bibliografia_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_estatuses_bibliografias ALTER COLUMN bibliografia_id SET DEFAULT nextval('especies_estatuses_bibliografias_bibliografia_id_seq'::regclass);


--
-- Name: especie_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_regiones ALTER COLUMN especie_id SET DEFAULT nextval('especies_regiones_especie_id_seq'::regclass);


--
-- Name: region_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_regiones ALTER COLUMN region_id SET DEFAULT nextval('especies_regiones_region_id_seq'::regclass);


--
-- Name: tipo_distribucion_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_regiones ALTER COLUMN tipo_distribucion_id SET DEFAULT nextval('especies_regiones_tipo_distribucion_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY estatuses ALTER COLUMN id SET DEFAULT nextval('estatuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY listas ALTER COLUMN id SET DEFAULT nextval('listas_id_seq'::regclass);


--
-- Name: usuario_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY listas ALTER COLUMN usuario_id SET DEFAULT nextval('listas_usuario_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nombres_comunes ALTER COLUMN id SET DEFAULT nextval('nombres_comunes_id_seq'::regclass);


--
-- Name: especie_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nombres_regiones ALTER COLUMN especie_id SET DEFAULT nextval('nombres_regiones_especie_id_seq'::regclass);


--
-- Name: region_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nombres_regiones ALTER COLUMN region_id SET DEFAULT nextval('nombres_regiones_region_id_seq'::regclass);


--
-- Name: nombre_comun_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nombres_regiones ALTER COLUMN nombre_comun_id SET DEFAULT nextval('nombres_regiones_nombre_comun_id_seq'::regclass);


--
-- Name: especie_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nombres_regiones_bibliografias ALTER COLUMN especie_id SET DEFAULT nextval('nombres_regiones_bibliografias_especie_id_seq'::regclass);


--
-- Name: region_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nombres_regiones_bibliografias ALTER COLUMN region_id SET DEFAULT nextval('nombres_regiones_bibliografias_region_id_seq'::regclass);


--
-- Name: nombre_comun_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nombres_regiones_bibliografias ALTER COLUMN nombre_comun_id SET DEFAULT nextval('nombres_regiones_bibliografias_nombre_comun_id_seq'::regclass);


--
-- Name: bibliografia_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nombres_regiones_bibliografias ALTER COLUMN bibliografia_id SET DEFAULT nextval('nombres_regiones_bibliografias_bibliografia_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY regiones ALTER COLUMN id SET DEFAULT nextval('regiones_id_seq'::regclass);


--
-- Name: tipo_region_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY regiones ALTER COLUMN tipo_region_id SET DEFAULT nextval('regiones_tipo_region_id_seq'::regclass);


--
-- Name: id_region_asc; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY regiones ALTER COLUMN id_region_asc SET DEFAULT nextval('regiones_id_region_asc_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessiones ALTER COLUMN id SET DEFAULT nextval('sessiones_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tipos_distribuciones ALTER COLUMN id SET DEFAULT nextval('tipos_distribuciones_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tipos_regiones ALTER COLUMN id SET DEFAULT nextval('tipos_regiones_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY usuarios ALTER COLUMN id SET DEFAULT nextval('usuarios_id_seq'::regclass);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: id_bibliografias; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bibliografias
    ADD CONSTRAINT id_bibliografias PRIMARY KEY (id);


--
-- Name: id_bitacoras; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bitacoras
    ADD CONSTRAINT id_bitacoras PRIMARY KEY (id);


--
-- Name: id_catalogos; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY catalogos
    ADD CONSTRAINT id_catalogos PRIMARY KEY (id);


--
-- Name: id_categorias_taxonomicas; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categorias_taxonomicas
    ADD CONSTRAINT id_categorias_taxonomicas PRIMARY KEY (id);


--
-- Name: id_especies; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY especies
    ADD CONSTRAINT id_especies PRIMARY KEY (id);


--
-- Name: id_especies_bibliografias; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY especies_bibliografias
    ADD CONSTRAINT id_especies_bibliografias PRIMARY KEY (especie_id, bibliografia_id);


--
-- Name: id_especies_catalogos; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY especies_catalogos
    ADD CONSTRAINT id_especies_catalogos PRIMARY KEY (especie_id, catalogo_id);


--
-- Name: id_especies_estatuses; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY especies_estatuses
    ADD CONSTRAINT id_especies_estatuses PRIMARY KEY (especie_id1, especie_id2, estatus_id);


--
-- Name: id_especies_estatuses_bibliografias; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY especies_estatuses_bibliografias
    ADD CONSTRAINT id_especies_estatuses_bibliografias PRIMARY KEY (especie_id, estatus_id, bibliografia_id);


--
-- Name: id_especies_regiones; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY especies_regiones
    ADD CONSTRAINT id_especies_regiones PRIMARY KEY (especie_id, region_id);


--
-- Name: id_estatuses; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY estatuses
    ADD CONSTRAINT id_estatuses PRIMARY KEY (id);


--
-- Name: id_listas; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY listas
    ADD CONSTRAINT id_listas PRIMARY KEY (id);


--
-- Name: id_nombres_comunes; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nombres_comunes
    ADD CONSTRAINT id_nombres_comunes PRIMARY KEY (id);


--
-- Name: id_nombres_regiones; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nombres_regiones
    ADD CONSTRAINT id_nombres_regiones PRIMARY KEY (especie_id, region_id, nombre_comun_id);


--
-- Name: id_nombres_regiones_bibliografias; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nombres_regiones_bibliografias
    ADD CONSTRAINT id_nombres_regiones_bibliografias PRIMARY KEY (especie_id, region_id, nombre_comun_id, bibliografia_id);


--
-- Name: id_regiones; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY regiones
    ADD CONSTRAINT id_regiones PRIMARY KEY (id);


--
-- Name: id_roles; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT id_roles PRIMARY KEY (id);


--
-- Name: id_tipos_distribuciones; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tipos_distribuciones
    ADD CONSTRAINT id_tipos_distribuciones PRIMARY KEY (id);


--
-- Name: id_tipos_regiones; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tipos_regiones
    ADD CONSTRAINT id_tipos_regiones PRIMARY KEY (id);


--
-- Name: id_usuarios; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY usuarios
    ADD CONSTRAINT id_usuarios PRIMARY KEY (id);


--
-- Name: sessiones_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sessiones
    ADD CONSTRAINT sessiones_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: index_especies_on_ancestry_acendente_directo; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_especies_on_ancestry_acendente_directo ON especies USING btree (ancestry_acendente_directo);


--
-- Name: index_especies_on_ancestry_acendente_obligatorio; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_especies_on_ancestry_acendente_obligatorio ON especies USING btree (ancestry_acendente_obligatorio);


--
-- Name: index_especies_on_nombre_cientifico; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_especies_on_nombre_cientifico ON especies USING btree (nombre_cientifico);


--
-- Name: index_on_nombre_comun; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_on_nombre_comun ON nombres_comunes USING btree (nombre_comun);


--
-- Name: index_regiones_on_ancestry; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_regiones_on_ancestry ON regiones USING btree (ancestry);


--
-- Name: index_sessiones_on_session_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_sessiones_on_session_id ON sessiones USING btree (session_id);


--
-- Name: index_sessiones_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessiones_on_updated_at ON sessiones USING btree (updated_at);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: bibliografia_relacionbibliografia_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_estatuses_bibliografias
    ADD CONSTRAINT bibliografia_relacionbibliografia_fk FOREIGN KEY (bibliografia_id) REFERENCES bibliografias(id);


--
-- Name: bibliografia_relnombrebiblio_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_bibliografias
    ADD CONSTRAINT bibliografia_relnombrebiblio_fk FOREIGN KEY (bibliografia_id) REFERENCES bibliografias(id);


--
-- Name: bibliografia_relnomnomcomunregionbiblio_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nombres_regiones_bibliografias
    ADD CONSTRAINT bibliografia_relnomnomcomunregionbiblio_fk FOREIGN KEY (bibliografia_id) REFERENCES bibliografias(id);


--
-- Name: catalogonombre_relnombrecatalogo_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_catalogos
    ADD CONSTRAINT catalogonombre_relnombrecatalogo_fk FOREIGN KEY (catalogo_id) REFERENCES catalogos(id);


--
-- Name: categoriataxonomica_nombre_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies
    ADD CONSTRAINT categoriataxonomica_nombre_fk FOREIGN KEY (categoria_taxonomica_id) REFERENCES categorias_taxonomicas(id);


--
-- Name: nombre_nombre_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies
    ADD CONSTRAINT nombre_nombre_fk FOREIGN KEY (id_nombre_ascendente) REFERENCES especies(id);


--
-- Name: nombre_nombre_fk1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies
    ADD CONSTRAINT nombre_nombre_fk1 FOREIGN KEY (id_ascend_obligatorio) REFERENCES especies(id);


--
-- Name: nombre_nombrerelacion1_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_estatuses
    ADD CONSTRAINT nombre_nombrerelacion1_fk FOREIGN KEY (especie_id1) REFERENCES especies(id);


--
-- Name: nombre_nombrerelacion2_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_estatuses
    ADD CONSTRAINT nombre_nombrerelacion2_fk FOREIGN KEY (especie_id2) REFERENCES especies(id);


--
-- Name: nombre_relnombrebiblio_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_bibliografias
    ADD CONSTRAINT nombre_relnombrebiblio_fk FOREIGN KEY (especie_id) REFERENCES especies(id);


--
-- Name: nombre_relnombrecatalogo_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_catalogos
    ADD CONSTRAINT nombre_relnombrecatalogo_fk FOREIGN KEY (especie_id) REFERENCES especies(id);


--
-- Name: nombre_relnombreregion_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_regiones
    ADD CONSTRAINT nombre_relnombreregion_fk FOREIGN KEY (especie_id) REFERENCES especies(id);


--
-- Name: nomcomun_relnomnomcomunregion_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nombres_regiones
    ADD CONSTRAINT nomcomun_relnomnomcomunregion_fk FOREIGN KEY (nombre_comun_id) REFERENCES nombres_comunes(id);


--
-- Name: region_region_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY regiones
    ADD CONSTRAINT region_region_fk FOREIGN KEY (id_region_asc) REFERENCES regiones(id);


--
-- Name: region_relnombreregion_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_regiones
    ADD CONSTRAINT region_relnombreregion_fk FOREIGN KEY (region_id) REFERENCES regiones(id);


--
-- Name: relnombreregion_relnomnomcomunregion_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nombres_regiones
    ADD CONSTRAINT relnombreregion_relnomnomcomunregion_fk FOREIGN KEY (especie_id, region_id) REFERENCES especies_regiones(especie_id, region_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: relnomnomcomunregion_relnomnomcomunregionbiblio_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nombres_regiones_bibliografias
    ADD CONSTRAINT relnomnomcomunregion_relnomnomcomunregionbiblio_fk FOREIGN KEY (nombre_comun_id, especie_id, region_id) REFERENCES nombres_regiones(nombre_comun_id, especie_id, region_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: roles_usuarios_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY usuarios
    ADD CONSTRAINT roles_usuarios_fk FOREIGN KEY (rol_id) REFERENCES roles(id);


--
-- Name: tipodistribucion_relnombreregion_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_regiones
    ADD CONSTRAINT tipodistribucion_relnombreregion_fk FOREIGN KEY (tipo_distribucion_id) REFERENCES tipos_distribuciones(id);


--
-- Name: tiporegion_region_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY regiones
    ADD CONSTRAINT tiporegion_region_fk FOREIGN KEY (tipo_region_id) REFERENCES tipos_regiones(id);


--
-- Name: tiporelacion_nombrerelacion_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY especies_estatuses
    ADD CONSTRAINT tiporelacion_nombrerelacion_fk FOREIGN KEY (estatus_id) REFERENCES estatuses(id);


--
-- Name: usuarios_bitacoras_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bitacoras
    ADD CONSTRAINT usuarios_bitacoras_fk FOREIGN KEY (usuario_id) REFERENCES usuarios(id);


--
-- Name: usuarios_listas_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listas
    ADD CONSTRAINT usuarios_listas_fk FOREIGN KEY (usuario_id) REFERENCES usuarios(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20130730181035');

INSERT INTO schema_migrations (version) VALUES ('20130730181247');

INSERT INTO schema_migrations (version) VALUES ('20130730181959');

INSERT INTO schema_migrations (version) VALUES ('20130731015842');

INSERT INTO schema_migrations (version) VALUES ('20130731020042');

INSERT INTO schema_migrations (version) VALUES ('20131018142400');

INSERT INTO schema_migrations (version) VALUES ('20131021221425');

INSERT INTO schema_migrations (version) VALUES ('20131021222103');

INSERT INTO schema_migrations (version) VALUES ('20131028180853');

INSERT INTO schema_migrations (version) VALUES ('20140224155302');

INSERT INTO schema_migrations (version) VALUES ('20140224222120');

INSERT INTO schema_migrations (version) VALUES ('20140228164310');

INSERT INTO schema_migrations (version) VALUES ('20140228165610');
