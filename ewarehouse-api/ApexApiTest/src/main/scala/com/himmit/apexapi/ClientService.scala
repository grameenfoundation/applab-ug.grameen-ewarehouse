package com.himmit.apexapi

import org.slf4j.LoggerFactory
import com.himmit.apexapi.authentication._
import spray.json._
import DefaultJsonProtocol._
import com.himmit.apexapi._
import com.himmit.apexapi.response._
import com.himmit.apexapi.parameter.{UpdateClientSaleStatus, UpdateClient}
import com.himmit.apexapi.base.ApexApiRequest
import com.himmit.apexapi.base.JsonConfigurator._
import scala.util.parsing.json.JSONObject


/**
 * User: Oskar
 * Date: 21/04/13
 * Time: 10:00
 */
class ClientService (val apiSession: ApiSession) {
    val logger = LoggerFactory.getLogger(classOf[ClientService])

    val request = new ApexApiRequest(Authenticator.getSession.get)

    val clientRequest = "client"
    val clientsRequest = "clients"
    val clientSaleStatusRequest = "clientsalestatus"
    val groupRequest = "group"

    def getClient(id: String) : Option[ClientResponse] =  {
        val parameters = Map[String, String](
            "Id" -> id
        )
        val jsonResult = request.get(clientRequest, parameters)
        val myObject = jsonResult.get.convertTo[ClientResponse]

        return Some(myObject)

    }

    def updateClient(updateClient: UpdateClient) : Option[ClientResponse] = {

        val parameters = Map[String, String](
            "Id" -> updateClient.Id,
            "Status" -> updateClient.Status
        )

        val jsonResult = request.post(clientRequest, parameters)
        val myObject = jsonResult.get.convertTo[ClientResponse]

        return Some(myObject)

    }

    def getClients(status: String) : ClientsResponse =  {

        val parameters = Map[String, String](
            "Status" -> status
        )

        val jsonResult = request.get(clientsRequest, parameters)
        val myObject = jsonResult.get.convertTo[ClientsResponse]

        return myObject
    }

    def updateClients(updateClients: Array[UpdateClient]) : ClientsResponse =  {

        val json = updateClients.toJson

        val jsonResult = request.post(clientsRequest, json.toString)
        val myObject = jsonResult.get.convertTo[ClientsResponse]

        return myObject
    }

    def updateClientSaleStatus(status: UpdateClientSaleStatus) : ClientResponse =  {
        val parameters = Map[String, String](
            "Id" -> status.Id,
            "SaleStatus" -> status.SaleStatus
        )

        val jsonResult = request.post(clientSaleStatusRequest, parameters)
        val myObject = jsonResult.get.convertTo[ClientResponse]

        return myObject
    }

    def insertGroup(name: String, groupID: String){
        val parameters = Map[String, String](
            "Name" -> name,
            "GroupID" -> groupID
        )
        val jsonResult = request.post(groupRequest, parameters)
        logger.info(jsonResult.get.toString());
        //val myObject = jsonResult.get.convertTo[String]

    }

}