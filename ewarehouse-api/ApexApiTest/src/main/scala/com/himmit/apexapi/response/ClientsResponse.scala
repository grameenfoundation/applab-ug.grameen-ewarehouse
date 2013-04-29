package com.himmit.apexapi.response

import com.himmit.apexapi.Client

/**
 * User: Oskar
 * Date: 29/04/13
 * Time: 15:19
 */
case class ClientsResponse (code: String, description: String, clients: Option[Array[Client]])
