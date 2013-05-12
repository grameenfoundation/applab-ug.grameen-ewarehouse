package com.himmit.apexapi.parameter

import java.util.Date

/**
 * User: Oskar
 * Date: 10/05/13
 * Time: 11:13
 */
case class AddRepayment (Id: Option[String], LoanId: String, SaleId: String, Amount: Float, Remarks: String, PaymentDate: String)