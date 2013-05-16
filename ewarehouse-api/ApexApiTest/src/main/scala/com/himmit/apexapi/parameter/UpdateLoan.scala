package com.himmit.apexapi.parameter

import com.sun.javaws.exceptions.InvalidArgumentException

/**
 * User: Oskar
 * Date: 06/05/13
 * Time: 16:41
 */
case class UpdateLoan (Id: String, Status: String, Balance: Float) {

    val allowedStatus = List[String] ("Application","Processing", "Rejected", "Service", "Default", "Repaid")
    if(!allowedStatus.contains(Status))
        throw new InvalidArgumentException(allowedStatus.toArray)


}
