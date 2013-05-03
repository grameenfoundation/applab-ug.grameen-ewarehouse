package com.himmit.apexapi.base

import dispatch._, Defaults._
import scala.util.parsing.json.{JSONObject, JSON}
import org.slf4j.LoggerFactory
import com.himmit.apexapi.authentication.ApiSession
import spray.json.{JsonParser, pimpAny, JsValue}
import com.ning.http.multipart.Part
import com.ning.http.client.RequestBuilder


/**
 * User: Oskar
 * Date: 21/04/13
 * Time: 10:00
 */
class ApexApiRequest (val apiSession: ApiSession) {

    val logger = LoggerFactory.getLogger(classOf[ApexApiRequest])

    def requestHost = host(apiSession.instanceUrl.replace("https://", "")) / "services" / "apexrest" / "ewarehouse" secure

    //def buildRequest

    def get(objectType: String, parameters: Map[String, String]) : Option[JsValue] =  {

        logger.info("Build GET request for [%s]", objectType)
        def requestObject = requestHost / objectType

        def requestType = requestObject.GET

        doRequest(requestType, parameters, get = true)
    }

    def patch(objectType: String, parameters: Map[String, String]) = {

        logger.info("Build PATCH request for [%s]", objectType)
        def requestObject = requestHost / objectType
        def requestType = requestObject.PATCH

        doRequest(requestType, parameters)
    }

    def patch(objectType: String, json: String) = {

        logger.info("Build PATCH request for [%s]", objectType)
        def requestObject = requestHost / objectType
        def requestType = requestObject.PATCH

        logger.debug(json)

        doRequest(requestType = requestType, body = json)
    }

    def doRequest(requestType: RequestBuilder, parameters: Map[String, String] = null, body: String = null, get: Boolean = false) : Option[JsValue] = {

        // check requirements
        if(parameters != null && body != null){
            throw new Exception("Set either the parameters or body parameter of the method but not both")
        }

        // add Headers
        def requestAddHeaders =
            requestType
                .addHeader("Authorization", "Bearer "+apiSession.accessToken)
                .addHeader("content-type", "application/x-www-form-urlencoded")

        // push the parameters in the body as JSON
        def jsonBody =
            if(parameters != null)
                JSONObject(parameters).toString()
            else
                body
        logger.debug(jsonBody)

        // when method is GET add parameters as query, otherwise add them as JSON in the body
        def request =
            if(get)
                requestAddHeaders <<?  parameters
            else
                requestAddHeaders.setBody(jsonBody)

        //val request= requestBody
        // do the request
        val response = Http(request > as.String)

        // because of Actor system, wait for the response "response()"
        val stringObjs = response()

        logger.debug(stringObjs)

        // response should be JSON, parse and return
        new Some(JsonParser(stringObjs))
    }
}