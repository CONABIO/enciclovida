-- MySQL dump 10.16  Distrib 10.1.26-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: metamares
-- ------------------------------------------------------
-- Server version	10.1.26-MariaDB-0+deb9u1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `datos`
--

DROP TABLE IF EXISTS `datos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `datos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descarga_datos` text,
  `licencia_uso` text,
  `descripcion_base` text,
  `metadatos` text,
  `publicaciones` text,
  `publicacion_url` varchar(1000) DEFAULT NULL,
  `descarga_informe` varchar(1000) DEFAULT NULL,
  `forma_citar` text,
  `notas_adicionales` text,
  `restricciones` text,
  `numero_ejemplares` int(11) DEFAULT NULL,
  `tipo_unidad` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `datos`
--

LOCK TABLES `datos` WRITE;
/*!40000 ALTER TABLE `datos` DISABLE KEYS */;
/*!40000 ALTER TABLE `datos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `directorio`
--

DROP TABLE IF EXISTS `directorio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `directorio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombres` varchar(255) DEFAULT NULL,
  `apellido_paterno` varchar(255) DEFAULT NULL,
  `apellido_materno` varchar(255) DEFAULT NULL,
  `cargo` varchar(255) DEFAULT NULL,
  `grado_academico` varchar(255) DEFAULT NULL,
  `tema_estudio` varchar(255) DEFAULT NULL,
  `linea_investigacion` varchar(500) DEFAULT NULL,
  `region_estudio` varchar(255) DEFAULT NULL,
  `correo` varchar(255) DEFAULT NULL,
  `telefono` varchar(255) DEFAULT NULL,
  `institucion_id` int(11) DEFAULT NULL,
  `usuario_id` int(11) DEFAULT NULL COMMENT 'ID de la tabla usuarios, de la base enciclovida',
  PRIMARY KEY (`id`),
  KEY `fk_directorio_instituciones1_idx` (`institucion_id`),
  CONSTRAINT `fk_directorio_instituciones1` FOREIGN KEY (`institucion_id`) REFERENCES `instituciones` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `directorio`
--

LOCK TABLES `directorio` WRITE;
/*!40000 ALTER TABLE `directorio` DISABLE KEYS */;
/*!40000 ALTER TABLE `directorio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `especies_estudiadas`
--

DROP TABLE IF EXISTS `especies_estudiadas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `especies_estudiadas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `especie_id` int(11) DEFAULT NULL COMMENT 'ID de la tabla Nombre en catalogocentralizado',
  `nombre_cientifico` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `especies_estudiadas`
--

