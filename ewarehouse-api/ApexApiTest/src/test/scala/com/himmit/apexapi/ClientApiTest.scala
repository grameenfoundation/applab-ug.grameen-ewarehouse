package com.himmit.apexapi

import org.scalatest.FunSpec
import org.scalatest.matchers.ShouldMatchers
import org.slf4j.LoggerFactory
import com.himmit.apexapi.base.GetObject
import com.himmit.apexapi.authentication.Authenticator
import scala.Predef._

/**
 * User: Oskar
 * Date: 21/04/13
 * Time: 13:20
 */
class ClientApiTest  extends FunSpec with ShouldMatchers {
    val logger = LoggerFactory.getLogger(classOf[ClientApiTest])

    describe("The SalesForce Client API") {

        info("Authenticate once for all test cases to do with getting objects")
        val apiSessionOption = Authenticator.getSession

        if(apiSessionOption == None)
            fail("No valid authentication with SalesForce, cannot continue test")

        val getObject = new GetObject(apiSessionOption.get)

        it("will return a Client from a Custom APEX API given a existing ID"){
            //“https://na8.salesforce.com/services/apexrest/FieldCase”
            val resultOption = getObject.getClient("client", "a01i0000001E5iK") //

            resultOption should not be(None)
            val result =  resultOption.get.asInstanceOf[Client]

            logger.info(result.id + result.name)

            result.id should startWith("a01i0000001E5iK")
            result.name should be("Jane Fonda")
            result.dateOfBirth should be("1937-12-21")
            result.timeAuthorized should be("2013-04-27T14:32:00.000Z")
            result.married should be(true)


        }
    }
}