package com.himmit.apexapi.parameter

import com.sun.javaws.exceptions.InvalidArgumentException

/**
 * User: Oskar
 * Date: 29/04/13
 * Time: 12:00
 */
case class UpdateClient(id: String, status: String) {

    val allowedStatus = List[String] ("Processed","Duplicate", "Failed")
    if(!allowedStatus.contains(status))
        throw new InvalidArgumentException(allowedStatus.toArray)          //"""status should be "Processed","Duplicate", "Failed" """



}
