package com.himmit.apexapi

import com.himmit.apexapi.authentication.{Authenticator, ApiSession}
import com.himmit.apexapi.base.ApexApiRequest
import com.himmit.apexapi.response.{LoanResponse, ClientResponse}
import com.himmit.apexapi.base.JsonConfigurator._
import spray.json._
import DefaultJsonProtocol._

/**
 * User: Oskar
 * Date: 03/05/13
 * Time: 20:42
 */
class LoanService (val apiSession: ApiSession) {

    val request = new ApexApiRequest(Authenticator.getSession.get)

    val loanRequest = "loan"
    val loansRequest = "loans"

    def getLoan(id: String) : Option[LoanResponse] = {
        val parameters = Map[String, String](
            "Id" -> id
        )
        val jsonResult = request.get(loanRequest, parameters)
        val myObject = jsonResult.get.convertTo[LoanResponse]

        return Some(myObject)

    }
}
