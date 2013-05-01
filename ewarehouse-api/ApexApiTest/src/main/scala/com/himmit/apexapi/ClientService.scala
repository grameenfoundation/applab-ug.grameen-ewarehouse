package com.himmit.apexapi

import org.slf4j.LoggerFactory
import com.himmit.apexapi.authentication._
import spray.json._
import com.himmit.apexapi._
import com.himmit.apexapi.response.ClientResponse
import com.himmit.apexapi.parameter.UpdateClient
import com.himmit.apexapi.base.ApexApiRequest
import com.himmit.apexapi.base.JsonConfigurator._


/**
 * User: Oskar
 * Date: 21/04/13
 * Time: 10:00
 */
class ClientService (val apiSession: ApiSession) {

    val clientRequest = "client"

    def getClient(id: String) : Option[ClientResponse] =  {
        val parameters = Map[String, String](
            "id" -> id
        )
        val jsonResult = new ApexApiRequest(Authenticator.getSession.get).get(clientRequest, parameters)
        val myObject = jsonResult.get.convertTo[ClientResponse]

        return Some(myObject)

    }

    def updateClient(updateClient: UpdateClient) : Option[ClientResponse] = {

        val parameters = Map[String, String](
            "id" -> updateClient.id,
            "status" -> updateClient.status
        )

        val jsonResult = new ApexApiRequest(Authenticator.getSession.get).patch(clientRequest, parameters)
        val myObject = jsonResult.get.convertTo[ClientResponse]

        return Some(myObject)

    }

}