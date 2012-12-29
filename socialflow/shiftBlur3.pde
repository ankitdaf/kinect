// 00 51 00
// 51 52 00
// 00 51 00
// 256 in total, >>8

void shiftBlur3(int[] s, int[] t){ // source & target buffer  int yOffset;
  int yOffset;
  for (int i = 1; i < (width-1); ++i){
    
    yOffset = width*(height-1);
    // top edge (minus corner pixels)
    t[i] = (((((s[i] & 0xFF) * 52) + 
      ((s[i+1] & 0xFF) + 
      (s[i-1] & 0xFF) + 
      (s[i + width] & 0xFF) + 
      (s[i + yOffset] & 0xFF)) * 51) >>> 8)  & 0xFF) +
      (((((s[i] & 0xFF00) * 52) + 
      ((s[i+1] & 0xFF00) + 
      (s[i-1] & 0xFF00) + 
      (s[i + width] & 0xFF00) + 
      (s[i + yOffset] & 0xFF00)) * 51) >>> 8)  & 0xFF00) +
      (((((s[i] & 0xFF0000) * 52) + 
      ((s[i+1] & 0xFF0000) + 
      (s[i-1] & 0xFF0000) + 
      (s[i + width] & 0xFF0000) + 
      (s[i + yOffset] & 0xFF0000)) * 51) >>> 8)  & 0xFF0000) +
      0xFF000000; //ignores transparency

    // bottom edge (minus corner pixels)
    t[i + yOffset] = (((((s[i + yOffset] & 0xFF) * 52) + 
      ((s[i - 1 + yOffset] & 0xFF) + 
      (s[i + 1 + yOffset] & 0xFF) +
      (s[i + yOffset - width] & 0xFF) +
      (s[i] & 0xFF)) * 51) >>> 8) & 0xFF) +
      (((((s[i + yOffset] & 0xFF00) * 52) + 
      ((s[i - 1 + yOffset] & 0xFF00) + 
      (s[i + 1 + yOffset] & 0xFF00) +
      (s[i + yOffset - width] & 0xFF00) +
      (s[i] & 0xFF00)) * 51) >>> 8) & 0xFF00) +
      (((((s[i + yOffset] & 0xFF0000) * 52) + 
      ((s[i - 1 + yOffset] & 0xFF0000) + 
      (s[i + 1 + yOffset] & 0xFF0000) +
      (s[i + yOffset - width] & 0xFF0000) +
      (s[i] & 0xFF0000)) * 51) >>> 8) & 0xFF0000) +
      0xFF000000;    
    
    // central square
    for (int j = 1; j < (height-1); ++j){
      yOffset = j*width;
      t[i + yOffset] = (((((s[i + yOffset] & 0xFF) * 52) +
        ((s[i + 1 + yOffset] & 0xFF) +
        (s[i - 1 + yOffset] & 0xFF) +
        (s[i + yOffset + width] & 0xFF) +
        (s[i + yOffset - width] & 0xFF)) * 51) >>> 8) & 0xFF) +
        (((((s[i + yOffset] & 0xFF00) * 52) +
        ((s[i + 1 + yOffset] & 0xFF00) +
        (s[i - 1 + yOffset] & 0xFF00) +
        (s[i + yOffset + width] & 0xFF00) +
        (s[i + yOffset - width] & 0xFF00)) * 51) >>> 8) & 0xFF00) +
        (((((s[i + yOffset] & 0xFF0000) * 52) +
        ((s[i + 1 + yOffset] & 0xFF0000) +
        (s[i - 1 + yOffset] & 0xFF0000) +
        (s[i + yOffset + width] & 0xFF0000) +
        (s[i + yOffset - width] & 0xFF0000)) * 51) >>> 8) & 0xFF0000) +
        0xFF000000;
    }
  }
  
  // left and right edge (minus corner pixels)
  for (int j = 1; j < (height-1); ++j){
      yOffset = j*width;
      t[yOffset] = (((((s[yOffset] & 0xFF) * 52) +
        ((s[yOffset + 1] & 0xFF) +
        (s[yOffset + width - 1] & 0xFF) +
        (s[yOffset + width] & 0xFF) +
        (s[yOffset - width] & 0xFF) ) * 51) >>> 8) & 0xFF) +
        (((((s[yOffset] & 0xFF00) * 52) +
        ((s[yOffset + 1] & 0xFF00) +
        (s[yOffset + width - 1] & 0xFF00) +
        (s[yOffset + width] & 0xFF00) +
        (s[yOffset - width] & 0xFF00) ) * 51) >>> 8) & 0xFF00) +
        (((((s[yOffset] & 0xFF0000) * 52) +
        ((s[yOffset + 1] & 0xFF0000) +
        (s[yOffset + width - 1] & 0xFF0000) +
        (s[yOffset + width] & 0xFF0000) +
        (s[yOffset - width] & 0xFF0000) ) * 51) >>> 8) & 0xFF0000) +
        0xFF000000;

      t[yOffset + width - 1] = (((((s[yOffset + width - 1] & 0xFF) * 52) +
        ((s[yOffset] & 0xFF) +
        (s[yOffset + width - 2] & 0xFF) +
        (s[yOffset + (width<<1) - 1] & 0xFF) +
        (s[yOffset - 1] & 0xFF)) * 51) >>> 8) & 0xFF) +
        (((((s[yOffset + width - 1] & 0xFF00) * 52) +
        ((s[yOffset] & 0xFF00) +
        (s[yOffset + width - 2] & 0xFF00) +
        (s[yOffset + (width<<1) - 1] & 0xFF00) +
        (s[yOffset - 1] & 0xFF00)) * 51) >>> 8) & 0xFF00) +
        (((((s[yOffset + width - 1] & 0xFF0000) * 52) +
        ((s[yOffset] & 0xFF0000) +
        (s[yOffset + width - 2] & 0xFF0000) +
        (s[yOffset + (width<<1) - 1] & 0xFF0000) +
        (s[yOffset - 1] & 0xFF0000)) * 51) >>> 8) & 0xFF0000) +
        0xFF000000;
  }
  
  // corner pixels
  t[0] = (((((s[0] & 0xFF) * 52) + 
    ((s[1] & 0xFF) + 
    (s[width-1] & 0xFF) + 
    (s[width] & 0xFF) + 
    (s[width*(height-1)] & 0xFF)) * 51) >>> 8)  & 0xFF) +
    (((((s[0] & 0xFF00) * 52) + 
    ((s[1] & 0xFF00) + 
    (s[width-1] & 0xFF00) + 
    (s[width] & 0xFF00) + 
    (s[width*(height-1)] & 0xFF00)) * 51) >>> 8)  & 0xFF00) +
    (((((s[0] & 0xFF0000) * 52) + 
    ((s[1] & 0xFF0000) + 
    (s[width-1] & 0xFF0000) + 
    (s[width] & 0xFF0000) + 
    (s[width*(height-1)] & 0xFF0000)) * 51) >>> 8)  & 0xFF0000) +
    0xFF000000;

  t[width - 1 ] = (((((s[width-1] & 0xFF) * 52) + 
    ((s[width-2] & 0xFF) + 
    (s[0] & 0xFF) + 
    (s[(width<<1) - 1] & 0xFF) + 
    (s[width*height-1] & 0xFF) ) * 51) >>> 8) & 0xFF) +
    (((((s[width-1] & 0xFF00) * 52) + 
    ((s[width-2] & 0xFF00) + 
    (s[0] & 0xFF00) + 
    (s[(width<<1) - 1] & 0xFF00) + 
    (s[width*height-1] & 0xFF00) ) * 51) >>> 8) & 0xFF00) +
    (((((s[width-1] & 0xFF0000) * 52) + 
    ((s[width-2] & 0xFF0000) + 
    (s[0] & 0xFF0000) + 
    (s[(width<<1) - 1] & 0xFF0000) + 
    (s[width*height-1] & 0xFF0000) ) * 51) >>> 8) & 0xFF0000) +
    0xFF000000;

  t[width * height - 1] = (((((s[width*height-1] & 0xFF) * 52) + 
    ((s[width-1] & 0xFF) + 
    (s[width*(height-1)-1] & 0xFF) + 
    (s[width*height-2] & 0xFF) + 
    (s[width*(height-1)] & 0xFF) ) * 51) >>> 8) & 0xFF) +
    (((((s[width*height-1] & 0xFF00) * 52) + 
    ((s[width-1] & 0xFF00) + 
    (s[width*(height-1)-1] & 0xFF00) + 
    (s[width*height-2] & 0xFF00) + 
    (s[width*(height-1)] & 0xFF00) ) * 51) >>> 8) & 0xFF00) +
    (((((s[width*height-1] & 0xFF0000) * 52) + 
    ((s[width-1] & 0xFF0000) + 
    (s[width*(height-1)-1] & 0xFF0000) + 
    (s[width*height-2] & 0xFF0000) + 
    (s[width*(height-1)] & 0xFF0000) ) * 51) >>> 8) & 0xFF0000) +
    0xFF000000;
  
  t[width *(height-1)] = (((((s[width*(height-1)] & 0xFF) * 52) + 
    ((s[width*(height-1) + 1] & 0xFF) + 
    (s[width*height-1] & 0xFF) + 
    (s[width*(height-2)] & 0xFF) + 
    (s[0] & 0xFF) ) * 51) >>> 8) & 0xFF) +
    (((((s[width*(height-1)] & 0xFF00) * 52) + 
    ((s[width*(height-1) + 1] & 0xFF00) + 
    (s[width*height-1] & 0xFF00) + 
    (s[width*(height-2)] & 0xFF00) + 
    (s[0] & 0xFF00) ) * 51) >>> 8) & 0xFF00) +
    (((((s[width*(height-1)] & 0xFF0000) * 52) + 
    ((s[width*(height-1) + 1] & 0xFF0000) + 
    (s[width*height-1] & 0xFF0000) + 
    (s[width*(height-2)] & 0xFF0000) + 
    (s[0] & 0xFF0000) ) * 51) >>> 8) & 0xFF0000) +
    0xFF000000;
}

