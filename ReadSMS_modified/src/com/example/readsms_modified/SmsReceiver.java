package com.example.readsms_modified;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.StringTokenizer;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import android.telephony.SmsManager;
import android.telephony.SmsMessage;
import android.util.Log;
import android.widget.Toast;

public class SmsReceiver extends BroadcastReceiver{
	final String FILE_NAME = "SMS.txt";

	@Override
	public void onReceive(Context context, Intent intent) {
		// TODO Auto-generated method stub
		
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
                String tempString = phone+": "+msgBody;
                Toast.makeText(context, tempString, Toast.LENGTH_LONG).show();
                Log.d("***SMSText", "smsMessage" + tempString );
                String[] msgBodyByWord = getMsgBodyByWord(msgBody);
                if (msgBodyByWord != null && phone.length() >0 ) {
                	
                	if (msgBodyByWord.length > 11  && msgBodyByWord[0].equals("Reply")
                		&& msgBodyByWord[2].equals("to") && msgBodyByWord[3].equals("securely") 
                		&& msgBodyByWord[4].equals("confirm") && msgBodyByWord[5].equals("your") && msgBodyByWord[6].equals("identity"))
                	{
                		
                		this.sendSMS(phone, msgBodyByWord[1]);
                		
                	}
                }
          }	
	}                	
 }

	private String[] getMsgBodyByWord(String msgBody) {
		StringTokenizer tok = new StringTokenizer(msgBody, ":");
		String[] tempResult = null;
		if (tok.countTokens() == 2)
		{
			tok.nextToken();
			String body = tok.nextToken();
			tempResult = body.trim().split("\\s");
		}

		return tempResult;
	}
	 
	private void sendSMS(String phoneNumber, String message) {
		 SmsManager sms = SmsManager.getDefault();
		 sms.sendTextMessage(phoneNumber.trim(), null, message.substring(1, message.length() - 1), null, null);
		 Log.d("***SMSText", "Reply*** OOB smsMessage*****Debug" + message.substring(1, message.length() - 1));
	     
	}
	
}
