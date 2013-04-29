package com.himmit.apexapi.base

import org.slf4j.LoggerFactory
import com.himmit.apexapi.authentication._
import spray.json._
import com.himmit.apexapi._
import com.himmit.apexapi.JsonConfigurator._


/**
 * User: Oskar
 * Date: 21/04/13
 * Time: 10:00
 */
class GetObject (val apiSession: ApiSession) {

    //val logger = LoggerFactory.getLogger(classOf[GetObject])

    def getPosition(objectType: String, id: String) : Option[Position] =  {
        val jsonResult = new ApexApiRequest(Authenticator.getSession.get).get(objectType, id)

        val myObject = jsonResult.get.convertTo[Position]

        return Some(myObject)

    }

    def getClient(objectType: String, id: String) : Option[Client] =  {
        val jsonResult = new ApexApiRequest(Authenticator.getSession.get).get(objectType, id)
        val myObject = jsonResult.get.convertTo[Client]

        return Some(myObject)

    }

}