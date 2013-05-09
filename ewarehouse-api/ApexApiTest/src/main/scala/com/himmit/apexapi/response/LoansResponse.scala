package com.himmit.apexapi.response

import com.himmit.apexapi.Loan

/**
 * User: Oskar
 * Date: 07/05/13
 * Time: 11:00
 */
case class LoansResponse (code: String, description: String, loans: Option[Array[Loan]])
