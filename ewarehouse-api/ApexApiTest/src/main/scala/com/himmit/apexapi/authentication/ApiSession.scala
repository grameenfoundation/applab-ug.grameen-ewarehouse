package com.himmit.apexapi.authentication

/**
 * User: Oskar
 * Date: 20/04/13
 * Time: 21:44
 */

object ApiSession{
    val AccessToken = "access_token"
    val InstanceUrl = "instance_url"
    val Signature = "signature"
    val Id = "id"
    val IssuedAt = "issued_at"
}

class ApiSession (val accessToken: String, val instanceUrl: String, val signature: String, val id: String, val issuedAt: Long)
