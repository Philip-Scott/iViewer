/*
 * Copyright (c) 2015 Felipe Escoto
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 
 * Author:
 *      Felipe Escoto 
 */
 
using GLib;
using Gtk;
using Gdk;
using WebKit;
using Granite.Widgets;
using Granite.Services;
using Notify;

/*
	valac-0.26 --pkg gtk+-3.0 --pkg webkit2gtk-3.0 --pkg libnotify --pkg granite --thread --target-glib 2.32 iViewer.vala && ./iViewer
	sudo cp org.felipe.iViewer*.xml /usr/share/glib-2.0/schemas/
	sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
	
	TODO:	!Run in background: using dbus? 
			Fix Notification Icon
			"Pakage" the app for an easyer install (Don't use ~/.local)
			
			Android support? 
			
*/
namespace iMessage {

	private Gtk.Window app;
	private Welcome welcome;
	private WebView view;
	private Gtk.HeaderBar headerbar;
	private Notify.Notification notification;
	private ToolButton refresh_button;
    private ToolButton return_button;
	private GLib.Settings settings;
	private Box box;
	private InfoBar infobar;

	private int main_index;	
	private int messages = 0;
	private int type[3]; 
	private string data_path;
	private bool newdevice = false;
	private bool running = false;
	private string device;
	
public class Device_Dialog : Gtk.Dialog { //New device dialog
	
	public signal void connect_device (string url);

	public bool address_focus = false;
	private int index;
	
	public Device_Dialog () {
		
		//Find a place to store your shortcut
		if 		 (settings.get_int(@"type0") == -1 ) index = 0;
		else if (settings.get_int(@"type1") == -1 ) index = 1;
		else if (settings.get_int(@"type2") == -1 ) index = 2;
		else index = -1;
	
		this.set_border_width (12);
		set_keep_above (true);
		set_size_request (420, 300);
        resizable = false;
		
		
		var mainbox 		= this.get_content_area();
		var title 			= new Label ("<b>Connect To Device</b>");
		var type_label 		= new Label ("Device Type: ");
		var address_label 	= new Label ("Address: ");
		var favorites_label	= new Label ("Add to favorites: ");
		title.set_use_markup (true);
		type_label.xalign = 0;
		address_label.xalign = 0;
		favorites_label.xalign = 0;
		title.xalign = 0;
		
		
		var type_tbox 			= new ComboBoxText ();
		var address_tbox 	 	= new Entry ();
		var favorites_switch	= new Switch ();
		var box = new HBox (false, 20);
		box.add (favorites_label);
		box.add (favorites_switch);
			
		this.add_button("Cancel", 2);
		this.add_button("Connect", 1);		
		
		var grid = new Grid ();
		grid.attach (title,				0,  0,  1,  1);
		grid.attach (type_label, 		0,	1, 	1,	1);
		grid.attach (type_tbox,  		1,	1, 	1,	1);
		grid.attach (address_label, 	0,	2, 	1,	1);
		grid.attach (address_tbox,  	1,	2, 	1,	1);
		grid.attach (box, 				1,	3, 	1, 	1);
		
		grid.set_column_homogeneous (false);
		grid.set_row_homogeneous (true);
		grid.row_spacing = 12;
	
	
		if (index == -1) {
			favorites_switch.set_sensitive (false);
			favorites_switch.set_tooltip_text ("Favorite slots are full");
		}
					
		type_tbox.append_text ("iPhone");
		type_tbox.append_text ("iPod");
		type_tbox.append_text ("iPad");
		type_tbox.active = 0;

		address_tbox.set_placeholder_text ("192.168.1.");
		address_tbox.focus_in_event.connect (() => {
			if (address_focus == false) {
				address_tbox.text = "192.168.1.";
				address_focus = true; 

			}
			return false;
		});
		
		
		mainbox.add (grid);
		mainbox.spacing = 12;
		
		
		this.response.connect((id) => {
			switch (id) {
			case 1:
				if (address_focus == true) {
					if (index != -1 && favorites_switch.active == true) {
						settings.set_int (@"type$index" , type_tbox.active);
						settings.set_string (@"address$index", @"$(address_tbox.text)");
					}
					connect_device (@"$(address_tbox.text)");
					this.destroy ();	
				}
				else address_tbox.set_placeholder_text ("Enter an address");
				break;
			case 2:
				running = false;
				this.destroy ();
				break;
			}
		});
	}
}
	
public class MyApp : Gtk.Window {
	string[] URL = {};
	int added_items = 0;
	
public Welcome WelcomeWindow () {
	var welcome_ = new Welcome ("iViewer", "remote messages client");
	this.Items (settings.get_int ("type0") ,settings.get_string ("address0"), welcome_);
	this.Items (settings.get_int ("type1") ,settings.get_string ("address1"), welcome_);
	this.Items (settings.get_int ("type2") ,settings.get_string ("address2"), welcome_);
	this.Items (-5, "", welcome_);
	
	var css_theme = new CssProvider ();
	var css_file = @"$(data_path)/custom.css";
	
	css_theme.load_from_path (css_file);
	Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), css_theme, Gtk.STYLE_PROVIDER_PRIORITY_USER);
	
