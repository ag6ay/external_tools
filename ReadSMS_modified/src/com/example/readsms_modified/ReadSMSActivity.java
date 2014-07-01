package com.example.readsms_modified;

import java.io.File;

import android.os.Bundle;
import android.app.Activity;
import android.view.Menu;
import android.widget.ProgressBar;


public class ReadSMSActivity extends Activity {
	final String FILE_NAME = "SMS.txt";
	public SmsReceiver receiver;
	public ProgressBar progress;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
    	
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_read_sms);   
    }
    
  /*  @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.read_sm, menu);
        return true;
    }*/
    
  
    
}
