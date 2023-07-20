dir1=getDirectory("Get Directory"); list = getFileList(dir1); 
path2=getDirectory("My output dir"); setBatchMode(true);
for (i=0; i<list.length; i++) { showProgress(i+1, list.length); open(dir1 + list[i]);
run("Set Scale...", "distance=2.2026 known=1 unit=µm global");
run("8-bit");
run("Subtract Background...", "rolling=30"); 
original_file_name = getTitle(); 
duplicated_file_name = getTitle() + "-1";
run("Duplicate...", "title=&duplicated_file_name");
run("Gaussian Blur...", "sigma=1.50");
run("Auto Local Threshold", "method=Phansalkar radius=3 parameter_1=0 parameter_2=0 white");
run("Set Measurements...", "area mean standard min centroid integrated display redirect=[&original_file_name] decimal = 2");
run("Analyze Particles...", "size=5-200 pixel circularity=0.50-1.00 show=[Overlay Masks] display exclude");
run("Flatten");
saveAs("Tiff", path2 + getTitle() + "-result.tif");
close();}

