/**
* Name : AC_AppLauncherController
* Author : Accenture IDC
* Description : This class holds the Logic for the getting the Url passed based on Parameters.                 
* Date : 06/5/14 
*/
public with sharing class AC_AppLauncherController{
    
    // public variables
    public String link {get;set;}      
    public Application__c app {get;set;}
    public String caseC {get;set;} 
    
    // private variables
    private List<AppParameter__c> appParams = new List<AppParameter__c>();
    private String appId=null;
    private String track=null;
    private static final String STATICPARAM = 'Static';
    private static final String PASSTHROUGHPARAM = 'PassThrough';
    private static final String APPIDPARAM = 'AppId';
    private static final String CASEPARAM = 'case' ;
    private static final String APPLICATIONNAME = 'Application Catalog';
    private static final String CLASSNAME = 'AC_AppLauncherController';
    private static final String METHODNAME = 'CreateParameteizedURL';
    private static final String ISURLFROMCASE = 'True';
    private static final String ENCODING_SCHEME = 'UTF-8';
    private static final Integer ZERO = 0;
    private static final String URL = 'url';
    private static final String HTTP= 'http';
    private static final String HTTPS= 'https://';
    private static final String TRACKNUMS= '&trackNums=';
  
    /**
       @description  : Construtor of AC_AppLauncherController Class
       @param        : NA
       @return       : NA
      */
    public AC_AppLauncherController() {
        
        caseC = null;
        link = null;
    }
    
    /**
       @Method Name  : createParameterizedUrl
       @description  : This Method appends the Link  with the Application name and Parameter along with parameter Type
       @param        : NA
       @return       : void
    */
    public void createParameterizedUrl() {
       
        Map<String,String> pageParams = ApexPages.currentPage().getParameters();
        
        if(pageParams.containsKey(APPIDPARAM)) {
            
            //appId is a parameter pased in URL to Page AC_AppLauncher. It is used to identify the app to be opened.            
                appId = EncodingUtil.urlDecode(pageParams.get(APPIDPARAM),ENCODING_SCHEME);
            
            if(pageParams.containsKey(CASEPARAM)) {
                //caseC is a parameter passed in URL to Page AC_AppLauncher.It is set 'true' if link is clicked from a case record.
                caseC = EncodingUtil.urlDecode(pageParams.get(CASEPARAM),ENCODING_SCHEME);
            }
            
            try {
                app = [select URL__c, App_Type__c from Application__c where Name =: appId LIMIT 1];
              
             // If Applauncher is called from Shipping App than it will have "url" as a parameter in Page URL
             if(pageParams.containsKey(URL)){               
                link=ApexPages.currentPage().getParameters().get('url');
                
                //if URl is having tracknums as a parameter than add it to the final link
                    track=ApexPages.currentPage().getParameters().get('trackNums');
                if(String.isNotBlank(track)){
                    link=link+TRACKNUMS+track;
                }
                
                // If link is not containing http than add it to the link
                if(!link.contains(HTTP)){
                link=HTTPS+link;
                }
                           
             }
             else{
                PageReference pageLink = new PageReference(app.URL__c);
                
                appParams = [select Param_Value__c ,Param_Type__c ,Name ,Application__r.App_Type__c
                             from AppParameter__c where Application__r.Name = :appid LIMIT 10];
                String param = null;
                //check if there are any parameters for this link
                if(appParams != null && !appParams.isEmpty()) {
                   
                    for(AppParameter__c appParam : appParams ) {
                    
                        param = null;
                        //Create link based on whether parameters are static or pass through
                        if(STATICPARAM.equalsIgnoreCase(appParam.Param_Type__c)) {
                         
                            param = appParam.Param_Value__c;   
                        }
                        else if(ISURLFROMCASE.equalsIgnoreCase(caseC) && pageParams.containsKey(appParam.Name)) {
                        
                            param = EncodingUtil.urlDecode(pageParams.get(appParam.Name),ENCODING_SCHEME);                                                          
                        }   
                        if(!String.isBlank(param)) {
                            
                            pageLink.getParameters().put(EncodingUtil.urlEncode(appParam.Name,ENCODING_SCHEME),param);
                        }  
                    }
                }
                link = pageLink.getUrl();
              }
            }
            catch(Exception gExcp) {
                
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,gEXCp.getMessage());
                ApexPages.addMessage(errMsg);
                //Calling the method in Exception Logging Framework to create an Exception log record for handled general Exception
                UTIL_LoggingService.logHandledException(gExcp, userinfo.getOrganizationId(), APPLICATIONNAME,
                                                        CLASSNAME, METHODNAME, null, LoggingLevel.ERROR);
            }
        }
        else {
            
            WPUtility.displayErrorMessage2UI(LABEL.GenericErrorMessage);
        }
    }
}