package com.himmit.apexapi.response

import com.himmit.apexapi.{Loan}

/**
 * User: Oskar
 * Date: 03/05/13
 * Time: 20:43
 */
case class LoanResponse (code: String, description: String, loan: Option[Loan])
