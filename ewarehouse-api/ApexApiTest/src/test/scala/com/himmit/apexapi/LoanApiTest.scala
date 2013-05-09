package com.himmit.apexapi

import org.scalatest.FunSpec
import org.scalatest.matchers.ShouldMatchers
import org.slf4j.LoggerFactory
import com.himmit.apexapi.authentication.Authenticator
import com.himmit.apexapi.parameter.UpdateLoan

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

            resultOption should not be None
            resultOption.get.loan should not be None

            resultOption.get.code should be("200")
            resultOption.get.description should be("OK")

            val loan = resultOption.get.loan.get
            loan.Id should startWith("a0zi00000009rNHAAY")
            loan.Status should be("Default")
            loan.FarmerId should be("3eyUUD")
            loan.DecisionDate should be("2013-04-30")
            loan.ApplicationDate should be("2013-04-29")
            loan.AmountApproved should be(120000.00)
            loan.AmountApplied should be(130000.00)
        }
        it("will update a Loan from a Custom APEX API given a Loan object"){

            val resultOption = getObject.updateLoan(new UpdateLoan(loanId, "Rejected")) //

            resultOption should not be(None)
            resultOption.get.loan should be(None)

            val result = resultOption.get

            result.code should be("200")
            result.description should be("Updated: Loan Id ["+loanId+"], Status: [Rejected]")

        }
        it("will reset (update) a Loan from a Custom APEX API given a Loan object"){

            val resultOption = getObject.updateLoan(new UpdateLoan(loanId, "Default")) //

            resultOption should not be(None)
            resultOption.get.loan should be(None)

            val result = resultOption.get

            result.code should be("200")
            result.description should be("Updated: Loan Id ["+loanId+"], Status: [Default]")
        }

        it("will return a List of two Loans from a Custom APEX API given a Status Default"){

            val result = getObject.getLoans("Default")

            result should not be(null)
            result.loans should not be(None)

            val loans =  result.loans.get

            result.code should be("200")
            result.description should be("OK")

            loans.length should be(2)

        }
        /* it("will return a List of one Clients from a Custom APEX API given a Status Duplicate"){

             val result = getObject.getClients("Duplicate")

             result should not be(null)
             result.clients should not be(None)

             val clients =  result.clients.get

             result.code should be("200")
             result.description should be("OK")

             clients.length should be(1)

         }*/
        it("will return a empty List of Loans from a Custom APEX API given a Status Application"){

            val result = getObject.getLoans("Application")

            result should not be(null)
            result.loans should not be(None)

            val loans =  result.loans.get

            result.code should be("200")
            result.description should be("OK")

            loans.length should be(0)

        }

        it("will update an Array of 2 UpdateLoan objects from a Custom APEX API"){

            val updateLoans = new Array[UpdateLoan](2)
            updateLoans(0) = new UpdateLoan(Id = "a0zi0000000A352AAC", Status = "Rejected")
            updateLoans(1) = new UpdateLoan(Id = "a0zi00000009rNHAAY", Status = "Service")

            val result = getObject.updateLoans(updateLoans)

            result should not be(null)
            result.loans should be(None)

            result.code should be("200")
            result.description should be("Update success")
        }

        it("will reset (update) an Array of 2 UpdateLoan objects from a Custom APEX API"){

            val updateLoans = new Array[UpdateLoan](2)
            updateLoans(0) = new UpdateLoan(Id = "a0zi0000000A352AAC", Status = "Default")
            updateLoans(1) = new UpdateLoan(Id = "a0zi00000009rNHAAY", Status = "Default")

            val result = getObject.updateLoans(updateLoans)

            result should not be(null)
            result.loans should be(None)

            result.code should be("200")
            result.description should be("Update success")
        }
    }
}
