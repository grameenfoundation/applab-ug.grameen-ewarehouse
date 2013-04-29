package com.himmit.apexapi.base

import dispatch._, Defaults._
import scala.util.parsing.json.JSON
import org.slf4j.LoggerFactory
import com.himmit.apexapi.authentication.ApiSession
import spray.json.{JsonParser, JsValue}


/**
 * User: Oskar
 * Date: 21/04/13
 * Time: 10:00
 */
class ApexApiRequest (val apiSession: ApiSession) {

    val logger = LoggerFactory.getLogger(classOf[ApexApiRequest])
    val apiVersion = "v27.0"

    def requestHost = host(apiSession.instanceUrl.replace("https://", "")) / "services" / "apexrest" / "eu_himmit" secure

    def requestType = requestHost.GET

    def get(objectType: String, id: String = null) : Option[JsValue] =  {

        logger.info("Build request for [%s] ID=%s - %s", objectType, id, "")

        // build the final query url with the object type and id
        def requestObject = requestType / objectType

        def requestAddHeaders =
                requestObject
                    .addHeader("Authorization", "Bearer "+apiSession.accessToken)
                    .addHeader("content-type", "application/x-www-form-urlencoded")

        def requestParameters =
            if(id != null)
                requestAddHeaders.addQueryParameter("id", id)
            else
                requestAddHeaders

        val request= requestParameters

        val response = Http(request > as.String)
        val stringObjs = response()

        logger.debug(stringObjs)

        new Some(JsonParser(stringObjs))
    }
}