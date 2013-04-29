package com.himmit.apexapi

import spray.json.{JsonWriter, DefaultJsonProtocol}

/**
 * User: Oskar
 * Date: 27/04/13
 * Time: 16:57
 */
object JsonConfigurator extends DefaultJsonProtocol {
    implicit val positionFormat = jsonFormat2(Position)
    implicit val clientFormat = jsonFormat5(Client)
}
