package com.himmit.apexapi.base

import spray.json._
import com.himmit.apexapi.response._
import com.himmit.apexapi._
import com.himmit.apexapi.parameter._
import com.himmit.apexapi.response.ClientsResponse
import com.himmit.apexapi.response.ClientResponse
import com.himmit.apexapi.Loan
import com.himmit.apexapi.Client
import com.himmit.apexapi.parameter.UpdateClient

/**
 * User: Oskar
 * Date: 27/04/13
 * Time: 16:57
 */
object JsonConfigurator extends DefaultJsonProtocol with CollectionFormats with spray.json.AdditionalFormats{
    implicit val clientFormat = jsonFormat12(Client)
    implicit val loanFormat = jsonFormat7(Loan);
    implicit val updateClientFormat = jsonFormat(UpdateClient, "Id", "Status")
    implicit val updateLoanFormat = jsonFormat(UpdateLoan, "Id", "Status")
    implicit val addRepaymentFormat = jsonFormat(AddRepayment, "Id", "LoanId", "SaleId", "Amount", "Remarks", "PaymentDate")

    implicit val updateClientArrayFormat = arrayFormat[UpdateClient]
    implicit val updateLoanArrayFormat = arrayFormat[UpdateLoan]
    implicit val addRepaymentsResponseArrayFormat = arrayFormat[AddRepayment]

    implicit val clientResponseFormat = jsonFormat(ClientResponse, "code", "description", "client")
    implicit val loanResponseFormat = jsonFormat(LoanResponse, "code", "description", "loan")
    implicit val clientsResponseFormat = jsonFormat(ClientsResponse, "code", "description", "clients")
    implicit val loansResponseFormat = jsonFormat(LoansResponse, "code", "description", "loans")

}
