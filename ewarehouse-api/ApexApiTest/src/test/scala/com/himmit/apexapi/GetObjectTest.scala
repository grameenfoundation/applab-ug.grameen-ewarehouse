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
class GetObjectTest  extends FunSpec with ShouldMatchers {
    val logger = LoggerFactory.getLogger(classOf[GetObjectTest])

    logger.info("Test");

    describe("The SalesForce GetObject") {

        info("Authenticate once for all test cases to do with getting objects")
        val apiSessionOption = Authenticator.getSession

        if(apiSessionOption == None)
            fail("No valid authentication with SalesForce, cannot continue test")

        val getObject = new GetObject(apiSessionOption.get)

        it("will return an object from a Custom APEX API given a existing ID"){
            //“https://na8.salesforce.com/services/apexrest/FieldCase”
            val resultOption = getObject.getPosition("CustomPosition", "a00i0000002Tmge") //

            resultOption should not be(None)
            val result =  resultOption.get.asInstanceOf[Position]

            logger.info(result.responsibilities + result.title)

            result.title should be("C# developer")
            result.responsibilities should be("Develop stuff")

        }
        /*it("will return an object when given a existing ID") {

            val resultOption = getObject.get("CustomPosition", "a00i0000002Tmge") //

            resultOption should not be(None)
            val result =  resultOption.get

            logger.info(result.responsibilities + result.title)
            //logger.info(apiSession)

            result.title should be("C# developer")
            result.responsibilities should be("Develop stuff")

        }*/
    }
}