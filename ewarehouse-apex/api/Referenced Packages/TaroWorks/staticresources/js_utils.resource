/**
* Decode the text to HTML entities
* <p>
* Get a encoded text and translate it into HTML entities
* (Related to IDALMSA-2272)
*
* @param text String    Encoded Text.
* @retunr text String   Decoded Text.
*/
function htmlDecode( text ){

    return (text) ? jQuery('<div/>').html(text).text() : '';
}

/**
* Encode the HTML text to special characters
* <p>
* Get a html text and translate special characters
* (Related to IDALMSA-2272)
*
* @param text String    Decoded Text.
* @return text String   Encoded Text.
*/
function htmlEncode( text ){

    return (text) ? jQuery('<div/>').text(text).html() : '';
}