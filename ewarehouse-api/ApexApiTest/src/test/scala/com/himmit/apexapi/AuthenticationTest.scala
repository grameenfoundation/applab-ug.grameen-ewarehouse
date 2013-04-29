package com.himmit.apexapi

import org.scalatest.FunSpec
import org.scalatest.matchers.ShouldMatchers
import org.slf4j.{LoggerFactory, Logger}
import com.himmit.apexapi.authentication.{ApiSession, Authenticator}

class AuthenticationTest extends FunSpec with ShouldMatchers {
    val logger = LoggerFactory.getLogger(classOf[AuthenticationTest])

    describe("The SalesForce Authenticator") {
        it("will return ApiSession on successful authentication") {

            val apiSession = Authenticator.getSession();

            apiSession should not be(None)

            logger.info(apiSession.get.instanceUrl)

            apiSession.get.instanceUrl should include("salesforce")
            apiSession.get.issuedAt should be > (10000l)
        }
    }
}