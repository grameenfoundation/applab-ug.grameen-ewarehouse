package com.himmit.apexapi

import com.himmit.apexapi.authentication._
import com.himmit.apexapi.base.ApexApiRequest
import com.himmit.apexapi.response._
import com.himmit.apexapi.base.JsonConfigurator._
import spray.json._
import DefaultJsonProtocol._
import com.himmit.apexapi.parameter._
import org.slf4j.LoggerFactory

/**
 * User: Oskar
 * Date: 03/05/13
 * Time: 20:42
 */
class LoanService (val apiSession: ApiSession) {

    val logger = LoggerFactory.getLogger(classOf[LoanService])

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

    def updateLoan(updateLoan: UpdateLoan) : Option[LoanResponse] = {

        val parameters = Map[String, String](
            "Id" -> updateLoan.Id,
            "Status" -> updateLoan.Status
        )

        val jsonResult = request.patch(loanRequest, parameters)
        val myObject = jsonResult.get.convertTo[LoanResponse]

        return Some(myObject)

    }

    def getLoans(status: String) : LoansResponse =  {

        val parameters = Map[String, String](
            "Status" -> status
        )

        val jsonResult = request.get(loansRequest, parameters)
        val myObject = jsonResult.get.convertTo[LoansResponse]

        return myObject
    }

    def updateLoans(updateLoans: Array[UpdateLoan]) : LoansResponse =  {

        val json = updateLoans.toJson
        logger.info(json.toString)

        val jsonResult = request.patch(loansRequest, json.toString)
        val myObject = jsonResult.get.convertTo[LoansResponse]

        return myObject
    }
}
