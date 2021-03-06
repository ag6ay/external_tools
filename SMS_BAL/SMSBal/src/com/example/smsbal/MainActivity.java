package com.example.smsbal;

import android.os.Bundle;
import android.app.Activity;
import android.view.Menu;
import android.telephony.SmsManager;

public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        // call sms function
        try {
         sendSmsMessage("53086", "BAL");
         
        } catch (Exception e) {
         e.printStackTrace();
        }        
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }
    
    private void sendSmsMessage(String address, String message)
    throws Exception {
         SmsManager smsMgr = SmsManager.getDefault();
         smsMgr.sendTextMessage(address, null, message, null, null);
    }    
}