	return welcome_;
}

public void Items (int index, string address_, Welcome welcome_) {
	Gtk.Image icon = new Gtk.Image ();
	
	switch (index + 1) {
		case 1: //iphone
			icon.set_from_file (@"$(data_path)/iphone.png"); 
			welcome_.append_with_image (icon, "iPhone iMessage", "Connect to iPhone");
			URL += "http://" + address_;
			break;
		case 2: //ipod
			icon.set_from_file (@"$(data_path)/ipod.png");
			welcome_.append_with_image (icon, "iPod iMessage", "Connect to iPod");
			URL += "http://" + address_;
			break;
		case 3: //ipad
			icon.set_from_file (@"$(data_path)/ipad.png");
			welcome_.append_with_image (icon, "iPad iMessage", "Connect to iPad");
			URL += "http://" + address_;
			break;
		case -4: //"Add" button
			welcome_.append ("add", "    New Device", "    Connect to a new device");		
		break;	
	}
}	
	
public ScrolledWindow create_web_window (int index, string overide) {
	this.remove (welcome);
	
	view = new WebKit.WebView ();
	if (overide == "false") view.load_uri (URL[index]);
	else view.load_uri ("http://" + overide);
 	
	var settings = new WebKit.Settings ();
 	settings.enable_smooth_scrolling = true;
 	settings.enable_media_stream = true;
 	settings.enable_webgl = true;
	settings.enable_page_cache = true;
	settings.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1944.0 Safari/537.36";
	settings.enable_mediasource = true;
	settings.enable_webaudio = true;
	settings.enable_hyperlink_auditing = false;
	settings.javascript_can_open_windows_automatically = true;
	settings.set_default_font_size (12);
	
 	view.settings = settings;

	var scrolled_window = new ScrolledWindow (null, null);
	scrolled_window.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
	scrolled_window.add (view);

	return scrolled_window;
}
public void show_welcome () {
	this.width_request = 340;
	this.height_request = 100;
	this.resize (800,650);
	this.set_title ("iViewer");
	welcome.destroy ();
	welcome = WelcomeWindow ();
	
	welcome.activated.connect ((index) => {
		main_index = index;
		if (index == 3 || settings.get_int(@"type$index") == -1) {	//If new device was requested
			if (running == false) { 
			var add_device = new Device_Dialog ();
			add_device.connect_device.connect ((url) => { 
				new_webapp (0, true, url); 
				this.resize (980,600);
			});
			
			add_device.show_all ();
			running = true;
			}
		} else {
			new_webapp(index); //imessage
			this.resize (980,600);
		}
	});
	
	this.add (welcome);
	this.title = "iViewer";
	main_index = -1;
		
	headerbar.set_decoration_layout ("close");
}

