-- MySQL dump 10.13  Distrib 5.5.37, for debian-linux-gnu (i686)
--
-- Host: localhost    Database: myapp_development
-- ------------------------------------------------------
-- Server version	5.5.37-0ubuntu0.12.04.1

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
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `native_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `balance_nqt` decimal(20,0) DEFAULT '0',
  `pos_balance_nqt` decimal(20,0) DEFAULT '0',
  `public_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `passphrase` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_accounts_on_native_id` (`native_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blocks`
--

DROP TABLE IF EXISTS `blocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blocks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `native_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `generator` int(10) DEFAULT NULL,
  `timestamp` int(10) DEFAULT '0',
  `height` int(10) DEFAULT NULL,
  `payload_length` int(10) DEFAULT '0',
  `payload_hash` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `generation_signature` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `block_signature` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `base_target` decimal(20,0) DEFAULT '0',
  `cumulative_difficulty` decimal(20,0) DEFAULT '0',
  `total_amount_nqt` decimal(20,0) DEFAULT '0',
  `total_fee_nqt` decimal(20,0) DEFAULT '0',
  `total_pos_nqt` decimal(20,0) DEFAULT '0',
  `version` int(10) DEFAULT NULL,
  `previous_block` int(10) DEFAULT NULL,
  `next_block` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_blocks_on_native_id` (`native_id`),
  KEY `index_blocks_on_generator` (`generator`),
  KEY `index_blocks_on_height` (`height`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pending_transactions`
--

DROP TABLE IF EXISTS `pending_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pending_transactions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `sender` int(10) DEFAULT NULL,
  `recipient` int(10) DEFAULT NULL,
  `amount_nqt` decimal(20,0) DEFAULT '0',
  `fee_nqt` decimal(20,0) DEFAULT '0',
  `native_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `error_msg` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `error_code` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_pending_transactions_on_native_id` (`native_id`),
  KEY `index_pending_transactions_on_sender` (`sender`),
  KEY `index_pending_transactions_on_recipient` (`recipient`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transactions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `native_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `timestamp` int(10) DEFAULT '0',
  `block` int(10) DEFAULT NULL,
  `sender` int(10) DEFAULT NULL,
  `recipient` int(10) DEFAULT NULL,
  `amount_nqt` decimal(20,0) DEFAULT '0',
  `fee_nqt` decimal(20,0) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_transactions_on_native_id` (`native_id`),
  KEY `index_transactions_on_block` (`block`),
  KEY `index_transactions_on_sender` (`sender`),
  KEY `index_transactions_on_recipient` (`recipient`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `unconfirmed_transactions`
--

DROP TABLE IF EXISTS `unconfirmed_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unconfirmed_transactions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sender` int(10) DEFAULT NULL,
  `recipient` int(10) DEFAULT NULL,
  `amount_nqt` decimal(20,0) DEFAULT '0',
  `fee_nqt` decimal(20,0) DEFAULT '0',
  `native_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `timestamp` int(10) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_unconfirmed_transactions_on_native_id` (`native_id`),
  KEY `index_unconfirmed_transactions_on_sender` (`sender`),
  KEY `index_unconfirmed_transactions_on_recipient` (`recipient`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-05-20 14:42:11
INSERT INTO schema_migrations (version) VALUES ('20140503235909');

