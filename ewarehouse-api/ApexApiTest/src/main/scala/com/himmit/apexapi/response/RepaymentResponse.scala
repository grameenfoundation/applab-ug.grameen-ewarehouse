package com.himmit.apexapi.response

import com.himmit.apexapi.Repayment

/**
 * User: Oskar
 * Date: 16/05/13
 * Time: 12:09
 */
case class RepaymentResponse (code: String, description: String, repayments: Option[Array[Repayment]]){

}
