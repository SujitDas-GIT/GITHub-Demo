<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Email_to_Application_Owner</fullName>
        <description>Send Email to Application Owner</description>
        <protected>true</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AU_ApplicationReportingFolder/AU_Application_Error</template>
    </alerts>
    <rules>
        <fullName>Application Error Report</fullName>
        <actions>
            <name>Send_Email_to_Application_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AU_DebugInfo__c.Level__c</field>
            <operation>equals</operation>
            <value>Error</value>
        </criteriaItems>
        <description>This rule will send out an email if the application reports an error.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
