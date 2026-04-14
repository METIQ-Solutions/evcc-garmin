REM Copies the source files from source-annot-glance
REM and replaces the annotations. See README.MD for details.
REM cd .\source-annot-tinyglance\
cd ..\..\source
robocopy .\glance-full .\glance-tiny /MIR
cd .\glance-tiny
for /R %%f in (*.mc) do sed -i "s/(:glance) //g" "%%f"
for /R %%f in (*.mc) do sed -i "s/(:glance :/(:/g" "%%f"
del sed*