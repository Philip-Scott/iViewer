clear 
echo "Installing iViewer"
sudo cp org.felipe.iViewer*.xml /usr/share/glib-2.0/schemas/
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
sudo mkdir /usr/share/iViewer/
sudo cp iViewer.desktop /usr/share/applications/iViewer.desktop
sudo cp iViewer/iViewer /usr/share/iViewer/iViewer
sudo cp iViewer/custom.css /usr/share/iViewer/custom.css
sudo cp iViewer/ipad.png /usr/share/iViewer/ipad.png
sudo cp iViewer/iphone.png /usr/share/iViewer/iphone.png
sudo cp iViewer/ipod.png /usr/share/iViewer/ipod.png



#Icons
sudo cp icons/32/iViewer.svg /usr/share/icons/hicolor/32x32/apps/iViewer.svg
sudo cp icons/48/iViewer.svg /usr/share/icons/hicolor/48x48/apps/iViewer.svg
sudo cp icons/64/iViewer.svg /usr/share/icons/hicolor/64x64/apps/iViewer.svg
sudo cp icons/128/iViewer.svg /usr/share/icons/hicolor/128x128/apps/iViewer.svg
sudo cp icons/128/iViewer.svg /usr/share/icons/hicolor/scalable/apps/iViewer.svg

sudo chmod 644 /usr/share/icons/hicolor/32x32/apps/iViewer.svg
sudo chmod 644 /usr/share/icons/hicolor/48x48/apps/iViewer.svg
sudo chmod 644 /usr/share/icons/hicolor/64x64/apps/iViewer.svg
sudo chmod 644 /usr/share/icons/hicolor/128x128/apps/iViewer.svg
sudo chmod 644 /usr/share/icons/hicolor/scalable/apps/iViewer.svg

sudo gtk-update-icon-cache /usr/share/icons/hicolor
