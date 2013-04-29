package com.himmit.apexapi.authentication

import dispatch._, Defaults._
import scala.util.parsing.json.{JSON, JSONObject}
import org.slf4j.LoggerFactory

object Authenticator {
    val logger = LoggerFactory.getLogger(classOf[Authenticator])

    val authenticator = new Authenticator

    def getSession() : Option[ApiSession] = {
        logger.info("Check if there is a session with SalesForce")
        if(authenticator.apiSession == None){
            logger.info("No session found, authenticate with SalesForce")
            authenticator.apiSession = authenticator.authenticate()
        }

        return authenticator.apiSession
    }
}

class Authenticator {

    val logger = LoggerFactory.getLogger(classOf[Authenticator])

    var apiSession : Option[ApiSession] = None

    val clientId = "3MVG9A2kN3Bn17htzxn0E6oDR.cevoUhYYcTZJ.Bx9X4ohd5yMgb.dtzYdw29iz58bd9yUzZQdAEijjBNAa3M"
    val clientSecret = "3649899522752974225"
    val userName = "oskar@himmelreich-it.com"
    val password = "19Wolfs92Klem!"
    val securityToken = "MUols8jDHasp9lGEiJHSs1Zh"

    def sfHost = host("login.salesforce.com") / "services" / "oauth2" / "token" secure

    def loginHost = sfHost.POST

    def request = loginHost
        .addHeader("content-type", "application/x-www-form-urlencoded")
        .addParameter("grant_type", "password")
        .addParameter("client_id", clientId)
        .addParameter("client_secret", clientSecret)
        .addParameter("username", userName)
        .addParameter("password", password + securityToken)

    def authenticate(): Option[ApiSession] = {

        val response = Http(request > as.String)

        val result = JSON.parseFull(response())

        if(result == None)
            return None

        val map = result.get.asInstanceOf[Map[String, String]]

        if(map.contains(ApiSession.AccessToken) && map.contains(ApiSession.InstanceUrl))
            return new Some(
                new ApiSession(
                    accessToken = map.get(ApiSession.AccessToken).get,
                    instanceUrl = map.get(ApiSession.InstanceUrl).get,
                    signature = map.get(ApiSession.Signature).get,
                    id = map.get(ApiSession.Id).get,
                    issuedAt = map.get(ApiSession.IssuedAt).get.toLong
                )
            )

        return None
    }



}