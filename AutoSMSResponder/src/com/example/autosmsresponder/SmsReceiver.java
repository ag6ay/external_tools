package com.example.autosmsresponder;

import java.util.StringTokenizer;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.telephony.SmsManager;
import android.telephony.SmsMessage;
import android.util.Log;


public class SmsReceiver extends BroadcastReceiver {
	@Override
	public void onReceive(Context context, Intent intent) {
		
		Log.v("SmsReceiver", "onReceive");
        Bundle bundle = intent.getExtras();        
        SmsMessage[] msgs = null;
        String phone = null;
        String msgBody = null;
        
        if (bundle != null)
        {
            //---retrieve the SMS message received---
            Object[] pdus = (Object[]) bundle.get("pdus");
            msgs = new SmsMessage[pdus.length];            
            for (int i=0; i<msgs.length; i++){
                msgs[i] = SmsMessage.createFromPdu((byte[])pdus[i]);
                phone = msgs[i].getOriginatingAddress();
                msgBody = msgs[i].getMessageBody().toString();
              
                if (msgBody.toLowerCase().contains("deny".toLowerCase()) == true)
                {
	
                String reply = getReply(msgBody);
                String regex = "[\"][0-9]+[\"]";
                 
                //---respond to SMS message ---
                if (phone.length() > 0 && reply.length() > 0 && reply.matches(regex))
                {
                	this.sendSMS(phone, reply);
                }
              } 
            }
        }              
		
	}
	
	String getReply(String message)
	{
		StringTokenizer tok = new StringTokenizer(message, ":");
		if (tok.countTokens() == 2)
		{
			tok.nextToken();
			String body = tok.nextToken();
			String[] tempResult = body.trim().split("\\s");
			message = tempResult[1];
		}

		return message;
	}	
	
	private void sendSMS(String phoneNumber, String message) {
		 SmsManager sms = SmsManager.getDefault();
		 sms.sendTextMessage(phoneNumber.trim(), null, message.substring(1, message.length() - 1), null, null);
	}

}
