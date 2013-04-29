package com.himmit.apexapi.response

import com.himmit.apexapi.Client

/**
 * User: Oskar
 * Date: 29/04/13
 * Time: 13:34
 */
case class ClientResponse (code: String, description: String, client: Option[Client])
