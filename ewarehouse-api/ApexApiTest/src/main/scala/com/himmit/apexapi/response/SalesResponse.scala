package com.himmit.apexapi.response

import com.himmit.apexapi.Sale

/**
 * User: Oskar
 * Date: 23/05/13
 * Time: 22:22
 */
case class SalesResponse (code: String, description: String, sales: Option[Array[Sale]])
