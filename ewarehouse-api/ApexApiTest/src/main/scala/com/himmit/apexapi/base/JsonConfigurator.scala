package com.himmit.apexapi.base

import spray.json.{JsonWriter, DefaultJsonProtocol}
import com.himmit.apexapi.response._
import com.himmit.apexapi._
import com.himmit.apexapi.parameter._

/**
 * User: Oskar
 * Date: 27/04/13
 * Time: 16:57
 */
object JsonConfigurator extends DefaultJsonProtocol {
    implicit val clientFormat = jsonFormat12(Client)
    implicit val loanFormat = jsonFormat5(Loan);
    implicit val updateClientFormat = jsonFormat(UpdateClient, "id", "status")
    implicit val clientResponseFormat = jsonFormat(ClientResponse, "code", "description", "client")
    implicit val clientsResponseFormat = jsonFormat(ClientsResponse, "code", "description", "clients")
}
