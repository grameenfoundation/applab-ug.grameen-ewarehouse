//package com.himmit.apexapi
//
//
//import org.scalatest.FunSpec
//import org.scalatest.matchers.ShouldMatchers
//import org.slf4j.LoggerFactory
//import com.himmit.apexapi.authentication.Authenticator
//import scala.Predef._
//import com.himmit.apexapi.parameter._
//
///**
// * User: Oskar
// * Date: 06/06/13
// * Time: 17:23
// */
//class GroupApiTest extends FunSpec with ShouldMatchers {
//    val logger = LoggerFactory.getLogger(classOf[ClientApiTest])
//
//    val clientId = "3eyUUD" //4euODw (Peter Sellers)
//    describe("The SalesForce Client API") {
//
//        info("Authenticate once for all test cases to do with getting objects")
//
//        val apiSession = Authenticator.getSession.getOrElse(
//            fail("No valid authentication with SalesForce, cannot continue test")
//        )
//
//        val getObject = new ClientService(apiSession)
//
//        it("will return a Client from a Custom APEX API given a existing ID"){
//
//            val resultOption = getObject.insertGroup("""AR/12/001/002""", "Kiruri Farmers")
//        }
//    }
//}