public void new_webapp (int index, bool notify = true, string overide = "false") {

	var new_iViewer = new SimpleCommand (@"$(data_path)", "./iViewer");
	var webapp = this.create_web_window (index, overide);
	headerbar.set_decoration_layout ("minimize");
	
	//HeaderBar Buttons	
	refresh_button = new ToolButton.from_stock (Gtk.Stock.REFRESH);
    refresh_button.clicked.connect (() => {
        view.reload ();
        if (view.visible == false) box.remove (infobar);       
        view.visible = true;
    });
  	  	
    return_button = new ToolButton.from_stock (Gtk.Stock.GO_BACK);
    return_button.clicked.connect (() => {
    	new_iViewer.run ();
    	this.destroy ();    				 
    });
    
      	
	//Login window
	view.authenticate.connect (() => {
		this.title = "Log in";
		return false;
	});
	
		
	//NOTIFICATIONS
	if (notify == true) {
		Notify.init ("iViewer");
		string summary = "iMessage";
		string body = "New message";
		string icon = "empathy";
		bool newmessage = false;
		//string icon = "iviewer"; //TODO 
		//var icon = new Pixbuf.from_file (@"$(data_path)/iviewer.svg"); //I would do it like this... but it adds a border

		notification = new Notify.Notification (summary, body, icon);
		notification.set_urgency (Urgency.CRITICAL);
		//notification.show (); //TEST NOTIFICATIONS
		//notification.set_image_from_pixbuf (icon);
		view.notify.connect (() => { 
			string temp;
			//unichar c;
			temp = view.title;
			if (temp == "New Message" && view.has_focus == false && newmessage == false) { //Show notification
				newmessage = true;
				//body = "New message";
				//notification.update("iMessage", "New message", "empathy");
				notification.show ();		
			}
			
			this.title = view.title;
		});
				
		this.focus_in_event.connect (() => {
			if (newmessage == true) {
				newmessage = false;
				notification.close ();
				messages = 0;
			}
			return false;
		});	
	}	
		
	//Error bar
	infobar = new InfoBar ();
	switch (settings.get_int (@"type$main_index")) {
		case 0:
			device = "iPhone";
		break;
		case 1:
			device = "iPod";
		break;
		case 2:
			device = "iPad";
		break;		
		default:
			device = "Device";
		break;
	}
	
	var error_label = new Label (@"<b>Connection to $device Failed</b>\nWould you like to remove it from favorites?");
	error_label.set_use_markup (true);
	infobar.set_message_type (MessageType.ERROR);
	infobar.get_content_area ().add (error_label);
	infobar.add_button ("Remove", 1);
	infobar.response.connect ((id) => {
		settings.set_int (@"type$main_index", -1);
		settings.set_string (@"address$main_index", "");
		
		new_iViewer.run ();
    	this.destroy ();
	});
	
	view.load_failed.connect (() => {
		box.pack_start (infobar, false);
		
		this.show_all ();
		view.visible = false;
		return false;
	});
	
	
	
    headerbar.pack_end (refresh_button);
    headerbar.pack_end (return_button);
    box.pack_end (webapp);
    this.add (box);
	this.show_all ();
}


public MyApp() {
	
	this.destroy.connect (Gtk.main_quit);
	this.width_request = 540;
	this.height_request = 300;
	this.resize (800,650);

	box = new Box (Gtk.Orientation.VERTICAL, 0);
	
	headerbar = new Gtk.HeaderBar ();
	headerbar.set_decoration_layout ("close");
    headerbar.decoration_layout_set = true;
    headerbar.show_close_button = true;
	this.set_titlebar (headerbar);
	this.title = "iViewer";
	
	show_welcome ();
		
}

public static int main (string[] args) {
	Gtk.init (ref args);
	settings = new GLib.Settings ("org.felipe.iViewer");
    var variables = new Granite.Services.Paths ();
    
    variables.initialize ("iViewer", "/dev/null");
    data_path = @"$(variables.home_folder.get_path())/.local/iViewer";
    
	
	app = new MyApp ();
	app.show_all ();
	
	Gtk.main ();
	notification.close ();

return 0;
}}}
