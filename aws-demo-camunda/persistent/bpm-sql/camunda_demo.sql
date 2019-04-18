create schema if not exists camunda_demo;
use camunda_demo;

-- MySQL dump 10.14  Distrib 5.5.60-MariaDB, for Linux (x86_64)
--
-- Host: eleksplatformdb.cilc2rgy1cbx.us-west-2.rds.amazonaws.com    Database: camunda_demo
-- ------------------------------------------------------
-- Server version	5.6.40-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `payment_type` varchar(200) DEFAULT NULL,
  `trip_id` varchar(100) DEFAULT NULL,
  `payment` double(20,2) DEFAULT NULL,
  `employee_id` varchar(200) DEFAULT NULL,
  `payment_datetime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,'Tickets','trip-3c68cfe2d96246f6',123.00,'employee','2019-04-15 11:39:38'),(2,'Tickets','trip-be93869474b84771',322.00,'employee','2019-04-15 11:47:23'),(3,'Accomodation','trip-be93869474b84771',232.00,'employee','2019-04-15 11:47:23'),(4,'Spends','trip-be93869474b84771',541.00,'employee','2019-04-15 11:47:23'),(5,'Tickets','trip-4d08e0fd537f490f',234.00,'employee','2019-04-15 12:49:52'),(6,'Accomodation','trip-4d08e0fd537f490f',345.00,'employee','2019-04-15 12:49:52'),(7,'Spends','trip-4d08e0fd537f490f',44.00,'employee','2019-04-15 12:49:52'),(8,'Tickets','trip-7aae333835e64722',1000.00,'employee','2019-04-15 13:07:31'),(9,'Accomodation','trip-7aae333835e64722',2000.00,'employee','2019-04-15 13:07:31'),(10,'Spends','trip-7aae333835e64722',2000.00,'employee','2019-04-15 13:07:32');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trip_approve`
--

DROP TABLE IF EXISTS `trip_approve`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trip_approve` (
  `trip_id` varchar(100) NOT NULL,
  `trip_status` varchar(100) DEFAULT NULL,
  `employee_id` varchar(200) DEFAULT NULL,
  `closure_datetime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`trip_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trip_approve`
--

LOCK TABLES `trip_approve` WRITE;
/*!40000 ALTER TABLE `trip_approve` DISABLE KEYS */;
INSERT INTO `trip_approve` VALUES ('trip-4d08e0fd537f490f','Approved','employee','2019-04-15 12:49:53'),('trip-75787ebc9bd2446b','Toooo expensive','employee','2019-04-15 11:25:15'),('trip-7aae333835e64722','Approved','employee','2019-04-15 13:07:33'),('trip-be93869474b84771','Approved','employee','2019-04-15 11:47:24');
/*!40000 ALTER TABLE `trip_approve` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trip_report_information`
--

DROP TABLE IF EXISTS `trip_report_information`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trip_report_information` (
  `trip_id` varchar(100) NOT NULL,
  `trip_address` varchar(200) DEFAULT NULL,
  `trip_purpose` varchar(200) DEFAULT NULL,
  `employee_id` varchar(200) DEFAULT NULL,
  `generation_datetime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`trip_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trip_report_information`
--

LOCK TABLES `trip_report_information` WRITE;
/*!40000 ALTER TABLE `trip_report_information` DISABLE KEYS */;
INSERT INTO `trip_report_information` VALUES ('trip-3c68cfe2d96246f6','Alaska, USA','Plan Z','employee','2019-04-15 11:29:42'),('trip-4d08e0fd537f490f','Alaska, USA','Plan A','employee','2019-04-15 12:37:15'),('trip-75787ebc9bd2446b','California, USA','Project ZERO','employee','2019-04-15 11:16:48'),('trip-7aae333835e64722','Santa Clara, CA, USA','Conference','employee','2019-04-15 12:55:22'),('trip-be93869474b84771','Paris, France','Plan B','employee','2019-04-15 11:44:00');
/*!40000 ALTER TABLE `trip_report_information` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-04-15 16:02:25
