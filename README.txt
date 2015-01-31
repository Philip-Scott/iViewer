*
 * Copyright (c) 2015 Felipe Escoto
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Felipe Escoto 
 */


Instalation ************************************************************************************

1.- Jailbreak your idevice, install the "Remote Messages" tweak and enable it from your settings
2.- Edit the iViewer desktop file, and replace "###YOUR USERNAME####" with your username
3.- Place the desktop file in YOUR_HOME_DIR/.local/share/applications
4.- Place the iViewer folder in YOUR_HOME_DIR/.local/
5.- In the iViewer folder, give "execute" permissions to the "iViewer" executable
6.- in the terminal, cd to this directory, and execute:

sudo cp org.felipe.iViewer.gschema.xml /usr/share/glib-2.0/schemas/
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

7.- Enjoy! 


Compile this program ***************************************************************************
In case the executables aren't working for you: 

sudo apt-get install libwebkit2gtk-3.0-dev     
sudo apt-get build-dep granite-demo pantheon-calculator
cp /usr/share/vala-0.26/vapi/webkit2gtk-4.0.vapi /usr/share/vala-0.26/vapi/webkit2gtk-3.0.vapi
cp /usr/share/vala-0.26/vapi/webkit2gtk-4.0.deps /usr/share/vala-0.26/vapi/webkit2gtk-3.0.deps

valac-0.26 --pkg gtk+-3.0 --pkg webkit2gtk-3.0 --pkg libnotify --pkg granite --thread --target-glib 2.32 iViewer.vala

sudo cp org.felipe.iViewer.xml /usr/share/glib-2.0/schemas/
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/





Special thanks to:

- Micah Ilbery for the Awesome icon
- Kay van der Zander and Nicolas Laplante for their help with vala 



