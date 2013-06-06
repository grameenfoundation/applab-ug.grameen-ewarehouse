package com.himmit.apexapi.base

import spray.json._
import com.himmit.apexapi.response._
import com.himmit.apexapi._
import com.himmit.apexapi.parameter._
import com.himmit.apexapi.response._
import com.himmit.apexapi.response.ClientResponse

/**
 * User: Oskar
 * Date: 27/04/13
 * Time: 16:57
 */
object JsonConfigurator extends DefaultJsonProtocol with CollectionFormats with spray.json.AdditionalFormats{
    implicit val clientFormat = jsonFormat(Client, "Id", "FirstName", "LastName", "DateOfBirth", "MobileNumber",
        "IDNumber", "Gender", "Village", "District", "City", "Country", "SaleStatus", "PictureURL",
        "NextOfKin", "NextOfKinTelephone")
    implicit val harvestFormat = jsonFormat7(Harvest)
    implicit val loanFormat = jsonFormat8(Loan);
    implicit val repaymentFormat = jsonFormat6(Repayment);
    implicit val saleFarmerFormat = jsonFormat2(SaleFarmer);
    implicit val saleFormat = jsonFormat3(Sale);


    implicit val insertGroupFormat = jsonFormat2(InsertGroup)
    implicit val updateClientFormat = jsonFormat(UpdateClient, "Id", "Status")
    implicit val updateClientSaleStatus = jsonFormat(UpdateClientSaleStatus, "Id", "UpdateClientSaleStatus")
    implicit val updateSaleFormat = jsonFormat(UpdateSale, "Id", "Status")
    implicit val updateLoanFormat = jsonFormat(UpdateLoan, "Id", "Status", "Balance")
    implicit val addRepaymentFormat = jsonFormat(AddRepayment, "Id", "LoanId", "SaleId", "Amount", "Remarks", "PaymentDate")

    implicit val updateClientArrayFormat = arrayFormat[UpdateClient]
    implicit val updateLoanArrayFormat = arrayFormat[UpdateLoan]
    implicit val updateSaleArrayFormat = arrayFormat[UpdateSale]
    implicit val addRepaymentsResponseArrayFormat = arrayFormat[AddRepayment]

    implicit val clientResponseFormat = jsonFormat(ClientResponse, "code", "description", "client")
    implicit val loanResponseFormat = jsonFormat(LoanResponse, "code", "description", "loan")
    implicit val clientsResponseFormat = jsonFormat(ClientsResponse, "code", "description", "clients")
    implicit val loansResponseFormat = jsonFormat(LoansResponse, "code", "description", "loans")
    implicit val repaymentResponseFormat = jsonFormat(RepaymentResponse, "code", "description", "repayments")
    implicit val saleResponseFormat = jsonFormat(SalesResponse, "code", "description", "sales")

}
