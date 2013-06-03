package com.himmit.apexapi

import org.scalatest.FunSpec
import org.scalatest.matchers.ShouldMatchers
import org.slf4j.LoggerFactory
import com.himmit.apexapi.authentication.Authenticator
import scala.Predef._
import com.himmit.apexapi.parameter.{UpdateSale, UpdateClient}

/**
 * User: Oskar
 * Date: 21/04/13
 * Time: 13:20
 */
class SalesApiTest  extends FunSpec with ShouldMatchers {
    val logger = LoggerFactory.getLogger(classOf[SalesApiTest])

    describe("The SalesForce Client API") {

        info("Authenticate once for all test cases to do with getting objects")

        val apiSession = Authenticator.getSession.getOrElse(
            fail("No valid authentication with SalesForce, cannot continue test")
        )

        val getObject = new SalesService

        it("will return a List of Clients from a Custom APEX API given a Status New"){

            val result = getObject.getSales("New")

            result should not be(null)
            result.sales should not be(None)

            val sales =  result.sales.get

            result.code should be("200")
            result.description should be("OK")

            sales.length should be(2)

        }
        /* it("will return a List of one Clients from a Custom APEX API given a Status Duplicate"){

             val result = getObject.getClients("Duplicate")

             result should not be(null)
             result.clients should not be(None)

             val clients =  result.clients.get

             result.code should be("200")
             result.description should be("OK")

             clients.length should be(1)

         }
         it("will return a empty List of Clients from a Custom APEX API given a Status Failed"){

             val result = getObject.getClients("Failed")

             result should not be(null)
             result.clients should not be(None)

             val clients =  result.clients.get

             result.code should be("200")
             result.description should be("OK")

             clients.length should be(0)

         }*/

        it("will update an Array of 2 UpdateSale objects from a Custom APEX API"){

            val updateSales = new Array[UpdateSale](2)
            updateSales(0) = new UpdateSale(Id = "a1Oi00000001qskEAA", Status = "Duplicate")
            updateSales(1) = new UpdateSale(Id = "a1Oi00000001vUHEAY", Status = "Failed")

            val result = getObject.updateClients(updateSales)

            result should not be(null)
            result.sales should be(None)

            result.code should be("200")
            result.description should be("Update success")


        }

        it("will reset (update) an Array of 2 UpdateClient objects from a Custom APEX API"){

            val updateSales = new Array[UpdateSale](2)
            updateSales(0) = new UpdateSale(Id = "a1Oi00000001qskEAA", Status = "New")
            updateSales(1) = new UpdateSale(Id = "a1Oi00000001vUHEAY", Status = "New")

            val result = getObject.updateClients(updateSales)

            result should not be(null)
            result.sales should be(None)

            result.code should be("200")
            result.description should be("Update success")
        }





    }
}