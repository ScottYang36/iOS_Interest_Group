<?php
/**
 *  This file is part of amfPHP
 *
 * LICENSE
 *
 * This source file is subject to the license that is bundled
 * with this package in the file license.txt.
 * @package Amfphp_Plugins_Json
 */

/**
 * plugin allowing service calls coming from JavaScript encoded as JSON 
 * strings and returned as JSON strings using POST parameters. 
 * Requires at least PHP 5.2.
 *
 * @package Amfphp_Plugins_Json
 * @author Yannick DOMINGUEZ
 */
class AmfphpJson implements Amfphp_Core_Common_IDeserializer, Amfphp_Core_Common_IDeserializedRequestHandler, Amfphp_Core_Common_IExceptionHandler, Amfphp_Core_Common_ISerializer {

    /**
    * the content-type string indicating a JSON content
    */
    const JSON_CONTENT_TYPE = "application/json";
	
    /**
     * constructor. Add filters on the HookManager.
     * @param array $config optional key/value pairs in an associative array. Used to override default configuration values.
     */
    public function  __construct(array $config = null) {
        $filterManager = Amfphp_Core_FilterManager::getInstance();
        $filterManager->addFilter(Amfphp_Core_Gateway::FILTER_DESERIALIZER, $this, "filterHandler");
        $filterManager->addFilter(Amfphp_Core_Gateway::FILTER_DESERIALIZED_REQUEST_HANDLER, $this, "filterHandler");
        $filterManager->addFilter(Amfphp_Core_Gateway::FILTER_EXCEPTION_HANDLER, $this, "filterHandler");
        $filterManager->addFilter(Amfphp_Core_Gateway::FILTER_SERIALIZER, $this, "filterHandler");
    }

    /**
     * If the content type contains the "json" string, returns this plugin
     * @param mixed null at call in gateway.
     * @param String $contentType
     * @return this or null
     */
    public function filterHandler($handler, $contentType){
        if(strpos($contentType, self::JSON_CONTENT_TYPE) !== false)
            return $this;
		return $handler;
    }

    /**
     * @see Amfphp_Core_Common_IDeserializer
     */
    public function deserialize(array $getData, array $postData, $rawPostData){
		return json_decode($rawPostData);
    }

    /**
     * Retrieve the serviceName, methodName and parameters from the PHP object
     * representing the JSON string
     * @see Amfphp_Core_Common_IDeserializedRequestHandler
     * @return the service call response
     */
    public function handleDeserializedRequest($deserializedRequest, Amfphp_Core_Common_ServiceRouter $serviceRouter){
		
		if(isset ($deserializedRequest->serviceName)){
            $serviceName = $deserializedRequest->serviceName;
        }else{
            throw new Exception("Service name field missing in POST parameters \n" . print_r($deserializedRequest, true));
        }
        if(isset ($deserializedRequest->methodName)){
            $methodName = $deserializedRequest->methodName;
        }else{
            throw new Exception("MethodName field missing in POST parameters \n" . print_r($deserializedRequest, true));
        }
        $parameters = array();
        if(isset ($deserializedRequest->parameters)){
            $parameters = $deserializedRequest->parameters;
        }
        return $serviceRouter->executeServiceCall($serviceName, $methodName, $parameters);
        
    }

    /**
     * @see Amfphp_Core_Common_IExceptionHandler
     */
    public function handleException(Exception $exception){
        return str_replace("\n", "<br>", $exception->__toString());
        
    }
    
    /**
     * Encode the PHP object returned from the service call into a JSON string
     * @see Amfphp_Core_Common_ISerializer
     * @return the encoded JSON string sent to JavaScript
     */
    public function serialize($data){
    	// Add JSON_FORCE_OBJECT to force we always return object format with php array
    	//	$array = array("a","b","c");
		//	json_encode($array); // ["a","b","c"]
		//	json_encode($array, JSON_FORCE_OBJECT); // {"0":"a", "1":"b","2":"c"}

        return json_encode($data, JSON_FORCE_OBJECT);
    }


}
?>
