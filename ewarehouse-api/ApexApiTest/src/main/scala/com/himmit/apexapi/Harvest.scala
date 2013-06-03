package com.himmit.apexapi

/**
 * User: Oskar
 * Date: 30/05/13
 * Time: 14:59
 */
case class Harvest(Id: String, Crop: String, DateHarvested: String, QuantityAccepted: Float,
                   QuantityHarvested: Float, QuantityRejected: Float, StorageLocation: String)

