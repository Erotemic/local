def main():
    rd = doc.GetActiveRenderData().GetData()
    print rd[c4d.RDATA_XRES]
    print int(round(rd[c4d.RDATA_XRES]))
    print rd[c4d.RDATA_YRES]
    print int(round(rd[c4d.RDATA_YRES]))

import c4d
from c4d import bitmaps, documents

def main():
    rd = doc.GetActiveRenderData().GetData()
    xres = int(round(rd[c4d.RDATA_XRES]))
    yres = int(round(rd[c4d.RDATA_YRES]))

    bmp = bitmaps.BaseBitmap()
    bmp.Init(xres, yres, depth=32)

    res = documents.RenderDocument(doc, rd, bmp, c4d.RENDERFLAGS_EXTERNAL)
    if res == c4d.RENDERRESULT_OK:
        bitmaps.ShowBitmap(bmp)

    if __name__=='__main__':
        main()

