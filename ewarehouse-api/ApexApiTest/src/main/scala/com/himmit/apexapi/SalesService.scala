package com.himmit.apexapi

import org.slf4j.LoggerFactory
import com.himmit.apexapi.authentication._
import spray.json._
import DefaultJsonProtocol._
import com.himmit.apexapi._
import com.himmit.apexapi.response._
import com.himmit.apexapi.parameter.{UpdateSale, UpdateClient}
import com.himmit.apexapi.base.ApexApiRequest
import com.himmit.apexapi.base.JsonConfigurator._
import scala.util.parsing.json.JSONObject

/**
 * User: Oskar
 * Date: 23/05/13
 * Time: 22:20
 */
class SalesService {
    val request = new ApexApiRequest(Authenticator.getSession.get)

    val salesRequest = "sales"

    def getSales(status: String) : SalesResponse =  {

        val parameters = Map[String, String](
            "Status" -> status
        )

        val jsonResult = request.get(salesRequest, parameters)
        val myObject = jsonResult.get.convertTo[SalesResponse]

        return myObject
    }

    def updateClients(updateSales: Array[UpdateSale]) : SalesResponse =  {

        val json = updateSales.toJson

        val jsonResult = request.post(salesRequest, json.toString)
        val myObject = jsonResult.get.convertTo[SalesResponse]

        return myObject
    }
}

