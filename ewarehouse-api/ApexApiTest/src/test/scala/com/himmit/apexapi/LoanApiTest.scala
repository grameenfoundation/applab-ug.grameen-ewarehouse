package com.himmit.apexapi

import org.scalatest.FunSpec
import org.scalatest.matchers.ShouldMatchers
import org.slf4j.LoggerFactory
import com.himmit.apexapi.authentication.Authenticator

/**
 * User: Oskar
 * Date: 03/05/13
 * Time: 20:38
 */
class LoanApiTest  extends FunSpec with ShouldMatchers {
    val logger = LoggerFactory.getLogger(classOf[LoanApiTest])

    val loanId = "a0zi00000009rNH" //4euODw (Peter Sellers)
    describe("The SalesForce Loan API") {

        info("Authenticate once for all test cases to do with getting objects")

        val apiSession = Authenticator.getSession.getOrElse(
            fail("No valid authentication with SalesForce, cannot continue test")
        )

        val getObject = new LoanService(apiSession)

        it("will return a Loan from a Custom APEX API given a existing ID"){

            val resultOption = getObject.getLoan(loanId)
        }
    }

}
