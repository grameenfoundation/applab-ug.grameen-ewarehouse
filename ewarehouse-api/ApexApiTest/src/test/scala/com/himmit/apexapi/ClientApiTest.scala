package com.himmit.apexapi

import org.scalatest.FunSpec
import org.scalatest.matchers.ShouldMatchers
import org.slf4j.LoggerFactory
import com.himmit.apexapi.authentication.Authenticator
import scala.Predef._
import com.himmit.apexapi.parameter.UpdateClient
import com.himmit.apexapi.ClientService

/**
 * User: Oskar
 * Date: 21/04/13
 * Time: 13:20
 */
class ClientApiTest  extends FunSpec with ShouldMatchers {
    val logger = LoggerFactory.getLogger(classOf[ClientApiTest])

    val clientId = "a01i0000001E5iK"
    describe("The SalesForce Client API") {

        info("Authenticate once for all test cases to do with getting objects")

        val apiSession = Authenticator.getSession.getOrElse(
            fail("No valid authentication with SalesForce, cannot continue test")
        )

        val getObject = new ClientService(apiSession)

        it("will return a Client from a Custom APEX API given a existing ID"){

            val resultOption = getObject.getClient(clientId) //

            resultOption should not be(None)
            resultOption.get.client should not be(None)

            val result = resultOption.get
            val resultClient =  resultOption.get.client.get

            logger.info(resultClient.id + " - " +resultClient.FirstName + " " + resultClient.LastName)

            result.code should be("200")
            result.description should be("OK")

            resultClient.id should startWith(clientId)
            resultClient.FirstName should be("Jane")
            resultClient.LastName should be("Fonda")

            resultClient.DateOfBirth should be("1937-12-21")
            resultClient.PhoneNumber should be("xxxxx")
            resultClient.MobileNumber should be("xxxxx")
            resultClient.IDNumber should be("xxxxx")
            resultClient.Gender should be("xxxxx")
            resultClient.Address1 should be("xxxxx")
            resultClient.Address2 should be("xxxxx")
            resultClient.City should be("xxxxx")
            resultClient.Country should be("xxxxx")
        }
        it("will update a Client from a Custom APEX API given a client object"){

            val resultOption = getObject.updateClient(new UpdateClient(clientId, "Processed")) //

            resultOption should not be(None)
            resultOption.get.client should not be(None)

            val result = resultOption.get
            val resultClient =  resultOption.get.client.get

            logger.info(resultClient.id + " - " +resultClient.FirstName + " " + resultClient.LastName)

            result.code should be("200")
            result.description should be("OK")

            resultClient.id should startWith(clientId)
            resultClient.FirstName should be("Jane")
            resultClient.LastName should be("Fonda")

            resultClient.DateOfBirth should be("1937-12-21")
            resultClient.PhoneNumber should be("xxxxx")
            resultClient.MobileNumber should be("xxxxx")
            resultClient.IDNumber should be("xxxxx")
            resultClient.Gender should be("xxxxx")
            resultClient.Address1 should be("xxxxx")
            resultClient.Address2 should be("xxxxx")
            resultClient.City should be("xxxxx")
            resultClient.Country should be("xxxxx")
        }
        it("will reset (update) a Client from a Custom APEX API given a client object"){

            val resultOption = getObject.updateClient(new UpdateClient(clientId, "Processed")) //

            resultOption should not be(None)
            resultOption.get.client should not be(None)

            val result = resultOption.get
            val resultClient =  resultOption.get.client.get

            logger.info(resultClient.id + " - " +resultClient.FirstName + " " + resultClient.LastName)

            result.code should be("200")
            result.description should be("OK")

            resultClient.id should startWith(clientId)
            resultClient.FirstName should be("Jane")
            resultClient.LastName should be("Fonda")

            resultClient.DateOfBirth should be("1937-12-21")
            resultClient.PhoneNumber should be("xxxxx")
            resultClient.MobileNumber should be("xxxxx")
            resultClient.IDNumber should be("xxxxx")
            resultClient.Gender should be("xxxxx")
            resultClient.Address1 should be("xxxxx")
            resultClient.Address2 should be("xxxxx")
            resultClient.City should be("xxxxx")
            resultClient.Country should be("xxxxx")
        }

    }
}