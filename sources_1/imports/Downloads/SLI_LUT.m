% Generate the LUT values
lut = 0.5 + 0.5 * cos(2*pi*(0:719)/720);
lutV = 0.5 + 0.5 * cos(2*pi*(0:1279)/1280);
% Scale the values to integers between 0 and 255
lut_scaled = uint8(255 * lut);
lut_scaled_V = uint8(255 * lutV);
% Write the array to a raw binary file
fid = fopen('LUT.raw', 'wb');
fwrite(fid, lut_scaled, 'uint8');
fwrite(fid, lut_scaled_V, 'uint8');
fclose(fid);
clear;