LOCK TABLES `especies_estudiadas` WRITE;
/*!40000 ALTER TABLE `especies_estudiadas` DISABLE KEYS */;
/*!40000 ALTER TABLE `especies_estudiadas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `info_adicional`
--

DROP TABLE IF EXISTS `info_adicional`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `info_adicional` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `informacion_objeto` text,
  `informacion_posterior` text,
  `informacion_adicional` text,
  `colaboradores` text,
  `instituciones_involucradas` text,
  `equipo` text,
  `comentarios` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `info_adicional`
--

LOCK TABLES `info_adicional` WRITE;
/*!40000 ALTER TABLE `info_adicional` DISABLE KEYS */;
/*!40000 ALTER TABLE `info_adicional` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `instituciones`
--

DROP TABLE IF EXISTS `instituciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instituciones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_institucion` varchar(255) NOT NULL,
  `sitio_web` varchar(255) DEFAULT NULL,
  `contacto` varchar(255) DEFAULT NULL,
  `correo_contacto` varchar(255) DEFAULT NULL,
  `ubicacion_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_instituciones_ubicacones1_idx` (`ubicacion_id`),
  CONSTRAINT `fk_instituciones_ubicacones1` FOREIGN KEY (`ubicacion_id`) REFERENCES `ubicaciones` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `instituciones`
--

LOCK TABLES `instituciones` WRITE;
/*!40000 ALTER TABLE `instituciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `instituciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keywords`
--

DROP TABLE IF EXISTS `keywords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_keyword` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `keywords`
--

LOCK TABLES `keywords` WRITE;
/*!40000 ALTER TABLE `keywords` DISABLE KEYS */;
/*!40000 ALTER TABLE `keywords` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `periodos`
--

DROP TABLE IF EXISTS `periodos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `periodos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `peridiocidad` varchar(255) DEFAULT NULL,
  `periodo_monitoreo_desde` date DEFAULT NULL,
  `periodo_monitoreo_hasta` varchar(45) DEFAULT NULL,
  `periodo_sistematico_desde` date DEFAULT NULL,
  `periodo_sistematico_hasta` varchar(45) DEFAULT NULL,
  `monitoreo_desde` date DEFAULT NULL,
  `monitoreo_hasta` varchar(45) DEFAULT NULL,
  `cometarios` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `periodos`
--

LOCK TABLES `periodos` WRITE;
/*!40000 ALTER TABLE `periodos` DISABLE KEYS */;
/*!40000 ALTER TABLE `periodos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proyectos`
--

DROP TABLE IF EXISTS `proyectos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proyectos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_proyecto` varchar(255) NOT NULL DEFAULT 'Sin nombre',
  `financiamiento` text,
  `tipo_monitoreo` varchar(255) DEFAULT NULL,
  `objeto_monitoreo` text,
  `campo_investigacion` varchar(255) DEFAULT NULL,
  `campo_ciencia` varchar(255) DEFAULT NULL,
  `finalidad` text,
  `metodo` text,
  `info_adicional_id` int(11) DEFAULT NULL,
  `periodo_id` int(11) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `institucion_id` int(11) DEFAULT NULL,
  `datos_id` int(11) DEFAULT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_proyectos_info_adicional_idx` (`info_adicional_id`),
  KEY `fk_proyectos_periodo1_idx` (`periodo_id`),
  KEY `fk_proyectos_ubicaciones1_idx` (`region_id`),
  KEY `fk_proyectos_instituciones1_idx` (`institucion_id`),
  KEY `fk_proyectos_datos1_idx` (`datos_id`),
  CONSTRAINT `fk_proyectos_datos1` FOREIGN KEY (`datos_id`) REFERENCES `datos` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_proyectos_info_adicional` FOREIGN KEY (`info_adicional_id`) REFERENCES `info_adicional` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_proyectos_instituciones1` FOREIGN KEY (`institucion_id`) REFERENCES `instituciones` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_proyectos_periodo1` FOREIGN KEY (`periodo_id`) REFERENCES `periodos` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_proyectos_ubicaciones1` FOREIGN KEY (`region_id`) REFERENCES `regiones` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Pestaña de proyectos';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proyectos`
--

LOCK TABLES `proyectos` WRITE;
/*!40000 ALTER TABLE `proyectos` DISABLE KEYS */;
/*!40000 ALTER TABLE `proyectos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proyectos_especies`
--

DROP TABLE IF EXISTS `proyectos_especies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proyectos_especies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `proyecto_id` int(11) NOT NULL,
  `especie_estudiada_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_proyectos_especies_proyectos1_idx` (`proyecto_id`),
  KEY `fk_proyectos_especies_especies_estudiadas1_idx` (`especie_estudiada_id`),
  CONSTRAINT `fk_proyectos_especies_especies_estudiadas1` FOREIGN KEY (`especie_estudiada_id`) REFERENCES `especies_estudiadas` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_proyectos_especies_proyectos1` FOREIGN KEY (`proyecto_id`) REFERENCES `proyectos` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proyectos_especies`
--

LOCK TABLES `proyectos_especies` WRITE;
/*!40000 ALTER TABLE `proyectos_especies` DISABLE KEYS */;
/*!40000 ALTER TABLE `proyectos_especies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proyectos_keywords`
--

DROP TABLE IF EXISTS `proyectos_keywords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proyectos_keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `proyectos_id` int(11) NOT NULL,
  `keywords_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_proyectos_keywords_proyectos1_idx` (`proyectos_id`),
  KEY `fk_proyectos_keywords_keywords1_idx` (`keywords_id`),
  CONSTRAINT `fk_proyectos_keywords_keywords1` FOREIGN KEY (`keywords_id`) REFERENCES `keywords` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_proyectos_keywords_proyectos1` FOREIGN KEY (`proyectos_id`) REFERENCES `proyectos` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proyectos_keywords`
--

LOCK TABLES `proyectos_keywords` WRITE;
/*!40000 ALTER TABLE `proyectos_keywords` DISABLE KEYS */;
/*!40000 ALTER TABLE `proyectos_keywords` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `regiones`
--

DROP TABLE IF EXISTS `regiones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `regiones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_sitio` varchar(255) NOT NULL,
  `latitud` varchar(45) DEFAULT NULL,
  `longitud` varchar(45) DEFAULT NULL,
  `poligono` varchar(500) DEFAULT NULL,
  `zona` varchar(255) DEFAULT NULL,
  `entidad` varchar(255) DEFAULT NULL,
  `cuenca` varchar(255) DEFAULT NULL,
  `anp` varchar(255) DEFAULT NULL,
  `comentarios` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `regiones`
--

LOCK TABLES `regiones` WRITE;
/*!40000 ALTER TABLE `regiones` DISABLE KEYS */;
/*!40000 ALTER TABLE `regiones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ubicaciones`
--

DROP TABLE IF EXISTS `ubicaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ubicaciones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `calle_numero` varchar(500) DEFAULT NULL,
  `colonia` varchar(255) DEFAULT NULL,
  `municipio` varchar(255) DEFAULT NULL,
  `ciudad` varchar(255) DEFAULT NULL,
  `entidad_federativa` varchar(255) DEFAULT NULL,
  `cp` smallint(4) unsigned zerofill DEFAULT NULL,
  `pais` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ubicaciones`
--

LOCK TABLES `ubicaciones` WRITE;
/*!40000 ALTER TABLE `ubicaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `ubicaciones` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-09-02 23:20:50
