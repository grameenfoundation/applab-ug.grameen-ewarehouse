package com.himmit.apexapi

import org.scalatest.FunSpec
import org.scalatest.matchers.ShouldMatchers
import org.slf4j.LoggerFactory
import com.himmit.apexapi.authentication.Authenticator
import com.himmit.apexapi.parameter.AddRepayment
import java.util.Date
/**
 * User: Oskar
 * Date: 12/05/13
 * Time: 14:51
 */
class RepaymentApiTest  extends FunSpec with ShouldMatchers {
    val logger = LoggerFactory.getLogger(classOf[LoanApiTest])

    val loanId = "a0zi00000009rNH" //4euODw (Peter Sellers)
    val farmerId = "a0ii0000000fmex" //3eyUUD"
    val saleId = "a1Oi00000001qsk" // S-000232
    describe("The SalesForce Loan API") {

        info("Authenticate once for all test cases to do with getting objects")

        val apiSession = Authenticator.getSession.getOrElse(
            fail("No valid authentication with SalesForce, cannot continue test")
        )

        val getObject = new LoanService(apiSession)

        it("will return add Loan Repayment to a loan via the Custom APEX API"){

            val repayment = new AddRepayment(None, loanId, saleId, 1000, "Loan-Repayment", "2012-12-21")
            val repaymentArr = new Array[AddRepayment](1);
            repaymentArr(0) = repayment

            val resultOption = getObject.addRepayments(repaymentArr)

            resultOption should not be None
            resultOption.loans should be(None)

            resultOption.code should be("200")
            resultOption.description should be("Loan repayments posted successfully.")
        }
        it("will return repayments from the APEX API given a loan id"){

            val resultOption = getObject.getRepayments(loanId)

            resultOption should not be None
            resultOption.repayments should not be(None)

            resultOption.code should be("200")
            resultOption.description should be("OK")
        }
    }

}
